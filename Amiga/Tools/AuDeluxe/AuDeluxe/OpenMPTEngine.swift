//
//  OpenMPTEngine.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/15/25.
//

import Foundation
import AVFoundation

@MainActor
final class OpenMPTEngine: ObservableObject {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var currentSongInfo: String?
    @Published var songDetails: String?
    @Published var playlistItems: [PlaylistItem] = []
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var currentSongDuration: TimeInterval = 0
    @Published var isLooping = false

    // MARK: - Audio Engine Properties
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var processingFormat: AVAudioFormat!

    // MARK: - OpenMPT State
    private var module: OpaquePointer?
    private var currentlyAccessedURL: URL?
    private var timeUpdateTask: Task<Void, Never>?

    private let supportedExtensions = [
        "mod", "s3m", "xm", "it", "med", "okt", "mtm", "669", "dsm", "far", "ptm", "ult",
        "amf", "ams", "dbm", "dmf", "imf", "j2b", "mdl", "mo3", "psm", "stm", "stx", "umx"
    ]
    
    // Keys for our custom metadata attributes.
    private let ratingKey = "com.audeluxe.rating"
    private let titleKey = "com.audeluxe.title"
    private let artistKey = "com.audeluxe.artist"

    // MARK: - Buffer Management
    private var pendingBufferCount = 0
    private var reachedEndOfFile = false
    private let targetPendingBuffers = 3

