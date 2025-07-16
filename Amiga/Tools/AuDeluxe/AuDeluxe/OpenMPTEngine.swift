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

    // MARK: - Audio Engine Properties
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    // Use computed property to get the actual format being used after connection.
    private var audioFormat: AVAudioFormat {
        return playerNode.outputFormat(forBus: 0)
    }

    // MARK: - OpenMPT State
    private var module: OpaquePointer?
    private var playbackTask: Task<Void, Error>?
    private var currentlyAccessedURL: URL?

    private let supportedExtensions = [
        "mod", "s3m", "xm", "it", "med", "okt", "mtm", "669", "dsm", "far", "ptm", "ult",
        "amf", "ams", "dbm", "dmf", "imf", "j2b", "mdl", "mo3", "psm", "stm", "stx", "umx"
    ]

    // MARK: - Initialization
    init() {
        setupAudioEngine()
        print("OpenMPTEngine: AVAudioEngine initialized and ready.")
    }

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)

        let actualFormat = playerNode.outputFormat(forBus: 0)
        print("OpenMPTEngine: Using audio format - Sample Rate: \(actualFormat.sampleRate), Channels: \(actualFormat.channelCount), Interleaved: \(actualFormat.isInterleaved)")

        NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: nil,
            queue: .main) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            print("OpenMPTEngine: Audio engine configuration changed. Attempting to restart.")
            Task { @MainActor in
                await self.handleAudioEngineConfigurationChange()
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
    func isPlayable(fileURL: URL) -> Bool {
        let fileExtension = fileURL.pathExtension.lowercased()
        return supportedExtensions.contains(fileExtension)
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

        let modulePtr = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> OpaquePointer? in
            return openmpt_module_create_from_memory2(pointer.baseAddress, pointer.count, nil, nil, nil, nil, nil, nil, nil)
        }

        guard let newModule = modulePtr else {
            print("OpenMPTEngine: ERROR - libopenmpt could not create module from file.")
            stop()
            return
        }

        openmpt_module_set_log_func(newModule, { (message, _) in
            if let msg = message {
                print("OpenMPT_Log: \(String(cString: msg))")
            }
        }, nil)

        let duration = openmpt_module_get_duration_seconds(newModule)
        let numOrders = openmpt_module_get_num_orders(newModule)
        print("OpenMPTEngine_Debug: Module duration is \(duration) seconds, orders: \(numOrders)")

        self.module = newModule
        updateSongDetails()

        do {
            try audioEngine.start()
            
            // Pre-buffer to prevent starvation
            print("OpenMPTEngine: Pre-buffering audio...")
            var initialBufferCount = 0
            for _ in 0..<3 {
                if renderAndScheduleOneBuffer() {
                    initialBufferCount += 1
                } else {
                    break // Song is shorter than 3 buffers
                }
            }
            print("OpenMPTEngine: Pre-buffered \(initialBufferCount) chunks.")
            
            playerNode.play()
            isPlaying = true
            currentSongInfo = fileURL.lastPathComponent
            startPlaybackLoop()
        } catch {
            print("OpenMPTEngine: ERROR - Could not start AVAudioEngine: \(error.localizedDescription)")
            openmpt_module_destroy(self.module)
            self.module = nil
            stop()
        }
    }

    func stop() {
        guard currentlyAccessedURL != nil || isPlaying else { return }

        print("OpenMPTEngine: Stopping playback.")

        playbackTask?.cancel()
        playbackTask = nil

        if isPlaying {
            playerNode.stop()
            audioEngine.pause()
        }

        if let mod = module {
            openmpt_module_destroy(mod)
            module = nil
        }

        isPlaying = false
        currentSongInfo = nil
        songDetails = nil

        if let url = currentlyAccessedURL {
            url.stopAccessingSecurityScopedResource()
            print("OpenMPTEngine_Debug: Stopped security access for music folder.")
            currentlyAccessedURL = nil
        }
    }

    // MARK: - Private Helper Methods
    private func updateSongDetails() {
        guard let mod = module else {
            self.songDetails = "No song info available."
            return
        }

        let title = String(cString: openmpt_module_get_metadata(mod, "title"))
        let artist = String(cString: openmpt_module_get_metadata(mod, "artist"))
        let type = String(cString: openmpt_module_get_metadata(mod, "type_long"))

        var details = "Type: \(type)"
        if !title.isEmpty { details += "\nTitle: \(title)" }
        if !artist.isEmpty { details += "\nArtist: \(artist)" }
        self.songDetails = details
    }
    
    /// Renders one chunk of audio and schedules it for playback. Returns false if the song has ended.
    private func renderAndScheduleOneBuffer() -> Bool {
        guard let mod = module else { return false }
        
        let format = self.audioFormat
        let frameCount: Int = 4096
        let channelCount = Int(format.channelCount)
        let sampleRate = format.sampleRate
        let bufferSize = frameCount * channelCount * MemoryLayout<Float>.size
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: MemoryLayout<Float>.alignment)
        defer { buffer.deallocate() }

        let framesRendered = Int(openmpt_module_read_interleaved_float_stereo(mod, Int32(sampleRate), frameCount, buffer.assumingMemoryBound(to: Float.self)))

        guard framesRendered > 0 else { return false }

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(framesRendered)) else {
            return false
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
        playerNode.scheduleBuffer(pcmBuffer)
        
        return true
    }

    private func startPlaybackLoop() {
        playbackTask = Task.detached(priority: .userInitiated) {
            while true {
                try Task.checkCancellation()

                let success = await MainActor.run {
                    self.renderAndScheduleOneBuffer()
                }

                if !success {
                    print("OpenMPTEngine: Song finished.")
                    break
                }
                
                // Yield to allow other tasks to run, preventing a tight loop.
                await Task.yield()
            }
            await self.stop()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVAudioEngineConfigurationChange, object: nil)
        if let url = currentlyAccessedURL {
            url.stopAccessingSecurityScopedResource()
        }
        if let mod = module {
            print("OpenMPTEngine: Cleaning up module from deinit.")
            openmpt_module_destroy(mod)
        }
    }
}
