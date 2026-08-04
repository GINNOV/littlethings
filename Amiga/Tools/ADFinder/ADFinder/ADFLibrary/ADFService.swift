//
//  ADFService.swift
//  ADFinder
//
//  Created by Mario Esposito on 5/25/25.
//

import Foundation
import SwiftUI

@_cdecl("swift_log_bridge")
func swift_log_bridge(msg: UnsafePointer<CChar>?) {
    guard let msg = msg else { return }
    let logMessage = String(cString: msg)
    
    Task {
        await LogStore.shared.add(message: "[ADFLib C-Log]: \(logMessage)")
    }
}


@Observable
@MainActor
class ADFService {
    nonisolated(unsafe) internal var adfDevice: UnsafeMutablePointer<AdfDevice>?
    nonisolated(unsafe) internal var adfVolume: UnsafeMutablePointer<AdfVolume>?
    private(set) var isADFlibAvailable = false
    
    var currentVolumeName: String?
    var currentPath: [String] = []
    
    var filesystemType: String = "N/A"
    var isBootable: Bool = false
    var volumeLabel: String = "N/A"
    var creationDateString: String = "N/A"
    var diskSizeString: String = "N/A"
    var usedSizeString: String = "N/A"
    var freeSizeString: String = "N/A"
    var percentFullString: String = "N/A"
    var bootBlockType: String = "N/A"
    
    
    enum ImageKind { case adf, hdf }
    @ObservationIgnored var currentImageKind: ImageKind = .adf
    
    internal let kick13BootBlock: Data = Data([
        0x44, 0x4F, 0x53, 0x00, 0xDF, 0x10, 0x1A, 0x2A, 0x00, 0x00, 0x03, 0x70, 0x43, 0xFA, 0x00, 0x18,
        0x4E, 0xAE, 0xFF, 0xA0, 0x4A, 0x80, 0x67, 0x0A, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
        0x4E, 0x75, 0x70, 0xFF, 0x60, 0xFA, 0x64, 0x6F, 0x73, 0x2E, 0x6C, 0x69, 0x62, 0x72, 0x61, 0x72,
        0x79, 0x00
    ] + Data(repeating: 0, count: 1024 - 40))
    
    internal let kick20BootBlock: Data = Data([
        0x44, 0x4F, 0x53, 0x01, 0x43, 0x1A, 0x4A, 0x2A, 0x00, 0x00, 0x03, 0x70, 0x43, 0xFA, 0x00, 0x18,
        0x4E, 0xAE, 0xFF, 0xA0, 0x4A, 0x80, 0x67, 0x0A, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
        0x4E, 0x75, 0x70, 0xFF, 0x60, 0xFA, 0x64, 0x6F, 0x73, 0x2E, 0x6C, 0x69, 0x62, 0x72, 0x61, 0x72,
        0x79, 0x00
    ] + Data(repeating: 0, count: 1024 - 40))
    
    internal let scaBootBlock: Data = Data([
        0x44, 0x4f, 0x53, 0x06, 0x57, 0x02, 0x24, 0x4a, 0x00, 0x00, 0x03, 0x70, 0x43, 0xfa, 0x00, 0x18,
        0x4e, 0xae, 0xff, 0xa0, 0x4a, 0x80, 0x67, 0x0a, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
        0x4e, 0x75, 0x70, 0xff, 0x60, 0xfa, 0x64, 0x6f, 0x73, 0x2e, 0x6c, 0x69, 0x62, 0x72, 0x61, 0x72,
        0x79, 0x00
    ] + Data(repeating: 0, count: 1024 - 40))
    
    internal let banditBootBlock: Data = Data([
        0x44, 0x4f, 0x53, 0x07, 0x82, 0x2d, 0x53, 0x7a, 0x00, 0x00, 0x03, 0x70, 0x43, 0xfa, 0x00, 0x18,
        0x4e, 0xae, 0xff, 0xa0, 0x4a, 0x80, 0x67, 0x0a, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
        0x4e, 0x75, 0x70, 0xff, 0x60, 0xfa, 0x64, 0x6f, 0x73, 0x2e, 0x6c, 0x69, 0x62, 0x72, 0x61, 0x72,
        0x79, 0x00
    ] + Data(repeating: 0, count: 1024 - 40))
    
    
    init() {
        if adf_runtime_acquire() == ADF_RC_OK {
            isADFlibAvailable = true
            log("ADFService: process-wide ADFlib runtime is available.")
        } else {
            log("ADFService: Error - Failed to acquire process-wide ADFlib runtime.")
        }
    }
    
    deinit {
        if let vol = adfVolume {
            adfVolUnMount(vol)
        }
        if let dev = adfDevice {
            adfDevUnMount(dev)
            adfDevClose(dev)
        }
    }
    
    internal func log(_ message: String) {
        Task {
            await LogStore.shared.add(message: message)
        }
    }
    
    internal func getADFLibError(context: String) -> String {
        let errorMessage = "ADFLib operation failed: \(context)."
        log(errorMessage)
        return errorMessage
    }
    
    private func resetDiskInfo() {
        filesystemType = "N/A"
        isBootable = false
        volumeLabel = "N/A"
        creationDateString = "N/A"
        diskSizeString = "N/A"
        usedSizeString = "N/A"
        freeSizeString = "N/A"
        percentFullString = "N/A"
        currentVolumeName = nil
        bootBlockType = "N/A"
    }
    
