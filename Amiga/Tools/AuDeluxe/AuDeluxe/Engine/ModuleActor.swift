//
//  ModuleActor.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/16/25.
//

import Foundation
import AVFoundation

// This actor safely encapsulates all direct interactions with the libopenmpt C library.
// It's marked internal so it can be accessed by OpenMPTEngine from another file.
actor ModuleActor {
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
