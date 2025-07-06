//
//  HexdumpGenerator.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import Foundation

struct HexdumpGenerator {
    static func format(data: [UInt8]) -> String {
        var result = ""
        let bytesPerRow = 16
        
        for i in stride(from: 0, to: data.count, by: bytesPerRow) {
            let address = String(format: "%08x", i)
            result += "\(address)  "
            
            let rowData = data[i..<min(i + bytesPerRow, data.count)]
            var hexString = rowData.map { String(format: "%02x", $0) }.joined(separator: " ")
            if i + 8 < data.count {
                hexString.insert(" ", at: hexString.index(hexString.startIndex, offsetBy: 23))
            }
            result += hexString.padding(toLength: 49, withPad: " ", startingAt: 0)
            
            let asciiString = rowData.map { ($0 >= 32 && $0 <= 126) ? Character(UnicodeScalar($0)) : "." }.map(String.init).joined()
            result += " |\(asciiString)|\n"
        }
        
        return result
    }
}
