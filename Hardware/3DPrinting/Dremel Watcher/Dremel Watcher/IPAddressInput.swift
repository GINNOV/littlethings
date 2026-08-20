//
//  IPAddressInput.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import Foundation
import SwiftUI

struct IPAddressInputView: View {
    @Binding var ipAddress: String
    @FocusState private var focusedField: Int?
    
    private var ipSegments: [String] {
        let segments = ipAddress.split(separator: ".")
        var result = ["", "", "", ""]
        for (index, segment) in segments.enumerated() where index < 4 {
            result[index] = String(segment)
        }
        return result
    }
    
    private func updateIP(segments: [String]) {
        ipAddress = segments.joined(separator: ".")
    }
    
    private func isValidSegment(_ segment: String) -> Bool {
        guard let number = Int(segment) else { return false }
        return number >= 0 && number <= 255
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<4) { index in
                TextField("", text: Binding(
                    get: { ipSegments[index] },
                    set: { newValue in
                        var segments = ipSegments
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.isEmpty || (isValidSegment(filtered) && filtered.count <= 3) {
                            segments[index] = filtered
                            updateIP(segments: segments)
                        }
                    }
                ))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: index)
                .font(.system(size: 50))
                .frame(width: 160)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
                .onChange(of: focusedField) { oldValue, newValue in
                    // Allow moving past the text field even if it's empty
                    if newValue == nil {
                        // Focus is moving away, let it happen
                        focusedField = nil
                    }
                }
                
                if index < 3 {
                    Text(".")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
