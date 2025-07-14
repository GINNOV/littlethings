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
    @Published var songDetails: String? // New property for technical details
    
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
    
    // A list of common Amiga module extensions for filtering.
    private let supportedExtensions = ["mod", "s3m", "xm", "it", "med", "okt", "tfmx", "ahx"]

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

    func initializeUade(romsURL: URL) {
        guard !isUadeInitialized else { return }
        guard romsURL.startAccessingSecurityScopedResource() else { return }
        defer { romsURL.stopAccessingSecurityScopedResource() }

        print("UADEEngine: Initializing UADE with ROMs at \(romsURL.path)...")
        
        guard let uadecorePath = Bundle.main.path(forResource: "uadecore", ofType: nil),
              let uaercPath = Bundle.main.path(forResource: "uaerc", ofType: nil) else {
            print("UADEEngine: FATAL - Core component not found in app bundle.")
            return
        }
        
        let config = uade_new_config()
        uade_config_set_option(config, UC_BASE_DIR, romsURL.path)
        uade_config_set_option(config, UC_UADECORE_FILE, uadecorePath)
        uade_config_set_option(config, UC_UAE_CONFIG_FILE, uaercPath)
        uade_config_set_option(config, UC_FREQUENCY, "44100")
        uade_config_set_option(config, UC_VERBOSE, "1")
        
        self.uadeState = uade_new_state(config)
        free(config)
        
        if self.uadeState != nil {
            isUadeInitialized = true
            print("UADEEngine: UADE initialized successfully.")
        } else {
            print("UADEEngine: ERROR - uade_new_state failed to initialize.")
        }
    }

    /// Checks if a file is likely playable by checking its extension.
    func isPlayable(fileURL: URL) -> Bool {
        let fileExtension = fileURL.pathExtension.lowercased()
        return supportedExtensions.contains(fileExtension)
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
            logLastUadeError() // Log the specific reason for failure
            return
        }

        // Get and display song details on successful play
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
        songDetails = nil // Clear details on stop
    }
    
    // MARK: - Private Helper Methods
    
    /// Reads and prints detailed error notifications from the UADE library.
    private func logLastUadeError() {
        guard let state = uadeState else { return }
        var notification = uade_notification()
        
        // Read all available notifications from the queue
        while uade_read_notification(&notification, state) == 1 {
            if notification.type == UADE_NOTIFICATION_SONG_END {
                if let reason = notification.song_end.reason {
                    let reasonString = String(cString: reason)
                    print("UADE Playback Failure Reason: \(reasonString)")
                }
            }
            // IMPORTANT: We must clean up each notification to prevent memory leaks.
            uade_cleanup_notification(&notification)
        }
    }
    
    /// Retrieves song info from UADE and updates the published property.
    private func updateSongDetails() {
        guard let state = uadeState, let infoPtr = uade_get_song_info(state) else {
            self.songDetails = "No song info available."
            return
        }
        
        // Safely convert C strings from the struct to Swift Strings
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
    
    /// A helper function to convert a C-style char tuple (fixed-size array) to a Swift String.
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
    
    deinit {
        if let state = uadeState {
            print("UADEEngine: Cleaning up UADE state.")
            uade_cleanup_state(state)
        }
    }
}
