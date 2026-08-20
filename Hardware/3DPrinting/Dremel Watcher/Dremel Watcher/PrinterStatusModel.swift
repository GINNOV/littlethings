//
//  PrinterStatusModel.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import Foundation
import SwiftUI

class PrinterViewModel: ObservableObject {
    @Published var printerStatus: PrinterStatus?
    @Published var statusMessage: String = ""
    @Published var isCameraEnabled: Bool = false
    @StateObject private var settings = StreamSettings()
    
    private let timeout: TimeInterval = 0.5
    
    func fetchStatus(ipAddress: String) {
            guard let url = URL(string: "http://\(ipAddress)/command") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = "GETPRINTERSTATUS=".data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.statusMessage = "Error: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let data = data else {
                        self?.statusMessage = "No data received"
                        return
                    }
                    
                    // Parse response and update status
                    // Mock data for testing - replace with actual parsing
                    self?.printerStatus = PrinterStatus(
                        jobname: "Test Print",
                        jobstatus: "Printing",
                        doorOpen: 0,
                        filamentType: "PLA",
                        temperature: 200,
                        extruderTargetTemperature: 210,
                        platformTemperature: 60,
                        buildPlateTargetTemperature: 60,
                        chamberTemperature: 35,
                        elapsedTime: 1800,
                        remainingTime: 3600,
                        progress: 33.3
                    )
                }
            }.resume()
        }
    
    func pausePrint() {
        sendCommand(command: "PAUSE")
    }
    
    func resumePrint() {
        sendCommand(command: "RESUME")
    }
    
    func cancelPrint() {
        sendCommand(command: "CANCEL")
    }
    
    private func sendCommand(command: String) {
        let url = settings.streamURLString
        guard let url = URL(string: "\(url)/command") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "\(command)=".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.statusMessage = "Error: \(error.localizedDescription)"
                    return
                }
                
                self?.statusMessage = "\(command) command sent successfully"
            }
        }.resume()
    }
}

struct PrinterStatus: Codable {
    var jobname: String
    var jobstatus: String
    var doorOpen: Int
    var filamentType: String
    var temperature: Int
    var extruderTargetTemperature: Int
    var platformTemperature: Int
    var buildPlateTargetTemperature: Int
    var chamberTemperature: Int
    var elapsedTime: Int
    var remainingTime: Int
    var progress: Double
}