    func openADF(filePath: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        
        currentImageKind = fileURL.pathExtension.lowercased() == "hdf" ? .hdf : .adf
        closeADF()
        
        guard isADFlibAvailable else {
            log("ADFService.openADF: ABORT - ADFLib is not initialized.")
            return false
        }
        
        log("ADFService.openADF: === Starting Mount Process for: \"\(fileURL.path)\" ===")
        
        self.adfDevice = adfDevOpenWithDriver("dump", fileURL.path, AdfAccessMode(rawValue: UInt32(ACCESS_MODE_READWRITE_SWIFT)))
        
        if self.adfDevice == nil {
            log("ADFService.openADF: adfDevOpenWithDriver FAILED. Aborting without resetting shared runtime state.")
            return false
        }
        
        if adfDevMount(self.adfDevice) != ADF_RC_OK {
            log("ADFService.openADF: adfDevMount FAILED.")
            adfDevClose(self.adfDevice)
            self.adfDevice = nil
            return false
        }
        
        self.adfVolume = adfVolMount(self.adfDevice, 0, AdfAccessMode(rawValue: UInt32(ACCESS_MODE_READWRITE_SWIFT)))
        if self.adfVolume == nil {
            log("ADFService.openADF: adfVolMount FAILED.")
            adfDevUnMount(self.adfDevice)
            adfDevClose(self.adfDevice)
            self.adfDevice = nil
            return false
        }
        
        currentPath = []
        populateDiskInfo()
        
        log("ADFService.openADF: === Mount Process SUCCESS for volume: \(self.currentVolumeName ?? "N/A") ===")
        return true
    }
    
    internal func populateDiskInfo() {
        guard let vol = self.adfVolume else {
            resetDiskInfo()
            return
        }
        
        var fsTempType = ""
        if adfVolIsFFS(vol) == true {
            fsTempType = "FFS"
        } else {
            fsTempType = "OFS"
        }
        if adfVolHasINTL(vol) == true {
            fsTempType += " INTL"
        }
        if adfVolHasDIRCACHE(vol) == true {
            fsTempType += " DIRCACHE"
        }
        self.filesystemType = fsTempType.trimmingCharacters(in: .whitespaces)
        
        if let volNameCStr = vol.pointee.volName {
            self.volumeLabel = String(cString: volNameCStr)
        } else {
            self.volumeLabel = "Unnamed"
        }
        self.currentVolumeName = self.volumeLabel
        
        var bootBlock = AdfBootBlock()
        if adfReadBootBlock(vol, &bootBlock) == ADF_RC_OK {
            let dosTypeString = String(cString: [bootBlock.dosType.0, bootBlock.dosType.1, bootBlock.dosType.2].map { UInt8(bitPattern: $0) } + [0])
            isBootable = (dosTypeString == "DOS")
            
            if isBootable {
                switch bootBlock.dosType.3 {
                case 0: bootBlockType = "Kickstart 1.3 Compatible (OFS)"
                case 1: bootBlockType = "Kickstart 2.0+ Compatible (FFS)"
                case 6: bootBlockType = "SCA Virus Killer"
                case 7: bootBlockType = "Bandit Virus Killer"
                default: bootBlockType = "Custom/Unknown"
                }
            } else {
                bootBlockType = "Not Bootable"
            }
        } else {
            isBootable = false
            bootBlockType = "N/A (Read Error)"
            log("ADFService: Could not read boot block.")
        }
        
        let rootBlockSector = adfVolCalcRootBlk(vol)
        var rootBlock = AdfRootBlock()
        if adfReadRootBlock(vol, UInt32(rootBlockSector), &rootBlock) == ADF_RC_OK {
            var components = DateComponents()
            components.year = 1978
            components.month = 1
            components.day = 1
            
            if let amigaEpoch = Calendar.current.date(from: components) {
                var totalSeconds = TimeInterval(rootBlock.cDays * 24 * 60 * 60)
                totalSeconds += TimeInterval(rootBlock.cMins * 60)
                totalSeconds += TimeInterval(rootBlock.cTicks) / 50.0
                let creationDate = amigaEpoch.addingTimeInterval(totalSeconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yy HH:mm:ss"
                creationDateString = dateFormatter.string(from: creationDate)
            } else {
                creationDateString = "Date Calc Error"
            }
        } else {
            creationDateString = "N/A (RootBlock Error)"
            log("ADFService: Failed to read root block.")
        }
        
        let totalBlocks = Int64(adfVolGetSizeInBlocks(vol))
        let freeBlocks = Int64(adfCountFreeBlocks(vol))
        let usedBlocks = totalBlocks - freeBlocks
        let blockSize = Int64(vol.pointee.blockSize)
        
        if blockSize > 0 {
            let totalSizeKB = (totalBlocks * blockSize) / 1024
            let usedSizeKB = (usedBlocks * blockSize) / 1024
            let freeSizeKB = (freeBlocks * blockSize) / 1024
            
            diskSizeString = "\(totalSizeKB) KB"
            usedSizeString = "\(usedSizeKB) KB"
            freeSizeString = "\(freeSizeKB) KB"
            
            if totalBlocks > 0 {
                let percent = Double(usedBlocks) * 100.0 / Double(totalBlocks)
                percentFullString = String(format: "%.0f%%", percent)
            } else {
                percentFullString = "0%"
            }
        } else {
            diskSizeString = "N/A"; usedSizeString = "N/A"; freeSizeString = "N/A"; percentFullString = "N/A";
            log("ADFService: Invalid block size from volume.")
        }
    }
    
    
    func closeADF() {
        if let vol = self.adfVolume {
            adfVolUnMount(vol)
            self.adfVolume = nil
        }
        if let dev = self.adfDevice {
            adfDevUnMount(dev)
            adfDevClose(dev)
            self.adfDevice = nil
        }
        resetDiskInfo()
        currentPath = []
        log("ADFService: ADF closed.")
    }
}
