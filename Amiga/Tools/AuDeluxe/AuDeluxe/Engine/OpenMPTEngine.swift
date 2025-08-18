//
//  OpenMPTEngine.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/15/25.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
final class OpenMPTEngine: ObservableObject, Sendable {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var currentSongInfo: String?
    @Published var songDetails: String?
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var currentSongDuration: TimeInterval = 0
    @Published var isLooping = false
    @Published var isShuffling = false
    @Published var searchText: String = ""
    
    @Published var sortOrder: SortOrder = .name {
        didSet { Task { await applySort() } }
    }
    
    // MARK: - Playlist Properties
    @Published var allPlaylistItems: [PlaylistItem] = []
    @Published var activePlaylist: Playlist? = nil
    
    var playlistItems: [PlaylistItem] {
        var itemsToShow: [PlaylistItem]
        
        if let activePlaylist = activePlaylist {
            let urls = Set(activePlaylist.fileURLs)
            itemsToShow = allPlaylistItems.filter { urls.contains($0.fileURL) }
        } else {
            itemsToShow = allPlaylistItems
        }
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            itemsToShow = itemsToShow.filter { item in
                let titleMatch = item.title.range(of: searchText, options: .caseInsensitive) != nil
                let artistMatch = item.artist.range(of: searchText, options: .caseInsensitive) != nil
                return titleMatch || artistMatch
            }
        }
        
