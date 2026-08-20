//
//  Settings.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import Foundation
import SwiftUI

// Settings View
struct SettingsView: View {
    @ObservedObject var settings: StreamSettings
    
    var body: some View {
        VStack(spacing: 40) {
            Text("STREAM SETTINGS")
                .font(.system(size: 40))
            Text("Take the IP from your 3D45 touch screen panel.")
                .font(.system(size: 30))
            
            IPAddressInputView(ipAddress: $settings.ipAddress)
            
            Button("Save") {
                settings.showSettings = false
                settings.updateStreamURL()
            }
            .buttonStyle(.bordered)
            .font(.system(size: 30))
            .focusSection()
        }
        .padding(80)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(20)
    }
}

// State management
class StreamSettings: ObservableObject {
    @Published var ipAddress: String = "192.168.86.28"
    @Published var showSettings: Bool = false
    @Published var isStreaming: Bool = false
    @Published var streamURLString: String = ""
    
    func updateStreamURL() {
        if !ipAddress.isEmpty {
            streamURLString = "http://\(ipAddress):10123/?action=stream"
        }
    }
}
