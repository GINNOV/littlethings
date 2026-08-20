//
//  ContentView.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var settings = StreamSettings()
    @StateObject private var viewModel = PrinterViewModel()
    @State private var showingCancelAlert = false
    @State private var showingStatus = false
    
    private let timeout: TimeInterval = 5.0
    
    var body: some View {
        ZStack {
            // Set explicit black background for the entire view
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Main content
            if settings.isStreaming {
                MJPEGStreamView(url: settings.streamURLString)
            } else {
                Color.black
            }
            
            // Overlay controls
            VStack {
                // Top controls - only show when streaming
                if settings.isStreaming {
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            Button(action: {
                                settings.showSettings = true
                            }) {
                                Image(systemName: "gear.circle")
                                    .font(.system(size: 50))
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: {
                                viewModel.pausePrint()
                            }) {
                                Image(systemName: "pause.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: {
                                viewModel.resumePrint()
                            }) {
                                Image(systemName: "restart.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(.bordered)  // Add visible button style
                            
                            Button(action: {
                                viewModel.cancelPrint()
                            }) {
                                Image(systemName: "stop.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.bordered)  // Add visible button style
                            
                            Button(action: {
                                showingStatus = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.bordered)  // Add visible button style
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Action buttons
                    HStack(spacing: 30) {
                        if !settings.isStreaming {
                            Button("Monitor") {
                                settings.updateStreamURL()
                                settings.isStreaming = true
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: {
                                settings.showSettings = true
                            }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 30))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Printer IP display
                    HStack {
                        Text("Printer: \(settings.ipAddress)")
                            .foregroundColor(.red)
                            .font(.system(size: 24))
                        Spacer()
                    }
                    .padding(.leading, 40)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingStatus) {
            if let status = viewModel.printerStatus {
                StatusView(status: status)
            }
        }
        
        .onAppear {
            // Start status polling timer
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                viewModel.fetchStatus(ipAddress: settings.ipAddress)
            }
        }
    }
}
