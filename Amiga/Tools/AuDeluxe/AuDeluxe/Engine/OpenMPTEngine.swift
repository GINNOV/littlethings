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
    @Published var presentedError: FileOperationError?
    @Published private(set) var scanStatus: LibraryScanStatus = .idle

    @Published var sortOrder: SortOrder = .name {
        didSet { Task { await applySort() } }
    }

    // MARK: - Playlist Properties
    @Published var allPlaylistItems: [PlaylistItem] = []
    @Published var activePlaylist: Playlist? = nil
    private var shuffledIDs: [PlaylistItem.ID]?

    var playlistItems: [PlaylistItem] {
        PlaybackQueue.make(
            items: allPlaylistItems,
            activePlaylist: activePlaylist,
            searchText: searchText,
            sortOrder: sortOrder,
            shuffledIDs: shuffledIDs
        )
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
    private var scanTask: Task<Void, Never>?
    private var scanGeneration: UInt64 = 0
    
    private let moduleActor = ModuleActor()
    private let uiModuleActor = ModuleActor()
    
    private let visibleWindowSize = 51
    private var halfWindowSize: Int { visibleWindowSize / 2 }
    
    let supportedExtensions = ModuleFormat.supportedExtensions
    let ratingKey = "com.audeluxe.rating"
    let titleKey = "com.audeluxe.title"
    let artistKey = "com.audeluxe.artist"
    private var pendingBufferCount = 0
    private var reachedEndOfFile = false
    private let targetPendingBuffers = 10
    private var bufferGeneration: UInt64 = 0
    
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
        cancelMusicFolderScan(showCancelledStatus: false)
        scanStatus = .idle
        self.allPlaylistItems = []
        self.activePlaylist = nil
        self.objectWillChange.send()
    }

    func requestMusicFolderScan(for musicFolderURL: URL?) {
        cancelMusicFolderScan(showCancelledStatus: false)
        guard let musicFolderURL else {
            clearAllSongs()
            return
        }
        scanTask = Task { [weak self] in
            await self?.scanMusicFolder(for: musicFolderURL)
        }
    }

    func cancelMusicFolderScan() {
        cancelMusicFolderScan(showCancelledStatus: true)
    }

    func dismissScanStatus() {
        guard !scanStatus.isActive else { return }
        scanStatus = .idle
    }

    func scanMusicFolder(for musicFolderURL: URL) async {
        self.scannedMusicFolderURL = musicFolderURL
        scanGeneration &+= 1
        let generation = scanGeneration
        let cacheURL = self.cacheURL
        scanStatus = .discovering

        do {
            let worker = Task.detached(priority: .userInitiated) { [weak self, ratingKey, titleKey, artistKey] in
                guard musicFolderURL.startAccessingSecurityScopedResource() else {
                    throw FileOperationError.accessDenied
                }
                defer { musicFolderURL.stopAccessingSecurityScopedResource() }

                let discovery = try LibraryFingerprint.discover(in: musicFolderURL)
                if let cacheURL,
                   let data = try? Data(contentsOf: cacheURL),
                   let cache = try? JSONDecoder().decode(PlaylistCache.self, from: data),
                   cache.metadataVersion == 2,
                   cache.fingerprint == discovery.fingerprint {
                    return (
                        items: cache.items,
                        fingerprint: discovery.fingerprint,
                        usedCache: true
                    )
                }

                var items: [PlaylistItem] = []
                let total = discovery.moduleURLs.count
                await self?.publishScanProgress(
                    .processing(
                        processed: 0,
                        total: total,
                        loaded: 0,
                        skipped: 0,
                        currentFile: ""
                    ),
                    generation: generation
                )

                for (index, fileURL) in discovery.moduleURLs.enumerated() {
                    try Task.checkCancellation()
                    if let metadata = getMetadata(
                        for: fileURL,
                        ratingKey: ratingKey,
                        titleKey: titleKey,
                        artistKey: artistKey
                    ) {
                        items.append(metadata)
                    }
                    let processed = index + 1
                    if processed.isMultiple(of: 25) || processed == total {
                        await self?.publishScanProgress(
                            .processing(
                                processed: processed,
                                total: total,
                                loaded: items.count,
                                skipped: processed - items.count,
                                currentFile: discovery.fingerprint.entries[index].relativePath
                            ),
                            generation: generation
                        )
                    }
                }
                return (
                    items: items,
                    fingerprint: discovery.fingerprint,
                    usedCache: false
                )
            }
            let result = try await withTaskCancellationHandler {
                try await worker.value
            } onCancel: {
                worker.cancel()
            }

            guard generation == scanGeneration, !Task.isCancelled else { return }
            allPlaylistItems = result.items
            activePlaylist = nil
            await applySort()
            if !result.usedCache {
                savePlaylistToCache(items: result.items, fingerprint: result.fingerprint)
            }
            scanStatus = .completed(
                loaded: result.items.count,
                skipped: result.fingerprint.entries.count - result.items.count,
                usedCache: result.usedCache
            )
            scanTask = nil
        } catch is CancellationError {
            guard generation == scanGeneration else { return }
            scanStatus = .cancelled
            scanTask = nil
            return
        } catch {
            guard generation == scanGeneration else { return }
            scanStatus = .failed(message: error.localizedDescription)
            scanTask = nil
        }
    }

    private func cancelMusicFolderScan(showCancelledStatus: Bool) {
        let wasActive = scanStatus.isActive
        scanTask?.cancel()
        scanTask = nil
        scanGeneration &+= 1
        if showCancelledStatus, wasActive {
            scanStatus = .cancelled
        }
    }

    private func publishScanProgress(_ status: LibraryScanStatus, generation: UInt64) {
        guard generation == scanGeneration, !Task.isCancelled else { return }
        scanStatus = status
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
        playerNode.pause()
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
        bufferGeneration &+= 1
        
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
            var ids = PlaybackQueue.make(
                items: allPlaylistItems,
                activePlaylist: activePlaylist,
                searchText: searchText,
                sortOrder: sortOrder,
                shuffledIDs: nil
            ).map(\.id).shuffled()
            if let selectionID, let index = ids.firstIndex(of: selectionID) {
                ids.remove(at: index)
                ids.insert(selectionID, at: 0)
            }
            shuffledIDs = ids
        } else {
            shuffledIDs = nil
        }
        objectWillChange.send()
    }
    
    func seek(to time: TimeInterval) async {
        guard currentlyPlayingFileURL != nil else { return }

        let shouldResume = isPlaying
        let effectiveTime: TimeInterval
        if isLooping && currentSongDuration > 0 {
            effectiveTime = time.truncatingRemainder(dividingBy: currentSongDuration)
        } else {
            effectiveTime = min(max(time, 0), currentSongDuration)
        }

        timeUpdateTask?.cancel()
        timeUpdateTask = nil
        bufferGeneration &+= 1
        playerNode.stop()
        playerNode.reset()
        pendingBufferCount = 0
        reachedEndOfFile = false

        await moduleActor.setPosition(seconds: effectiveTime)
        await uiModuleActor.setPosition(seconds: effectiveTime)
        currentPlaybackTime = effectiveTime

        var buffers: [AVAudioPCMBuffer] = []
        for _ in 0..<targetPendingBuffers {
            guard let buffer = await renderBuffer() else {
                reachedEndOfFile = true
                break
            }
            buffers.append(buffer)
        }
        for buffer in buffers {
            scheduleBuffer(buffer)
        }

        guard shouldResume else { return }
        do {
            try audioEngine.start()
            playerNode.play()
            isPlaying = true
            startTimeUpdateTimer()
        } catch {
            await stopAndReset()
        }
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
        let generation = bufferGeneration
        pendingBufferCount += 1
        if debug { print("OpenMPTEngine: Scheduled buffer, pending: \(pendingBufferCount)") }
        playerNode.scheduleBuffer(buffer) { [weak self] in
            Task {
                await self?.handleBufferCompletion(generation: generation)
            }
        }
    }
    
    private func handleBufferCompletion(generation: UInt64) async {
        guard generation == bufferGeneration else { return }
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
        let sortedItems = sortItems(self.allPlaylistItems)
        self.allPlaylistItems = sortedItems
    }
    
    private func sortItems(_ items: [PlaylistItem]) -> [PlaylistItem] {
        switch sortOrder {
        case .name: return items.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .duration: return items.sorted { $0.duration < $1.duration }
        case .rating: return items.sorted { $0.rating > $1.rating }
        case .folder:
            return items.sorted {
                let comparison = $0.folderName.localizedCaseInsensitiveCompare($1.folderName)
                return comparison == .orderedSame
                    ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    : comparison == .orderedAscending
            }
        case .fileType:
            return items.sorted {
                let comparison = $0.fileType.localizedCaseInsensitiveCompare($1.fileType)
                return comparison == .orderedSame
                    ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                    : comparison == .orderedAscending
            }
        }
    }
    
    @discardableResult
    func rateFile(fileURL: URL, rating: Int, musicFolderURL: URL) -> Bool {
        guard musicFolderURL.startAccessingSecurityScopedResource() else {
            presentedError = .accessDenied
            return false
        }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }

        do {
            try setAttribute(key: ratingKey, value: rating, forFileAt: fileURL)
            return true
        } catch {
            presentedError = .mutationFailed(error.localizedDescription)
            return false
        }
    }
    
    func updateFile(from oldURL: URL, to newURL: URL, newTitle: String, newArtist: String, musicFolderURL: URL) async -> Bool {
        guard musicFolderURL.startAccessingSecurityScopedResource() else {
            presentedError = .accessDenied
            return false
        }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }

        do {
            try FileMutator.update(from: oldURL, to: newURL) { updatedURL in
                try setAttribute(key: titleKey, value: newTitle, forFileAt: updatedURL)
                try setAttribute(key: artistKey, value: newArtist, forFileAt: updatedURL)
            }
            return true
        } catch let error as FileOperationError {
            presentedError = error
            return false
        } catch {
            presentedError = .mutationFailed(error.localizedDescription)
            return false
        }
    }

    func trashFile(_ item: PlaylistItem, musicFolderURL: URL) -> Bool {
        guard musicFolderURL.startAccessingSecurityScopedResource() else {
            presentedError = .accessDenied
            return false
        }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }

        do {
            try FileManager.default.trashItem(at: item.fileURL, resultingItemURL: nil)
            requestMusicFolderScan(for: musicFolderURL)
            return true
        } catch {
            presentedError = .mutationFailed(error.localizedDescription)
            return false
        }
    }

    // MARK: - Caching Logic
    private func savePlaylistToCache(items: [PlaylistItem], fingerprint: LibraryFingerprint) {
        guard let cacheURL = self.cacheURL else { return }

        do {
            let cache = PlaylistCache(fingerprint: fingerprint, items: items)
            let data = try JSONEncoder().encode(cache)
            
            let directoryURL = cacheURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            
            try data.write(to: cacheURL)
        } catch {
            if debug { print("Error saving cache: \(error.localizedDescription)") }
        }
    }
    
    deinit {
        scanTask?.cancel()
        if let observer = configChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
