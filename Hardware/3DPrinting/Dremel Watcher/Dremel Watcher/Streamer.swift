//
//  Streamer.swift
//  Dremel Watcher
//
//  Created by Mario Esposito on 12/31/24.
//

import Foundation
import SwiftUI

// MJPEG Stream Handler
class MJPEGStreamHandler: NSObject, URLSessionDataDelegate, ObservableObject {
    @Published var currentImage: UIImage?
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var buffer = Data()
    
    func startStream(urlString: String) {
        stopStream() // Clean up any existing stream
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = session
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let task = session.dataTask(with: request)
        self.task = task
        task.resume()
    }
    
    func stopStream() {
        task?.cancel()
        task = nil
        session = nil
        buffer.removeAll()
    }
    
    // Handle incoming stream data
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        processBuffer()
    }
    
    private func processBuffer() {
        guard buffer.count > 2 else { return }
        
        let startMarker = Data([0xFF, 0xD8])
        let endMarker = Data([0xFF, 0xD9])
        
        // Safety check for buffer size
        if buffer.count > 1024 * 1024 * 10 { // 10MB limit
            buffer.removeAll()
            return
        }
        
        // Process all complete frames in buffer
        var searchRange = buffer.startIndex..<buffer.endIndex
        
        while searchRange.count > 2 {
            guard let startRange = buffer.range(of: startMarker, options: [], in: searchRange),
                  let endRange = buffer.range(of: endMarker, options: [], in: startRange.upperBound..<buffer.endIndex) else {
                break
            }
            
            let frameEndIndex = endRange.upperBound
            let imageData = buffer[startRange.lowerBound..<frameEndIndex]
            
            if let image = UIImage(data: Data(imageData)) {
                DispatchQueue.main.async {
                    self.currentImage = image
                }
            }
            
            // Update search range for next iteration
            searchRange = frameEndIndex..<buffer.endIndex
        }
        
        // Keep only unprocessed data
        if searchRange.lowerBound > buffer.startIndex {
            buffer.removeSubrange(buffer.startIndex..<searchRange.lowerBound)
        }
    }
}