    // MARK: - Initialization
    init() {
        setupAudioEngine()
        print("OpenMPTEngine: AVAudioEngine initialized and ready.")
    }

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        self.processingFormat = playerNode.outputFormat(forBus: 0)
        
        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange, object: nil, queue: .main) { [weak self] _ in
            guard let self, self.isPlaying else { return }
            Task { await self.handleAudioEngineConfigurationChange() }
        }
    }

    private func handleAudioEngineConfigurationChange() async {
        let wasPlaying = isPlaying
        let currentFile = self.currentSongInfo
        let currentFolder = self.currentlyAccessedURL?.deletingLastPathComponent()

        stop()

        if wasPlaying, let fileName = currentFile, let folderURL = currentFolder {
            let fileURL = folderURL.appendingPathComponent(fileName)
            play(fileURL: fileURL, musicFolderURL: folderURL)
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
            print("OpenMPTEngine: Error scanning music folder: \(error.localizedDescription)")
        }
        
        self.playlistItems = items.sorted { $0.title.lowercased() < $1.title.lowercased() }
        print("OpenMPTEngine: Found \(self.playlistItems.count) playable files.")
    }
    
    func play(fileURL: URL, musicFolderURL: URL) {
        if isPlaying { stop() }

        guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
        self.currentlyAccessedURL = musicFolderURL
        
        guard let data = try? Data(contentsOf: fileURL) else {
            stop(); return
        }

        let modulePtr = data.withUnsafeBytes { openmpt_module_create_from_memory2($0.baseAddress, $0.count, nil, nil, nil, nil, nil, nil, nil) }

        guard let newModule = modulePtr else {
            stop(); return
        }
        
        openmpt_module_set_render_param(newModule, OPENMPT_MODULE_RENDER_STEREOSEPARATION_PERCENT, 100)
        openmpt_module_set_render_param(newModule, OPENMPT_MODULE_RENDER_INTERPOLATIONFILTER_LENGTH, 8)
        
        self.module = newModule
        self.currentSongDuration = openmpt_module_get_duration_seconds(newModule)
        openmpt_module_set_repeat_count(newModule, isLooping ? -1 : 0)
        updateSongDetails()

        do {
            try audioEngine.start()
            
            pendingBufferCount = 0
            reachedEndOfFile = false
            
            for _ in 0..<targetPendingBuffers {
                scheduleNextBuffer()
            }
            
            playerNode.play()
            isPlaying = true
            currentSongInfo = fileURL.lastPathComponent
            startTimeUpdateTimer()
        } catch {
            print("OpenMPTEngine: ERROR - Could not start AVAudioEngine: \(error.localizedDescription)")
            stop()
        }
    }

    func stop() {
        guard isPlaying else {
             if let url = currentlyAccessedURL {
                url.stopAccessingSecurityScopedResource()
                currentlyAccessedURL = nil
            }
            return
        }
        
        timeUpdateTask?.cancel()
        timeUpdateTask = nil
        
        playerNode.stop()
        audioEngine.pause()

        if let mod = module {
            openmpt_module_destroy(mod)
            module = nil
        }

        isPlaying = false
        currentSongInfo = nil
        songDetails = nil
        pendingBufferCount = 0
        reachedEndOfFile = false
        currentPlaybackTime = 0
        currentSongDuration = 0

        if let url = currentlyAccessedURL {
            url.stopAccessingSecurityScopedResource()
            currentlyAccessedURL = nil
        }
    }
    
    func toggleLooping() {
        isLooping.toggle()
        if let mod = module, isPlaying {
            openmpt_module_set_repeat_count(mod, isLooping ? -1 : 0)
        }
    }
    
    func seek(to time: TimeInterval) {
        guard let mod = module else { return }
        openmpt_module_set_position_seconds(mod, time)
    }
    
    func rateFile(fileURL: URL, rating: Int, musicFolderURL: URL) {
        setAttribute(key: ratingKey, value: rating, forFileAt: fileURL, in: musicFolderURL)
    }
    
    func updateFile(from oldURL: URL, to newURL: URL, newTitle: String, newArtist: String, musicFolderURL: URL) async -> Bool {
        setAttribute(key: titleKey, value: newTitle, forFileAt: oldURL, in: musicFolderURL)
        setAttribute(key: artistKey, value: newArtist, forFileAt: oldURL, in: musicFolderURL)

        if oldURL.lastPathComponent != newURL.lastPathComponent {
            guard musicFolderURL.startAccessingSecurityScopedResource() else {
                print("Failed to gain security access to rename file.")
                return false
            }
            defer { musicFolderURL.stopAccessingSecurityScopedResource() }

            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                print("Successfully renamed file to \(newURL.lastPathComponent)")
                return true
            } catch {
                print("Error renaming file: \(error)")
                return false
            }
        }
        return true
    }

    // MARK: - Private Helper Methods
    private func isPlayable(fileURL: URL) -> Bool {
        let fileExtension = fileURL.pathExtension.lowercased()
        return supportedExtensions.contains(fileExtension)
    }
    
    private func getMetadata(for fileURL: URL) -> PlaylistItem? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        let modulePtr = data.withUnsafeBytes { openmpt_module_create_from_memory2($0.baseAddress, $0.count, nil, nil, nil, nil, nil, nil, nil) }
        
        guard let mod = modulePtr else { return nil }
        defer { openmpt_module_destroy(mod) }
        
        let internalTitle = String(cString: openmpt_module_get_metadata(mod, "title"))
        let internalArtist = String(cString: openmpt_module_get_metadata(mod, "artist"))
        let duration = openmpt_module_get_duration_seconds(mod)

        let customTitle = getStringAttribute(key: titleKey, forFileAt: fileURL)
        let customArtist = getStringAttribute(key: artistKey, forFileAt: fileURL)
        let rating = getIntAttribute(key: ratingKey, forFileAt: fileURL)

        let finalTitle = customTitle ?? (internalTitle.isEmpty ? fileURL.deletingPathExtension().lastPathComponent : internalTitle)
        let finalArtist = customArtist ?? internalArtist

        return PlaylistItem(fileURL: fileURL,
                            title: finalTitle,
                            artist: finalArtist,
                            duration: duration,
                            rating: rating)
    }
    
    // MARK: - Extended Attribute Helpers
    
    // I have corrected this function to properly handle C-String conversion for both the path and the key.
    private func setAttribute(key: String, value: String, forFileAt fileURL: URL, in musicFolderURL: URL) {
        guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }
        
        guard let data = value.data(using: .utf8) else { return }
        
        let result = fileURL.path.withCString { cPath in
            key.withCString { cKey in
                data.withUnsafeBytes { valuePtr in
                    setxattr(cPath, cKey, valuePtr.baseAddress, valuePtr.count, 0, 0)
                }
            }
        }
        if result == -1 {
            print("Failed to set attribute '\(key)' for \(fileURL.lastPathComponent): \(String(cString: strerror(errno)))")
        }
    }

    // I have also corrected this function to handle C-String conversion.
    private func setAttribute(key: String, value: Int, forFileAt fileURL: URL, in musicFolderURL: URL) {
        guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
        defer { musicFolderURL.stopAccessingSecurityScopedResource() }
        
        var value = value
        let data = Data(bytes: &value, count: MemoryLayout<Int>.size)
        
        let result = fileURL.path.withCString { cPath in
            key.withCString { cKey in
                data.withUnsafeBytes { valuePtr in
                    setxattr(cPath, cKey, valuePtr.baseAddress, valuePtr.count, 0, 0)
                }
            }
        }
        if result == -1 {
            print("Failed to set attribute '\(key)' for \(fileURL.lastPathComponent): \(String(cString: strerror(errno)))")
        }
    }
    
    private func getAttribute(key: String, forFileAt fileURL: URL) -> Data? {
        let result = fileURL.path.withCString { cPath -> Data? in
            key.withCString { cKey -> Data? in
                let size = getxattr(cPath, cKey, nil, 0, 0, 0)
                guard size > 0 else { return nil }
                
                var data = Data(count: size)
                let readBytes = data.withUnsafeMutableBytes { valuePtr -> Int in
                    getxattr(cPath, cKey, valuePtr.baseAddress, size, 0, 0)
                }
                
                guard readBytes > 0 else { return nil }
                return data
            }
        }
        return result
    }
    
    private func getStringAttribute(key: String, forFileAt fileURL: URL) -> String? {
        guard let data = getAttribute(key: key, forFileAt: fileURL) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func getIntAttribute(key: String, forFileAt fileURL: URL) -> Int {
        guard let data = getAttribute(key: key, forFileAt: fileURL), data.count == MemoryLayout<Int>.size else { return 0 }
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }
    
    private func updateSongDetails() {
        guard let mod = module else { return }
        let type = String(cString: openmpt_module_get_metadata(mod, "type_long"))
        let tracker = String(cString: openmpt_module_get_metadata(mod, "tracker"))
        self.songDetails = "Type: \(type) | Tracker: \(tracker)"
    }

    private func scheduleNextBuffer() {
        guard !reachedEndOfFile, pendingBufferCount < targetPendingBuffers else { return }

        guard let buffer = renderBuffer() else {
            reachedEndOfFile = true
            checkForPlaybackCompletion()
            return
        }

        pendingBufferCount += 1
        playerNode.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.pendingBufferCount -= 1
                self.scheduleNextBuffer()
                self.checkForPlaybackCompletion()
            }
        }
    }

    private func renderBuffer() -> AVAudioPCMBuffer? {
        guard let mod = module else { return nil }

        let frameCount: Int = 4096
        let channelCount = Int(processingFormat.channelCount)
        let sampleRate = processingFormat.sampleRate
        let bufferSize = frameCount * channelCount * MemoryLayout<Float>.size
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: MemoryLayout<Float>.alignment)
        defer { buffer.deallocate() }

        let framesRendered = Int(openmpt_module_read_interleaved_float_stereo(mod, Int32(sampleRate), frameCount, buffer.assumingMemoryBound(to: Float.self)))

        guard framesRendered > 0 else { return nil }

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(framesRendered)) else {
            return nil
        }
        
        let floatPtr = buffer.assumingMemoryBound(to: Float.self)
        if let channelData = pcmBuffer.floatChannelData {
            for frame in 0..<framesRendered {
                for channel in 0..<channelCount {
                    channelData[channel][frame] = floatPtr[frame * channelCount + channel]
                }
            }
        }
        
        pcmBuffer.frameLength = AVAudioFrameCount(framesRendered)
        return pcmBuffer
    }

    private func checkForPlaybackCompletion() {
        if reachedEndOfFile && pendingBufferCount == 0 {
            print("OpenMPTEngine: All buffers played. Song finished.")
            stop()
        }
    }
    
    private func startTimeUpdateTimer() {
        timeUpdateTask?.cancel()
        timeUpdateTask = Task {
            while !Task.isCancelled {
                if let mod = self.module {
                    self.currentPlaybackTime = openmpt_module_get_position_seconds(mod)
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let url = currentlyAccessedURL {
            url.stopAccessingSecurityScopedResource()
        }
        if let mod = module {
            openmpt_module_destroy(mod)
        }
    }
}
