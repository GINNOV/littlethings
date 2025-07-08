//
//  IFFWrapper.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import Foundation
import CoreGraphics

class IFFWrapper {
    
    struct ParseResult {
        let cgImage: CGImage
        let details: IFFImageDetails
        let chunkyData: [UInt8]?
    }

    func parse(data: Data, fileURL: URL) -> ParseResult? {
        return data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> ParseResult? in
            guard let baseAddress = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return nil
            }
            
            // AI_REVIEW: The C function returns an `Unmanaged<CGImage>`. We must call `takeRetainedValue()`
            // to correctly transfer memory management to Swift's ARC, resolving the compiler error.
            guard let unmanagedImageRef = iff_createImageFromData(baseAddress, data.count, true) else {
                print("❌ [Debug] iff_createImageFromData failed for \(fileURL.lastPathComponent)")
                return nil
            }
            let imageRef = unmanagedImageRef.takeRetainedValue()
            
            var ckmap = chunkMap_t()
            if iff_mapChunks(baseAddress, data.count, &ckmap) == 0, let _ = ckmap.bmhd {
                let details = extractDetails(from: &ckmap, fileURL: fileURL)
                return ParseResult(cgImage: imageRef, details: details, chunkyData: nil)
            }
            
            return nil
        }
    }
    
    private func extractDetails(from ckmap: inout chunkMap_t, fileURL: URL) -> IFFImageDetails {
        let bmhd = ckmap.bmhd.pointee
        
        let compression: String
        switch bmhd_getCompression(ckmap.bmhd) {
        case 0: compression = "None"
        case 1: compression = "ByteRun1"
        default: compression = "Unknown"
        }
        
        let masking: String
        switch bmhd_getMasking(ckmap.bmhd) {
        case 0: masking = "None"
        case 1: masking = "Image Mask"
        case 2: masking = "Transparent Color"
        case 3: masking = "Lasso"
        default: masking = "Unknown"
        }
        
        let id = form_getType(ckmap.form).bigEndian
        let c1 = Character(UnicodeScalar((id >> 24) & 0xFF) ?? " ")
        let c2 = Character(UnicodeScalar((id >> 16) & 0xFF) ?? " ")
        let c3 = Character(UnicodeScalar((id >> 8) & 0xFF) ?? " ")
        let c4 = Character(UnicodeScalar(id & 0xFF) ?? " ")
        let formTypeString = "\(c1)\(c2)\(c3)\(c4)"
        
        return IFFImageDetails(
            fileName: fileURL.lastPathComponent,
            filePath: fileURL.path,
            width: Int(bmhd_getWidth(ckmap.bmhd)),
            height: Int(bmhd_getHeight(ckmap.bmhd)),
            depth: Int(bmhd_getDepth(ckmap.bmhd)),
            colors: ckmap.cmap != nil ? Int(header_getSize(&ckmap.cmap.pointee.header) / 3) : (1 << bmhd_getDepth(ckmap.bmhd)),
            compression: compression,
            masking: masking,
            aspectRatio: "\(bmhd.xAspect):\(bmhd.yAspect)",
            pageDimensions: "\(bmhd.pageWidth)x\(bmhd.pageHeight)",
            viewportMode: ckmap.camg != nil ? "0x" + String(format: "%08X", camg_getLace(ckmap.camg)) : nil,
            formType: formTypeString,
            hasCMAP: ckmap.cmap != nil
        )
    }
}
