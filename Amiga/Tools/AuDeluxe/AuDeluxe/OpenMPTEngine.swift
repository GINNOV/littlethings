//
//  OpenMPTEngine.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/15/25.
//

import Foundation
import AVFoundation

// This actor safely encapsulates all direct interactions with the libopenmpt C library.
// It ensures that all calls to the module are serialized and thread-safe, preventing crashes.
private actor ModuleActor {
    var module: OpaquePointer?
    private var patternCache: [Int32: [PatternRow]] = [:]
    private var debug = false

    func setDebug(_ enabled: Bool) {
        self.debug = enabled
    }

    func create(from data: Data) -> (module: OpaquePointer?, channels: Int32, duration: Double) {
        let modulePtr = data.withUnsafeBytes { openmpt_module_create_from_memory2($0.baseAddress, $0.count, nil, nil, nil, nil, nil, nil, nil) }
        guard let newModule = modulePtr else { return (nil, 0, 0) }
        
        self.module = newModule
        openmpt_module_set_render_param(newModule, OPENMPT_MODULE_RENDER_STEREOSEPARATION_PERCENT, 100)
        openmpt_module_set_render_param(newModule, OPENMPT_MODULE_RENDER_INTERPOLATIONFILTER_LENGTH, 8)
        
        let channels = openmpt_module_get_num_channels(newModule)
        let duration = openmpt_module_get_duration_seconds(newModule)
        
        return (newModule, channels, duration)
    }

    func destroy() {
        if let mod = module {
            openmpt_module_destroy(mod)
            module = nil
        }
        patternCache.removeAll()
    }

    func setRepeat(count: Int32) {
        guard let mod = module else { return }
        openmpt_module_set_repeat_count(mod, count)
    }

    func setPosition(seconds: Double) {
        guard let mod = module else { return }
        openmpt_module_set_position_seconds(mod, seconds)
    }

    func getPlaybackState() -> (pattern: Int32, row: Int32, time: Double, numRows: Int32) {
        guard let mod = module else { return (-1, -1, 0, 0) }
        let pattern = openmpt_module_get_current_pattern(mod)
        let row = openmpt_module_get_current_row(mod)
        let time = openmpt_module_get_position_seconds(mod)
        let numRows = openmpt_module_get_pattern_num_rows(mod, pattern)
        return (pattern, row, time, numRows)
    }

    func getNumPatterns() -> Int32 {
        guard let mod = module else { return 0 }
        return openmpt_module_get_num_patterns(mod)
    }

    func getPatternNumRows(_ pattern: Int32) -> Int32 {
        guard let mod = module else { return 0 }
        return openmpt_module_get_pattern_num_rows(mod, pattern)
    }

    func formatRow(pattern: Int32, row: Int32, numChannels: Int32) -> [PatternCell] {
        if debug { print("Formatting row \(row) in pattern \(pattern)") }
        guard let mod = module else { return [] }
        var rowCells: [PatternCell] = []
        rowCells.append(PatternCell(text: String(format: "%02X", row), type: .rowNumber, position: 0))
        for channel in 0..<numChannels {
            let notePtr = openmpt_module_format_pattern_row_channel_command(mod, pattern, row, channel, OPENMPT_MODULE_COMMAND_NOTE)
            let instPtr = openmpt_module_format_pattern_row_channel_command(mod, pattern, row, channel, OPENMPT_MODULE_COMMAND_INSTRUMENT)
            let volPtr = openmpt_module_format_pattern_row_channel_command(mod, pattern, row, channel, OPENMPT_MODULE_COMMAND_VOLUMEEFFECT)
            let effPtr = openmpt_module_format_pattern_row_channel_command(mod, pattern, row, channel, OPENMPT_MODULE_COMMAND_EFFECT)
            let effParamPtr = openmpt_module_format_pattern_row_channel_command(mod, pattern, row, channel, OPENMPT_MODULE_COMMAND_PARAMETER)
            
            let note = notePtr != nil ? String(cString: notePtr!) : ""
            let inst = instPtr != nil ? String(cString: instPtr!) : ""
            let vol = volPtr != nil ? String(cString: volPtr!) : ""
            let eff = effPtr != nil ? String(cString: effPtr!) : ""
            let effParam = effParamPtr != nil ? String(cString: effParamPtr!) : ""
            
            if let notePtr = notePtr { openmpt_free_string(notePtr) }
            if let instPtr = instPtr { openmpt_free_string(instPtr) }
            if let volPtr = volPtr { openmpt_free_string(volPtr) }
            if let effPtr = effPtr { openmpt_free_string(effPtr) }
            if let effParamPtr = effParamPtr { openmpt_free_string(effParamPtr) }
            
            let basePosition = 1 + Int(channel) * 5
            rowCells.append(contentsOf: [
                PatternCell(text: note, type: .note, position: basePosition),
                PatternCell(text: inst, type: .instrument, position: basePosition + 1),
                PatternCell(text: vol, type: .volume, position: basePosition + 2),
                PatternCell(text: eff, type: .effect, position: basePosition + 3),
                PatternCell(text: effParam, type: .effectParam, position: basePosition + 4)
            ])
        }
        return rowCells
    }
    
    func getFormattedPattern(pattern: Int32, numRows: Int32, numChannels: Int32) -> [PatternRow] {
        let startTime = Date()
        if let cached = patternCache[pattern] {
            if debug { print("Pattern \(pattern) fetched from cache in \(Date().timeIntervalSince(startTime)) seconds") }
            return cached
        }
        
        if debug { print("Formatting pattern \(pattern) with \(numRows) rows") }
        var rows: [PatternRow] = []
        for r in 0..<numRows {
            let rowCells = formatRow(pattern: pattern, row: r, numChannels: numChannels)
            rows.append(PatternRow(rowNumber: Int(r), cells: rowCells))
        }
        
        patternCache[pattern] = rows
        if debug { print("Pattern \(pattern) formatted and cached in \(Date().timeIntervalSince(startTime)) seconds") }
        return rows
    }

    func render(format: AVAudioFormat, frameCount: Int) -> AVAudioPCMBuffer? {
        if debug { print("Rendering audio buffer with \(frameCount) frames") }
        guard let mod = module else { return nil }
        
        let channelCount = Int(format.channelCount)
        let sampleRate = Int32(format.sampleRate)
        let bufferSize = frameCount * channelCount * MemoryLayout<Float>.size
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: MemoryLayout<Float>.alignment)
        defer { buffer.deallocate() }

        let framesRendered = Int(openmpt_module_read_interleaved_float_stereo(mod, sampleRate, frameCount, buffer.assumingMemoryBound(to: Float.self)))

        guard framesRendered > 0, let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(framesRendered)) else {
            if debug { print("Failed to render buffer or framesRendered <= 0") }
            return nil
        }
        
        if let channelData = pcmBuffer.floatChannelData {
            let floatPtr = buffer.assumingMemoryBound(to: Float.self)
            for frame in 0..<framesRendered {
                for channel in 0..<channelCount {
                    channelData[channel][frame] = floatPtr[frame * channelCount + channel]
                }
            }
        }
        pcmBuffer.frameLength = AVAudioFrameCount(framesRendered)
        if debug { print("Buffer rendered with \(framesRendered) frames") }
        return pcmBuffer
    }
}

