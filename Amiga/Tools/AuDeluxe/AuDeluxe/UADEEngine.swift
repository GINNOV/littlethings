//
//  UADEEngine.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/14/25.
//

import Foundation
import AVFoundation

@MainActor
final class UADEEngine: ObservableObject {

    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var currentSongInfo: String?
    @Published var songDetails: String?
    
    @Published public private(set) var isUadeInitialized = false

    // MARK: - Audio Engine Properties
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let uadeAudioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                                sampleRate: 44100,
                                                channels: 2,
                                                interleaved: true)!

    // MARK: - UADE State
    private var uadeState: OpaquePointer?
    private var playbackTask: Task<Void, Error>?

    // MARK: - Initialization
    init() {
        audioEngine.attach(playerNode)
        
        let mixer = audioEngine.mainMixerNode
        let outputFormat = mixer.outputFormat(forBus: 0)
        audioEngine.connect(playerNode, to: mixer, format: outputFormat)
        
        audioEngine.prepare()
        print("UADEEngine: AVAudioEngine initialized and ready.")
    }

    // MARK: - Public Control Methods

    func initializeUade(settings: SettingsStore) {
        if isUadeInitialized { deinitialize() }

        print("UADEEngine: Initializing UADE...")
        
        // --- 1. Verify user has selected a ROMs folder ---
        guard let romsURL = settings.romsFolderURL else {
            print("UADEEngine: FATAL - ROMs folder not set in settings.")
            return
        }
        guard romsURL.startAccessingSecurityScopedResource() else {
            print("UADEEngine: FATAL - Could not access security-scoped ROMs folder.")
            return
        }
        defer { romsURL.stopAccessingSecurityScopedResource() }
        
        // --- 2. Verify the bundled resources exist at the top level ---
        guard let resourcePath = Bundle.main.resourcePath,
              let uadecorePath = Bundle.main.path(forResource: "uadecore", ofType: nil) else {
            print("UADEEngine: FATAL - 'uadecore' not found in the main resource bundle. Make sure it's included in 'Copy Bundle Resources'.")
            return
        }
        
        // --- 3. Create a temporary uaerc file to point to the user's ROMs ---
        let tempDir = FileManager.default.temporaryDirectory
        let tempUaercURL = tempDir.appendingPathComponent("audeluxe.uaerc")
        let uaercContent = "kickstart_dir=\(romsURL.path)"
        do {
            try uaercContent.write(to: tempUaercURL, atomically: true, encoding: .utf8)
            print("UADEEngine: Wrote temporary uaerc to \(tempUaercURL.path)")
        } catch {
            print("UADEEngine: FATAL - Failed to write temporary uaerc file: \(error)")
            return
        }
        
        // --- 4. Configure and initialize UADE ---
        let config = uade_new_config()
        // The Base Directory is the main Resources folder, where uade.conf and the players folder reside.
        uade_config_set_option(config, UC_BASE_DIR, resourcePath)
        // The Core File is the uadecore executable.
        uade_config_set_option(config, UC_UADECORE_FILE, uadecorePath)
        // Point UADE to our dynamically created uaerc file, which points to the user's ROMs.
        uade_config_set_option(config, UC_UAE_CONFIG_FILE, tempUaercURL.path)
        uade_config_set_option(config, UC_FREQUENCY, "44100")
        
        // Apply audio settings from the UI
        uade_config_set_option(config, UC_FILTER_TYPE, settings.filterType.rawValue)
        uade_config_set_option(config, UC_PANNING_VALUE, String(format: "%.2f", settings.panning))
        uade_config_set_option(config, UC_GAIN, String(format: "%.2f", settings.gain))
        
        if settings.headphonesEnabled {
            uade_config_set_option(config, UC_HEADPHONES, nil)
        }
        if settings.ntscEnabled {
            uade_config_set_option(config, UC_NTSC, nil)
        }
        
        self.uadeState = uade_new_state(config)
        free(config)
        
        if self.uadeState != nil {
            isUadeInitialized = true
            print("UADEEngine: UADE initialized successfully.")
        } else {
            print("UADEEngine: ERROR - uade_new_state failed to initialize.")
        }
    }

    /// Checks if a file is playable by asking the UADE library directly.
    func isPlayable(fileURL: URL) -> Bool {
        guard isUadeInitialized, let state = uadeState else { return false }
        // Now that uade.conf is bundled, this function should work reliably.
        return uade_is_our_file(fileURL.path, state) == 1
    }

    func play(fileURL: URL) {
        guard isUadeInitialized, let state = uadeState else {
            print("UADEEngine: ERROR - UADE must be initialized before playing.")
            return
        }
        
        if isPlaying { stop() }

        print("UADEEngine: Attempting to play \(fileURL.lastPathComponent)")

        guard uade_play(fileURL.path, -1, state) == 1 else {
            print("UADEEngine: ERROR - uade_play failed for file \(fileURL.path)")
            logLastUadeError()
            return
        }

        updateSongDetails()

        do {
            try audioEngine.start()
            playerNode.play()
            isPlaying = true
            currentSongInfo = fileURL.lastPathComponent
            startPlaybackLoop(uadeState: state)
        } catch {
            print("UADEEngine: ERROR - Could not start AVAudioEngine: \(error.localizedDescription)")
        }
    }

    func stop() {
        guard isPlaying, let state = uadeState else { return }
        
        print("UADEEngine: Stopping playback.")
        
        playbackTask?.cancel()
        playbackTask = nil
        
        playerNode.stop()
        audioEngine.pause()
        
        uade_stop(state)
        
        isPlaying = false
        currentSongInfo = nil
        songDetails = nil
    }
    
    // MARK: - Private Helper Methods
    
    private func logLastUadeError() {
        guard let state = uadeState else { return }
        var notification = uade_notification()
        
        while uade_read_notification(&notification, state) == 1 {
            if notification.type == UADE_NOTIFICATION_SONG_END {
                if let reason = notification.song_end.reason {
                    let reasonString = String(cString: reason)
                    print("UADE Playback Failure Reason: \(reasonString)")
                }
            }
            uade_cleanup_notification(&notification)
        }
    }
    
    private func updateSongDetails() {
        guard let state = uadeState, let infoPtr = uade_get_song_info(state) else {
            self.songDetails = "No song info available."
            return
        }
        
        let info = infoPtr.pointee
        let formatName = stringFromCCharTuple(info.formatname)
        let playerName = stringFromCCharTuple(info.playername)
        let moduleName = stringFromCCharTuple(info.modulename)
        
        var details = "Format: \(formatName)\nPlayer: \(playerName)"
        if !moduleName.isEmpty {
            details += "\nModule: \(moduleName)"
        }
        self.songDetails = details
    }
    
    private func stringFromCCharTuple<T>(_ tuple: T) -> String {
        var aTuple = tuple
        return withUnsafePointer(to: &aTuple) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }
    
    private func startPlaybackLoop(uadeState: OpaquePointer) {
        let bufferSize = 8192
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 1)
        
        playbackTask = Task.detached(priority: .userInitiated) {
            while true {
                try Task.checkCancellation()
                let bytesRead = uade_read(buffer, bufferSize, uadeState)
                
                if bytesRead > 0 {
                    if let pcmBuffer = await self.createPCMBuffer(from: buffer, length: bytesRead) {
                        await MainActor.run { self.playerNode.scheduleBuffer(pcmBuffer) }
                    }
                } else {
                    print("UADEEngine: Song finished.")
                    break
                }
            }
            buffer.deallocate()
            await self.stop()
        }
    }
    
    private func createPCMBuffer(from data: UnsafeMutableRawPointer, length: Int) -> AVAudioPCMBuffer? {
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: self.uadeAudioFormat, frameCapacity: AVAudioFrameCount(length) / self.uadeAudioFormat.streamDescription.pointee.mBytesPerFrame) else {
            return nil
        }
        pcmBuffer.mutableAudioBufferList.pointee.mBuffers.mData?.copyMemory(from: data, byteCount: length)
        pcmBuffer.frameLength = pcmBuffer.frameCapacity
        return pcmBuffer
    }
    
    func deinitialize() {
        if let state = uadeState {
            print("UADEEngine: Deinitializing UADE state for settings change.")
            uade_cleanup_state(state)
        }
        uadeState = nil
        isUadeInitialized = false
    }
    
    deinit {
        if let state = uadeState {
            print("UADEEngine: Cleaning up UADE state from deinit.")
            uade_cleanup_state(state)
        }
    }
}
