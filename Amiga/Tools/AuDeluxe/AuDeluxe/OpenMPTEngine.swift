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

    private let supportedExtensions = [
        "mod", "s3m", "xm", "it", "med", "okt", "mtm", "669", "dsm", "far", "ptm", "ult",
        "amf", "ams", "dbm", "dmf", "imf", "j2b", "mdl", "mo3", "psm", "stm", "stx", "umx"
    ]

    // MARK: - Debug Tracking
    private var cumulativeFramesRendered: Int = 0

    // MARK: - Buffer Management
    private var pendingBufferCount = 0
    private var reachedEndOfFile = false
    private let targetPendingBuffers = 3  // Keep this many ahead to avoid underruns

    // MARK: - Initialization
    init() {
        setupAudioEngine()
        print("OpenMPTEngine: AVAudioEngine initialized and ready.")
    }

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)

        let actualFormat = playerNode.outputFormat(forBus: 0)
        self.processingFormat = actualFormat
        print("OpenMPTEngine: Using audio format - Sample Rate: \(actualFormat.sampleRate), Channels: \(actualFormat.channelCount), Interleaved: \(actualFormat.isInterleaved)")

        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: nil,
            queue: .main) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.isPlaying {
                    print("OpenMPTEngine: Audio engine configuration changed. Attempting to restart.")
                    await self.handleAudioEngineConfigurationChange()
                }
            }
        }
    }

    private func handleAudioEngineConfigurationChange() async {
        let wasPlaying = isPlaying
        let currentFile = self.currentSongInfo
        let currentFolder = self.currentlyAccessedURL?.deletingLastPathComponent()

        stop() // Fully stop and release resources.

        if wasPlaying, let fileName = currentFile, let folderURL = currentFolder {
            let fileURL = folderURL.appendingPathComponent(fileName)
            print("OpenMPTEngine: Resuming playback after route change.")
            play(fileURL: fileURL, musicFolderURL: folderURL)
        }
    }

    // MARK: - Public Control Methods
    func scanMusicFolder(for musicFolderURL: URL) async {
        print("OpenMPTEngine: Scanning for music in \(musicFolderURL.path)")
        guard musicFolderURL.startAccessingSecurityScopedResource() else {
            print("OpenMPTEngine: ERROR - Could not gain security access to music folder for scanning.")
            return
        }
        defer {
            musicFolderURL.stopAccessingSecurityScopedResource()
            print("OpenMPTEngine_Debug: Stopped security access after scanning.")
        }
        
        var items: [PlaylistItem] = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: musicFolderURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                if isPlayable(fileURL: fileURL) {
                    if let metadata = getMetadata(for: fileURL) {
                        items.append(metadata)
                    }
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

        print("OpenMPTEngine: Attempting to play \(fileURL.lastPathComponent)")

        guard musicFolderURL.startAccessingSecurityScopedResource() else {
            print("OpenMPTEngine: ERROR - Could not gain security access to music folder.")
            return
        }
        self.currentlyAccessedURL = musicFolderURL
        print("OpenMPTEngine_Debug: Started security access for music folder.")

        guard let data = try? Data(contentsOf: fileURL) else {
            print("OpenMPTEngine: FATAL - Could not read file data from \(fileURL.path).")
            stop()
            return
        }

        let logClosure: @convention(c) (UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void = { message, _ in
            if let message {
                let msg = String(cString: message)
                print("OpenMPTEngine-Debug: libOpenMPT Log: \(msg)")
            }
        }

        let modulePtr = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> OpaquePointer? in
            return openmpt_module_create_from_memory2(pointer.baseAddress, pointer.count, logClosure, nil, nil, nil, nil, nil, nil)
        }

        guard let newModule = modulePtr else {
            print("OpenMPTEngine: ERROR - libopenmpt could not create module from file.")
            stop()
            return
        }

        self.module = newModule
        let durationSeconds = openmpt_module_get_duration_seconds(self.module)
        self.currentSongDuration = durationSeconds
        print("OpenMPTEngine-Debug: Module loaded. Estimated duration: \(durationSeconds) seconds.")
        updateSongDetails()

        do {
            try audioEngine.start()
            
            cumulativeFramesRendered = 0
            pendingBufferCount = 0
            reachedEndOfFile = false
            
            print("OpenMPTEngine: Pre-buffering audio...")
            for _ in 0..<targetPendingBuffers {
                scheduleNextBuffer()
            }
            
            print("OpenMPTEngine-Debug: Player presentation latency: \(playerNode.outputPresentationLatency)")
            
            playerNode.play()
            isPlaying = true
            currentSongInfo = fileURL.lastPathComponent
        } catch {
            print("OpenMPTEngine: ERROR - Could not start AVAudioEngine: \(error.localizedDescription)")
            openmpt_module_destroy(self.module)
            self.module = nil
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
        
        print("OpenMPTEngine: Stopping playback. Total cumulative frames rendered: \(cumulativeFramesRendered)")

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
            print("OpenMPTEngine_Debug: Stopped security access for music folder.")
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
        
        let title = String(cString: openmpt_module_get_metadata(mod, "title"))
        let artist = String(cString: openmpt_module_get_metadata(mod, "artist"))
        let duration = openmpt_module_get_duration_seconds(mod)

        return PlaylistItem(fileURL: fileURL,
                            title: title.isEmpty ? fileURL.deletingPathExtension().lastPathComponent : title,
                            artist: artist,
                            duration: duration)
    }
    
    private func updateSongDetails() {
        guard let mod = module else {
            self.songDetails = "No song info available."
            return
        }

        let title = String(cString: openmpt_module_get_metadata(mod, "title"))
        let artist = String(cString: openmpt_module_get_metadata(mod, "artist"))
        let type = String(cString: openmpt_module_get_metadata(mod, "type_long"))

        let tracker = String(cString: openmpt_module_get_metadata(mod, "tracker"))
        print("OpenMPTEngine-Debug: Tracker: \(tracker), Type: \(type)")

        var details = "Type: \(type)"
        if !title.isEmpty { details += "\nTitle: \(title)" }
        if !artist.isEmpty { details += "\nArtist: \(artist)" }
        self.songDetails = details
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

        guard framesRendered > 0 else {
            return nil
        }

        cumulativeFramesRendered += framesRendered

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
