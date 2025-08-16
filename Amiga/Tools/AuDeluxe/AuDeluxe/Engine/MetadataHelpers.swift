//
//  MetadataHelpers.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 8/16/25.
//

import Foundation

// AI_REVIEW: These helper functions are marked `nonisolated` so they can be called from the detached `Task`
// in `scanMusicFolder`. This is safe because they don't access any mutable state of the `OpenMPTEngine` class. #END_REVIEW
nonisolated func isPlayable(fileURL: URL, supportedExtensions: [String]) -> Bool {
    supportedExtensions.contains(fileURL.pathExtension.lowercased())
}

nonisolated func getMetadata(for fileURL: URL, ratingKey: String, titleKey: String, artistKey: String) -> PlaylistItem? {
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

nonisolated func setAttribute(key: String, value: Any, forFileAt fileURL: URL, in musicFolderURL: URL) {
    guard musicFolderURL.startAccessingSecurityScopedResource() else { return }
    defer { musicFolderURL.stopAccessingSecurityScopedResource() }
    
    let data: Data?
    if let intValue = value as? Int {
        var val = intValue
        data = Data(bytes: &val, count: MemoryLayout<Int>.size)
    } else if let stringValue = value as? String {
        data = stringValue.data(using: .utf8)
    } else { return }
    
    guard let attrData = data else { return }
    
    _ = fileURL.path.withCString { cPath in
        key.withCString { cKey in
            attrData.withUnsafeBytes { valuePtr in
                setxattr(cPath, cKey, valuePtr.baseAddress, valuePtr.count, 0, 0)
            }
        }
    }
}

nonisolated private func getAttribute(key: String, forFileAt fileURL: URL) -> Data? {
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

nonisolated private func getStringAttribute(key: String, forFileAt fileURL: URL) -> String? {
    guard let data = getAttribute(key: key, forFileAt: fileURL) else { return nil }
    return String(data: data, encoding: .utf8)
}

nonisolated private func getIntAttribute(key: String, forFileAt fileURL: URL) -> Int {
    guard let data = getAttribute(key: key, forFileAt: fileURL), data.count == MemoryLayout<Int>.size else { return 0 }
    return data.withUnsafeBytes { $0.load(as: Int.self) }
}