// The engine is no longer a MainActor itself. It manages its own threading internally.
final class OpenMPTEngine: ObservableObject, Sendable {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var currentSongInfo: String?
    @Published var songDetails: String?
    @Published var playlistItems: [PlaylistItem] = []
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var currentSongDuration: TimeInterval = 0
    @Published var isLooping = false
    
    @Published var sortOrder: SortOrder = .name {
        didSet { Task { await applySort() } }
    }
    
    // MARK: - Tracker Data Properties
    @Published var visiblePatternRows: [PatternRow] = []
    @Published var currentRow: Int32 = -1
    @Published var currentPattern: Int32 = -1
    @Published var numChannels: Int32 = 0

    // MARK: - Private Properties
    private let debug = false
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var processingFormat: AVAudioFormat!
    private var currentlyAccessedURL: URL?
    private var timeUpdateTask: Task<Void, Never>?
    
    private let moduleActor = ModuleActor()
    private let uiModuleActor = ModuleActor()
    
    private let visibleWindowSize = 51
    private var halfWindowSize: Int { visibleWindowSize / 2 }
    
    private let supportedExtensions = [
        "mod", "s3m", "xm", "it", "med", "okt", "mtm", "669", "dsm", "far", "ptm", "ult",
        "amf", "ams", "dbm", "dmf", "imf", "j2b", "mdl", "mo3", "psm", "stm", "stx", "umx"
    ]
    private let ratingKey = "com.audeluxe.rating"
    private let titleKey = "com.audeluxe.title"
    private let artistKey = "com.audeluxe.artist"
    private var pendingBufferCount = 0
    private var reachedEndOfFile = false
    private let targetPendingBuffers = 3