        return sortItems(itemsToShow)
    }

    // MARK: - Tracker Data Properties
    @Published var visiblePatternRows: [PatternRow] = []
    @Published var currentRow: Int32 = -1
    @Published var currentPattern: Int32 = -1
    @Published var numChannels: Int32 = 0
    
    var isTrackerVisible = false

    // MARK: - Private Properties
    private let debug = false
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var processingFormat: AVAudioFormat!
    var currentlyPlayingFileURL: URL?
    private var timeUpdateTask: Task<Void, Never>?
    
    private let moduleActor = ModuleActor()
    private let uiModuleActor = ModuleActor()
    
    private let visibleWindowSize = 51
    private var halfWindowSize: Int { visibleWindowSize / 2 }
    
    let supportedExtensions = [
        "mod", "s3m", "xm", "it", "med", "okt", "mtm", "669", "dsm", "far", "ptm", "ult",
        "amf", "ams", "dbm", "dmf", "imf", "j2b", "mdl", "mo3", "psm", "stm", "stx", "umx"
    ]
    let ratingKey = "com.audeluxe.rating"
    let titleKey = "com.audeluxe.title"
    let artistKey = "com.audeluxe.artist"
    private var pendingBufferCount = 0
    private var reachedEndOfFile = false
    private let targetPendingBuffers = 10
    
    weak var settingsStore: SettingsStore?
    private var scannedMusicFolderURL: URL?
    var onSongChange: ((PlaylistItem.ID) -> Void)?
    private var configChangeObserver: Any?
    
    private var cacheURL: URL? {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        guard let folderPath = scannedMusicFolderURL?.path.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }
        let appDirectory = appSupport.appendingPathComponent("AuDeluxe")
        return appDirectory.appendingPathComponent("\(folderPath).audeluxecache")
    }

    // MARK: - Initialization & Setup
    init() {
        Task {
            await moduleActor.setDebug(debug)
            await uiModuleActor.setDebug(debug)
            setupAudioEngine()
        }
        if debug { print("OpenMPTEngine: Initialized and ready.") }
    }

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        self.processingFormat = playerNode.outputFormat(forBus: 0)
        if debug { print("OpenMPTEngine: Audio engine setup with format: \(String(describing: self.processingFormat))") }
        
        configChangeObserver = NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            Task {
                let wasPlaying = await self.isPlaying
                let currentFile = await self.currentlyPlayingFileURL
                let currentFolder = await self.scannedMusicFolderURL
                await self.stopAndReset()
                if wasPlaying, let fileURL = currentFile, let folderURL = currentFolder {
                    await self.play(fileURL: fileURL, musicFolderURL: folderURL)
                }
            }
        }
    }

    // MARK: - Public Control Methods
    func clearAllSongs() {
        self.allPlaylistItems = []
        self.activePlaylist = nil
        self.objectWillChange.send()
    }
    
    func scanMusicFolder(for musicFolderURL: URL) async {
        self.scannedMusicFolderURL = musicFolderURL

        if await loadPlaylistFromCache(for: musicFolderURL) {
            if debug { print("OpenMPTEngine: Successfully loaded playlist from cache.") }
            return
        }

        if debug { print("OpenMPTEngine: Cache invalid or not found. Performing full scan.") }
        let items = await Task.detached(priority: .userInitiated) { [supportedExtensions, ratingKey, titleKey, artistKey] () -> [PlaylistItem] in
            guard musicFolderURL.startAccessingSecurityScopedResource() else { return [] }
            defer { musicFolderURL.stopAccessingSecurityScopedResource() }

            var playlistItems: [PlaylistItem] = []
            let fileManager = FileManager.default
            guard let enumerator = fileManager.enumerator(at: musicFolderURL, includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                return []
            }
            
            let allURLs = enumerator.allObjects as? [URL] ?? []

            for fileURL in allURLs {
                if isPlayable(fileURL: fileURL, supportedExtensions: supportedExtensions),
                   let metadata = getMetadata(for: fileURL, ratingKey: ratingKey, titleKey: titleKey, artistKey: artistKey) {
                    playlistItems.append(metadata)
                }
            }
            return playlistItems
        }.value
        
        self.allPlaylistItems = items
        self.activePlaylist = nil
        await applySort()
        await savePlaylistToCache(items: items, for: musicFolderURL)

        if debug { print("OpenMPTEngine: Found \(items.count) playable files and saved to cache.") }
    }

    func play(fileURL: URL, musicFolderURL: URL) async {
        await stopAndReset()
        
        self.scannedMusicFolderURL = musicFolderURL
        
        typealias ModuleCreationResult = (channels: Int32, duration: Double, success: Bool)

        let result: ModuleCreationResult = await Task.detached(priority: .userInitiated) {
            guard musicFolderURL.startAccessingSecurityScopedResource() else { return (0, 0, false) }
            defer { musicFolderURL.stopAccessingSecurityScopedResource() }
            
            guard let data = try? Data(contentsOf: fileURL) else { return (0, 0, false) }
            
            let createResult = await self.moduleActor.create(from: data)
            guard createResult.module != nil else {
                await self.moduleActor.destroy()
                await self.uiModuleActor.destroy()
                return (0, 0, false)
            }
            
            _ = await self.uiModuleActor.create(from: data)
            
            return (createResult.channels, createResult.duration, true)
        }.value

        guard result.success else {
            await stopAndReset()
            return
        }

        self.currentlyPlayingFileURL = fileURL
        
        await moduleActor.setRepeat(count: self.isLooping ? -1 : 0)
        await uiModuleActor.setRepeat(count: self.isLooping ? -1 : 0)

        self.numChannels = result.channels
        self.currentSongDuration = result.duration
        
        if let item = self.allPlaylistItems.first(where: { $0.fileURL == fileURL }) {
            let type = item.metadata["type_long"] ?? "", tracker = item.metadata["tracker"] ?? "", date = item.metadata["date"] ?? "", container = item.metadata["container_long"] ?? ""
            var details: [String] = []
            if !type.isEmpty { details.append("Type: \(type)") }
            if !tracker.isEmpty { details.append("Tracker: \(tracker)") }
            if !date.isEmpty { details.append("Date: \(date)") }
            if !container.isEmpty { details.append("Container: \(container)") }
            self.songDetails = details.joined(separator: " | ")
            self.onSongChange?(item.id)
        }

        let uiActor = self.uiModuleActor
        let numChannels = self.numChannels
        let debug = self.debug
        Task.detached(priority: .background) {
            let numPatterns = await uiActor.getNumPatterns()
            if debug { print("OpenMPTEngine: Starting background caching for \(numPatterns) patterns") }
            let cachingStart = Date()
            for p in 0..<numPatterns {
                let nr = await uiActor.getPatternNumRows(p)
                _ = await uiActor.getFormattedPattern(pattern: p, numRows: nr, numChannels: numChannels)
            }
            if debug { print("OpenMPTEngine: Background caching completed in \(Date().timeIntervalSince(cachingStart)) seconds") }
        }
        
        do {
            try audioEngine.start()
            playerNode.play()
            
            pendingBufferCount = 0
            reachedEndOfFile = false
            
            var preRenderedBuffers: [AVAudioPCMBuffer] = []
            for i in 1...targetPendingBuffers {
                if let buffer = await renderBuffer() {
                    preRenderedBuffers.append(buffer)
                    if debug { print("OpenMPTEngine: Pre-rendered buffer \(i)/\(targetPendingBuffers)") }
                } else {
                    reachedEndOfFile = true
                    break
                }
            }
            
            for buffer in preRenderedBuffers {
                scheduleBuffer(buffer)
            }
            
            self.isPlaying = true
            self.currentSongInfo = fileURL.lastPathComponent
            startTimeUpdateTimer()
        } catch {
            if debug { print("OpenMPTEngine: ERROR - Could not start AVAudioEngine: \(error.localizedDescription)") }
            await stopAndReset()
        }
    }

    func pause() {
        guard isPlaying else { return }
        timeUpdateTask?.cancel()
        timeUpdateTask = nil
        playerNode.stop()
        audioEngine.pause()
        isPlaying = false
    }
    
    func resume() {
        guard !isPlaying, currentlyPlayingFileURL != nil else { return }
        do {
            try audioEngine.start()
            playerNode.play()
            self.isPlaying = true
            startTimeUpdateTimer()
        } catch {
            if debug { print("OpenMPTEngine: ERROR - Could not resume AVAudioEngine: \(error.localizedDescription)") }
        }
    }

    func stopAndReset() async {
        timeUpdateTask?.cancel()
        timeUpdateTask = nil
        
        if audioEngine.isRunning {
            playerNode.stop()
            playerNode.reset()
            audioEngine.pause()
        }
        
        await moduleActor.destroy()
        await uiModuleActor.destroy()
        
        isPlaying = false
        currentSongInfo = nil
        songDetails = nil
        pendingBufferCount = 0
        reachedEndOfFile = false
        currentPlaybackTime = 0
        currentSongDuration = 0
        visiblePatternRows = []
        currentRow = -1
        currentPattern = -1
        numChannels = 0
        
        if let url = currentlyPlayingFileURL, url.startAccessingSecurityScopedResource() {
            url.stopAccessingSecurityScopedResource()
        }
        currentlyPlayingFileURL = nil
    }

    func toggleLooping() {
        self.isLooping.toggle()
        if debug { print("Toggling loop to: \(self.isLooping)") }
        if isPlaying {
            let repeatCount: Int32 = self.isLooping ? -1 : 0
            if debug { print("Setting repeat count to: \(repeatCount)") }
            Task {
                await moduleActor.setRepeat(count: repeatCount)
                await uiModuleActor.setRepeat(count: repeatCount)
            }
        }
    }

    func toggleShuffle(selectionID: PlaylistItem.ID?) {
        self.isShuffling.toggle()
        if isShuffling {
            let selectedItem = allPlaylistItems.first { $0.id == selectionID }
            var shuffledItems = allPlaylistItems.shuffled()
            if let item = selectedItem, let index = shuffledItems.firstIndex(of: item) {
                shuffledItems.remove(at: index)
                shuffledItems.insert(item, at: 0)
            }
            self.allPlaylistItems = shuffledItems
        } else {
            Task { await self.applySort() }
        }
    }
    
    func seek(to time: TimeInterval) async {
        let isLooping = self.isLooping
        let duration = self.currentSongDuration
        
        await Task.detached(priority: .userInitiated) {
            var effectiveTime = time
            if isLooping && duration > 0 {
                effectiveTime = time.truncatingRemainder(dividingBy: duration)
            }
            await self.moduleActor.setPosition(seconds: effectiveTime)
            await self.uiModuleActor.setPosition(seconds: effectiveTime)
        }.value
    }
    
    func setActivePlaylist(_ playlist: Playlist?) {
        activePlaylist = playlist
    }

    private func currentPlayedTime() -> Double {
        guard let nodeTime = self.playerNode.lastRenderTime,
              let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) else {
            return self.currentPlaybackTime
        }
        return Double(playerTime.sampleTime) / playerTime.sampleRate
    }
    
    private func updateVisibleRows() {
        let halfWindow = self.halfWindowSize
        Task.detached(priority: .userInitiated) {
            let playTime = await self.currentPlayedTime()
            let isLooping = await self.isLooping
            let duration = await self.currentSongDuration
            let numChannels = await self.numChannels
            
            var effectiveTime = playTime
            if isLooping && duration > 0 {
                effectiveTime = playTime.truncatingRemainder(dividingBy: duration)
            }
            await self.uiModuleActor.setPosition(seconds: effectiveTime)
            let state = await self.uiModuleActor.getPlaybackState()

            guard state.numRows > 0 else {
                await MainActor.run { self.visiblePatternRows = [] }
                return
            }

            let allRows = await self.uiModuleActor.getFormattedPattern(pattern: state.pattern, numRows: state.numRows, numChannels: numChannels)
            
            let first = max(0, Int(state.row) - halfWindow)
            let last = min(Int(state.numRows) - 1, first + self.visibleWindowSize - 1)
            let slice = Array(allRows[first...last])

            await MainActor.run {
                self.currentRow = state.row
                self.currentPlaybackTime = playTime
                if state.pattern != self.currentPattern {
                    self.currentPattern = state.pattern
                }
                self.visiblePatternRows = slice
            }
        }
    }

    private func startTimeUpdateTimer() {
        timeUpdateTask = Task {
            var lastPattern: Int32 = -1
            var lastRow: Int32 = -1
            while !Task.isCancelled {
                let state = await self.moduleActor.getPlaybackState()
                
                // Always log when looping is enabled to see what's happening
                if self.isLooping || self.debug {
                    if self.debug {
                        print("Timer - Time: \(state.time), Duration: \(self.currentSongDuration), Pattern: \(state.pattern), Row: \(state.row), Looping: \(self.isLooping)")
                    }
                }
                
                // Handle looping manually if libopenmpt isn't resetting time properly
                var effectiveTime = state.time
                if self.isLooping && self.currentSongDuration > 0 && state.time >= self.currentSongDuration {
                    effectiveTime = state.time.truncatingRemainder(dividingBy: self.currentSongDuration)
                    if self.debug {
                        print("Manual loop reset - Original: \(state.time), Effective: \(effectiveTime)")
                    }
                }
                
                self.currentPlaybackTime = effectiveTime
                
                if self.isTrackerVisible {
                    if state.pattern != lastPattern || state.row != lastRow {
                        self.updateVisibleRows()
                        lastPattern = state.pattern
                        lastRow = state.row
                    }
                }

                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
    
    private func renderBuffer() async -> AVAudioPCMBuffer? {
        return await moduleActor.render(format: self.processingFormat, frameCount: 8192)
    }
    
    private func scheduleBuffer(_ buffer: AVAudioPCMBuffer) {
        pendingBufferCount += 1
        if debug { print("OpenMPTEngine: Scheduled buffer, pending: \(pendingBufferCount)") }
        playerNode.scheduleBuffer(buffer) { [weak self] in
            Task {
                await self?.handleBufferCompletion()
            }
        }
    }
    
    private func handleBufferCompletion() async {
        pendingBufferCount -= 1
        if debug { print("OpenMPTEngine: Buffer completed, pending: \(pendingBufferCount)") }

        if !reachedEndOfFile {
            if let newBuffer = await renderBuffer() {
                scheduleBuffer(newBuffer)
            } else {
                if debug { print("OpenMPTEngine: Rendered nil buffer, marking reachedEndOfFile.") }
                reachedEndOfFile = true
            }
        }
        
        await checkForPlaybackCompletion()
    }
    
    private func checkForPlaybackCompletion() async {
        if reachedEndOfFile && pendingBufferCount == 0 {
            if debug { print("OpenMPTEngine: Playback complete.") }
            if settingsStore?.automaticallyPlayNext == true && !isLooping {
                guard let currentURL = currentlyPlayingFileURL,
                      let musicFolderURL = self.scannedMusicFolderURL,
                      let currentIndex = playlistItems.firstIndex(where: { $0.fileURL == currentURL }) else {
                    await stopAndReset()
                    return
                }

                let nextIndex = currentIndex + 1
                if playlistItems.indices.contains(nextIndex) {
                    let nextItem = playlistItems[nextIndex]
                    if debug { print("OpenMPTEngine: Playing next track: \(nextItem.fileURL.lastPathComponent)") }
                    await play(fileURL: nextItem.fileURL, musicFolderURL: musicFolderURL)
                } else {
                    await stopAndReset()
                }
            } else {
                await stopAndReset()
            }
        }
    }

    private func applySort() async {
        if self.isShuffling { self.isShuffling = false }
        let sortedItems = sortItems(self.allPlaylistItems)
        self.allPlaylistItems = sortedItems
    }
    
    private func sortItems(_ items: [PlaylistItem]) -> [PlaylistItem] {
        switch sortOrder {
        case .name: return items.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .duration: return items.sorted { $0.duration < $1.duration }
        case .rating: return items.sorted { $0.rating > $1.rating }
        }
    }
    
    func rateFile(fileURL: URL, rating: Int, musicFolderURL: URL) {
        setAttribute(key: ratingKey, value: rating, forFileAt: fileURL, in: musicFolderURL)
    }
    
    func updateFile(from oldURL: URL, to newURL: URL, newTitle: String, newArtist: String, musicFolderURL: URL) async -> Bool {
        setAttribute(key: titleKey, value: newTitle, forFileAt: oldURL, in: musicFolderURL)
        setAttribute(key: artistKey, value: newArtist, forFileAt: oldURL, in: musicFolderURL)
        if oldURL.lastPathComponent != newURL.lastPathComponent {
            guard musicFolderURL.startAccessingSecurityScopedResource() else { return false }
            defer { musicFolderURL.stopAccessingSecurityScopedResource() }
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                return true
            } catch {
                if debug { print("Error renaming file: \(error)") }
                return false
            }
        }
        return true
    }
    
    // MARK: - Caching Logic
    private func loadPlaylistFromCache(for musicFolderURL: URL) async -> Bool {
        guard let cacheURL = self.cacheURL, FileManager.default.fileExists(atPath: cacheURL.path) else { return false }

        do {
            let folderAttributes = try FileManager.default.attributesOfItem(atPath: musicFolderURL.path)
            guard let folderModificationDate = folderAttributes[.modificationDate] as? Date else { return false }

            let data = try Data(contentsOf: cacheURL)
            let cache = try JSONDecoder().decode(PlaylistCache.self, from: data)

            if Calendar.current.compare(folderModificationDate, to: cache.folderModificationDate, toGranularity: .second) == .orderedSame {
                self.allPlaylistItems = cache.items
                await self.applySort()
                return true
            }
        } catch {
            if debug { print("Error loading cache: \(error.localizedDescription)") }
            try? FileManager.default.removeItem(at: cacheURL)
            return false
        }

        return false
    }

    private func savePlaylistToCache(items: [PlaylistItem], for musicFolderURL: URL) async {
        guard let cacheURL = self.cacheURL else { return }

        do {
            let folderAttributes = try FileManager.default.attributesOfItem(atPath: musicFolderURL.path)
            guard let folderModificationDate = folderAttributes[.modificationDate] as? Date else { return }

            let cache = PlaylistCache(folderModificationDate: folderModificationDate, items: items)
            let data = try JSONEncoder().encode(cache)
            
            let directoryURL = cacheURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            
            try data.write(to: cacheURL)
        } catch {
            if debug { print("Error saving cache: \(error.localizedDescription)") }
        }
    }
    
    deinit {
        if let observer = configChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
