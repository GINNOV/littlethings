//
//  StatusView.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import Foundation
import SwiftUI

struct StatusView: View {
    let status: PrinterStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text("Job Name: \(status.jobname)")
                Text("Status: \(status.jobstatus)")
                Text("Door Open: \(status.doorOpen == 1 ? "Yes" : "No")")
                Text("Filament: \(status.filamentType)")
            }
            .foregroundColor(.white)
            
            Divider()
                .background(Color.white)
            
            Group {
                Text("Nozzle: \(status.temperature)°/\(status.extruderTargetTemperature)°")
                Text("Build Plate: \(status.platformTemperature)°/\(status.buildPlateTargetTemperature)°")
                Text("Chamber: \(status.chamberTemperature)°")
            }
            .foregroundColor(.white)
            
            Divider()
                .background(Color.white)
            
            Group {
                Text("Elapsed: \(formatTime(status.elapsedTime))")
                Text("Remaining: \(formatTime(status.remainingTime))")
                ProgressView(value: status.progress, total: 100) {
                    Text("Progress: \(String(format: "%.1f%%", status.progress))")
                        .foregroundColor(.white)
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