    // MARK: - Initialization & Setup
    init() {
        // This is a non-main actor, so we must dispatch to the main actor to set up the audio engine.
        Task {
            await moduleActor.setDebug(debug)
            await uiModuleActor.setDebug(debug)
            
            await MainActor.run {
                setupAudioEngine()
            }
        }
        if debug { print("OpenMPTEngine: initialized and ready.") }
    }

    @MainActor
    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        self.processingFormat = playerNode.outputFormat(forBus: 0)
        NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            Task {
                let wasPlaying = self.isPlaying
                let currentFile = self.currentSongInfo
                let currentFolder = self.currentlyAccessedURL?.deletingLastPathComponent()
                await self.stop()
                if wasPlaying, let fileName = currentFile, let folderURL = currentFolder {
                    let fileURL = folderURL.appendingPathComponent(fileName)
                    await self.play(fileURL: fileURL, musicFolderURL: folderURL)
                }
            }
        }
    }

    // MARK: - Public Control Methods
    func scanMusicFolder(for musicFolderURL: URL) async {
        guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }
        
        var items: [PlaylistItem] = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: musicFolderURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                if isPlayable(fileURL: fileURL), let metadata = getMetadata(for: fileURL) {
                    items.append(metadata)
                }
            }
        } catch {
            if debug { print("OpenMPTEngine: Error scanning music folder: \(error.localizedDescription)") }
        }
        
        await MainActor.run {
            self.playlistItems = items
        }
        await applySort()
        if debug { print("OpenMPTEngine: Found \(items.count) playable files.") }
    }

    func play(fileURL: URL, musicFolderURL: URL) async {
        if isPlaying { await stop() }
        
        await MainActor.run {
            self.visiblePatternRows = []
        }

        guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
        self.currentlyAccessedURL = musicFolderURL
        guard let data = try? Data(contentsOf: fileURL) else { await stop(); return }
        
        let result = await moduleActor.create(from: data)
        guard result.module != nil else { await stop(); return }
        
        let uiResult = await uiModuleActor.create(from: data)
        guard uiResult.module != nil else { await stop(); return }
        
        let _isLooping = self.isLooping // Read before async call
        await moduleActor.setRepeat(count: _isLooping ? -1 : 0)
        await uiModuleActor.setRepeat(count: _isLooping ? -1 : 0)

        // Dispatch UI updates to the main actor
        await MainActor.run {
            self.numChannels = result.channels
            self.currentSongDuration = result.duration
            if let item = self.playlistItems.first(where: { $0.fileURL == fileURL }) {
                let type = item.metadata["type_long"] ?? "", tracker = item.metadata["tracker"] ?? "", date = item.metadata["date"] ?? "", container = item.metadata["container_long"] ?? ""
                var details: [String] = []
                if !type.isEmpty { details.append("Type: \(type)") }
                if !tracker.isEmpty { details.append("Tracker: \(tracker)") }
                if !date.isEmpty { details.append("Date: \(date)") }
                if !container.isEmpty { details.append("Container: \(container)") }
                self.songDetails = details.joined(separator: " | ")
            }
        }

        let numPatterns = await uiModuleActor.getNumPatterns()
        if debug { print("Starting background caching for \(numPatterns) patterns") }
        Task.detached(priority: .background) {
            let cachingStart = Date()
            for p in 0..<numPatterns {
                let nr = await self.uiModuleActor.getPatternNumRows(p)
                _ = await self.uiModuleActor.getFormattedPattern(pattern: p, numRows: nr, numChannels: result.channels)
            }
            if self.debug { print("Background caching completed in \(Date().timeIntervalSince(cachingStart)) seconds") }
        }
        
        do {
            try await MainActor.run {
                try audioEngine.start()
                playerNode.play()
            }
            
            pendingBufferCount = 0
            reachedEndOfFile = false
            for _ in 0..<targetPendingBuffers { await scheduleNextBuffer() }
            
            await MainActor.run {
                self.isPlaying = true
                self.currentSongInfo = fileURL.lastPathComponent
            }
            startTimeUpdateTimer()
        } catch {
            if debug { print("OpenMPTEngine: ERROR - Could not start AVAudioEngine: \(error.localizedDescription)") }
            await stop()
        }
    }

    func stop() async {
        guard isPlaying else {
             if let url = currentlyAccessedURL {
                url.stopAccessingSecurityScopedResource()
                currentlyAccessedURL = nil
            }
            return
        }
        timeUpdateTask?.cancel()
        timeUpdateTask = nil
        
        await MainActor.run {
            playerNode.stop()
            audioEngine.pause()
        }
        
        await moduleActor.destroy()
        await uiModuleActor.destroy()
        
        await MainActor.run {
            isPlaying = false
            currentSongInfo = nil
            songDetails = nil
            pendingBufferCount = 0
            reachedEndOfFile = false
            currentPlaybackTime = 0
            currentSongDuration = 0
            currentRow = -1
            currentPattern = -1
            numChannels = 0
        }
        
        if let url = currentlyAccessedURL {
            url.stopAccessingSecurityScopedResource()
            currentlyAccessedURL = nil
        }
    }

    func toggleLooping() async {
        let newLoopingState = !self.isLooping
        await MainActor.run {
            self.isLooping = newLoopingState
        }
        if isPlaying {
            await moduleActor.setRepeat(count: newLoopingState ? -1 : 0)
            await uiModuleActor.setRepeat(count: newLoopingState ? -1 : 0)
        }
    }
    
    func seek(to time: TimeInterval) async {
        var effectiveTime = time
        if self.isLooping && self.currentSongDuration > 0 {
            effectiveTime = time.truncatingRemainder(dividingBy: self.currentSongDuration)
        }
        await moduleActor.setPosition(seconds: effectiveTime)
        await uiModuleActor.setPosition(seconds: effectiveTime)
    }
    
    // MARK: - Tracker Data Methods
    private func currentPlayedTime() async -> Double {
        await MainActor.run {
            guard let nodeTime = self.playerNode.lastRenderTime,
                  let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) else {
                if debug { print("Fallback to currentPlaybackTime: \(self.currentPlaybackTime)") }
                return self.currentPlaybackTime // fallback
            }
            let time = Double(playerTime.sampleTime) / playerTime.sampleRate
            if debug { print("Current played time: \(time)") }
            return time
        }
    }
    
    private func updateVisibleRows() async {
        let startTime = Date()
        if debug { print("Starting updateVisibleRows") }
        let playTime = await self.currentPlayedTime()
        var effectiveTime = playTime
        if self.isLooping && self.currentSongDuration > 0 {
            effectiveTime = playTime.truncatingRemainder(dividingBy: self.currentSongDuration)
        }
        if debug { print("Setting position to \(effectiveTime)") }
        await self.uiModuleActor.setPosition(seconds: effectiveTime)
        let state = await self.uiModuleActor.getPlaybackState()
        if debug { print("Playback state: pattern \(state.pattern), row \(state.row), time \(state.time), numRows \(state.numRows)") }
        
        // Ensure we have rows to process
        guard state.numRows > 0 else {
            await MainActor.run { self.visiblePatternRows = [] }
            return
        }

        let allRows = await self.uiModuleActor.getFormattedPattern(pattern: state.pattern, numRows: state.numRows, numChannels: self.numChannels)
        
        // Your correct slicing logic
        let first = max(0, Int(state.row) - halfWindowSize)
        let last = min(Int(state.numRows) - 1, first + visibleWindowSize - 1)
        
        let slice = Array(allRows[first...last])

        // Dispatch all UI updates together
        await MainActor.run {
            self.currentRow = state.row
            self.currentPlaybackTime = playTime
            if state.pattern != self.currentPattern {
                if debug { print("Pattern changed from \(self.currentPattern) to \(state.pattern)") }
                self.currentPattern = state.pattern
            }
            self.visiblePatternRows = slice
            if debug { print("Updating visiblePatternRows with \(slice.count) rows") }
        }
        if debug { print("updateVisibleRows completed in \(Date().timeIntervalSince(startTime)) seconds") }
    }

    private func startTimeUpdateTimer() {
        timeUpdateTask = Task(priority: .userInitiated) {
            if debug { print("Starting time update timer") }
            var lastPattern: Int32 = -1
            var lastRow: Int32 = -1
            while !Task.isCancelled {
                let playTime = await self.currentPlayedTime()
                var effectiveTime = playTime
                if self.isLooping && self.currentSongDuration > 0 {
                    effectiveTime = playTime.truncatingRemainder(dividingBy: self.currentSongDuration)
                }
                await self.uiModuleActor.setPosition(seconds: effectiveTime)
                let state = await self.uiModuleActor.getPlaybackState()
                if state.pattern != lastPattern || state.row != lastRow {
                    if debug { print("State changed: pattern \(state.pattern) (\(lastPattern)), row \(state.row) (\(lastRow)) - updating rows") }
                    await self.updateVisibleRows()
                    lastPattern = state.pattern
                    lastRow = state.row
                } else {
                    await MainActor.run {
                        self.currentPlaybackTime = playTime
                    }
                }
                try? await Task.sleep(for: .milliseconds(50))
            }
            if debug { print("Time update timer cancelled") }
        }
    }
    
    private func renderBuffer() async -> AVAudioPCMBuffer? {
        // Since this is called from the audio thread's callback, we ensure it's detached.
        return await Task.detached(priority: .high) {
            await self.moduleActor.render(format: self.processingFormat, frameCount: 4096)
        }.value
    }
    
    @MainActor
    private func scheduleNextBuffer() async {
        if debug { print("Scheduling next buffer. Pending: \(pendingBufferCount), EOF: \(reachedEndOfFile)") }
        guard !reachedEndOfFile, pendingBufferCount < targetPendingBuffers else {
            if !reachedEndOfFile { await checkForPlaybackCompletion() }
            return
        }
        
        guard let buffer = await renderBuffer() else {
            if debug { print("Render buffer returned nil - setting EOF") }
            reachedEndOfFile = true
            await checkForPlaybackCompletion()
            return
        }

        pendingBufferCount += 1
        if debug { print("Buffer scheduled. New pending: \(pendingBufferCount)") }
        playerNode.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            Task {
                guard let self else { return }
                self.pendingBufferCount -= 1
                if self.debug { print("Buffer completed. New pending: \(self.pendingBufferCount)") }
                await self.scheduleNextBuffer()
            }
        }
    }
    
    @MainActor
    private func checkForPlaybackCompletion() async {
        if debug { print("Checking playback completion. EOF: \(reachedEndOfFile), Pending: \(pendingBufferCount)") }
        if reachedEndOfFile && pendingBufferCount == 0 { await stop() }
    }

    // MARK: - Other Private Helpers
    private func applySort() async {
        var sortedItems = await MainActor.run { self.playlistItems }
        switch sortOrder {
        case .name: sortedItems.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .duration: sortedItems.sort { $0.duration < $1.duration }
        case .rating: sortedItems.sort { $0.rating > $1.rating }
        }
        await MainActor.run {
            self.playlistItems = sortedItems
        }
    }

    private func isPlayable(fileURL: URL) -> Bool {
        supportedExtensions.contains(fileURL.pathExtension.lowercased())
    }
    
    private func getMetadata(for fileURL: URL) -> PlaylistItem? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let modulePtr = data.withUnsafeBytes { openmpt_module_create_from_memory2($0.baseAddress, $0.count, nil, nil, nil, nil, nil, nil, nil) }
        guard let mod = modulePtr else { return nil }
        defer { openmpt_module_destroy(mod) }
        var metadataDict: [String: String] = [:]
        if let keysCString = openmpt_module_get_metadata_keys(mod) {
            let keysString = String(cString: keysCString)
            let keys = keysString.components(separatedBy: ";")
            openmpt_free_string(keysCString)
            for key in keys {
                if let valueCString = openmpt_module_get_metadata(mod, key) {
                    metadataDict[key] = String(cString: valueCString)
                    openmpt_free_string(valueCString)
                }
            }
        }
        metadataDict["duration"] = "\(openmpt_module_get_duration_seconds(mod))"
        if let customTitle = getStringAttribute(key: titleKey, forFileAt: fileURL) {
            metadataDict["title"] = customTitle
        } else if metadataDict["title"] == nil || metadataDict["title"]!.isEmpty {
            metadataDict["title"] = fileURL.deletingPathExtension().lastPathComponent
        }
        if let customArtist = getStringAttribute(key: artistKey, forFileAt: fileURL) {
            metadataDict["artist"] = customArtist
        }
        let rating = getIntAttribute(key: ratingKey, forFileAt: fileURL)
        return PlaylistItem(fileURL: fileURL, metadata: metadataDict, rating: rating)
    }
    
    private func setAttribute(key: String, value: Any, forFileAt fileURL: URL, in musicFolderURL: URL) {
        guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }
        
        let data: Data?
        if let intValue = value as? Int {
            var val = intValue
            data = Data(bytes: &val, count: MemoryLayout<Int>.size)
        } else if let stringValue = value as? String {
            data = stringValue.data(using: .utf8)
        } else {
            return
        }
        
        guard let attrData = data else { return }
        
        let result = fileURL.path.withCString { cPath in
            key.withCString { cKey in
                attrData.withUnsafeBytes { valuePtr in
                    setxattr(cPath, cKey, valuePtr.baseAddress, valuePtr.count, 0, 0)
                }
            }
        }
        if result == -1 {
            if debug { print("Failed to set attribute '\(key)' for \(fileURL.lastPathComponent): \(String(cString: strerror(errno)))") }
        }
    }
    
    private func getAttribute(key: String, forFileAt fileURL: URL) -> Data? {
        fileURL.path.withCString { cPath in
            key.withCString { cKey in
                let size = getxattr(cPath, cKey, nil, 0, 0, 0)
                guard size > 0 else { return nil }
                var data = Data(count: size)
                let readBytes = data.withUnsafeMutableBytes { getxattr(cPath, cKey, $0.baseAddress, size, 0, 0) }
                return readBytes > 0 ? data : nil
            }
        }
    }
    
    private func getStringAttribute(key: String, forFileAt fileURL: URL) -> String? {
        guard let data = getAttribute(key: key, forFileAt: fileURL) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func getIntAttribute(key: String, forFileAt fileURL: URL) -> Int {
        guard let data = getAttribute(key: key, forFileAt: fileURL), data.count == MemoryLayout<Int>.size else { return 0 }
        return data.withUnsafeBytes { $0.load(as: Int.self) }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let url = currentlyAccessedURL { url.stopAccessingSecurityScopedResource() }
        Task {
            await moduleActor.destroy()
            await uiModuleActor.destroy()
        }
    }
}
