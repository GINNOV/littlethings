//
//  PreviewViewController.swift
//  IFFViewer Extension
//
//  Created by Mario Esposito on 7/7/25.
//
import Cocoa
import Quartz
import SwiftUI // Make sure to import SwiftUI
import os.log // Import for unified logging

// --- DEBUGGING FLAG ---
// Set this to true to enable detailed print statements in the Xcode console.
let enableDebugSpew = false
// --------------------

// Create a logger instance for better debugging.
// You can view these logs in the Console app by filtering by subsystem.
let logger = Logger(subsystem: "com.theblifemovement.IFFViewer.IFFPreviewExtension", category: "Preview")

class PreviewViewController: NSViewController, QLPreviewingController {

    // This is the modern async/await entry point for Quick Look.
    // It replaces the older completion handler-based method.
    func preparePreviewOfFile(at url: URL) async throws {
        logger.log("Starting preview for file: \(url.path)")
        if enableDebugSpew { print("--- QL PREVIEW START --- for file: \(url.path)") }
        
        // Read the file's contents into a Data object. This can throw an error.
        let fileData: Data
        do {
            fileData = try Data(contentsOf: url)
            logger.log("Successfully read \(fileData.count) bytes from file.")
            if enableDebugSpew { print("[DEBUG] Successfully read \(fileData.count) bytes from file.") }
        } catch {
            logger.error("Failed to read file data: \(error.localizedDescription)")
            if enableDebugSpew { print("[ERROR] Failed to read file data: \(error.localizedDescription)") }
            throw error
        }
        
        // Pass the raw data buffer to our C function.
        let image: CGImage? = fileData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> CGImage? in
            guard let baseAddress = pointer.baseAddress else {
                logger.error("Could not get base address of file data.")
                if enableDebugSpew { print("[ERROR] Could not get base address of file data.") }
                return nil
            }
            
            if enableDebugSpew { print("[DEBUG] Calling C function iff_createImageFromData...") }
            // The C function returns an Unmanaged<CGImage>.
            // We must take ownership of the memory from Core Foundation.
            if let unmanagedImage = iff_createImageFromData(baseAddress.assumingMemoryBound(to: UInt8.self), fileData.count, true) {
                logger.log("C function successfully returned an image.")
                if enableDebugSpew { print("[DEBUG] C function successfully returned an image.") }
                return unmanagedImage.takeRetainedValue()
            } else {
                logger.error("C function iff_createImageFromData returned nil.")
                if enableDebugSpew { print("[ERROR] C function iff_createImageFromData returned nil.") }
                return nil
            }
        }
        
        // Ensure we successfully decoded an image.
        guard let finalImage = image else {
            logger.error("Image decoding failed. Final image is nil.")
            if enableDebugSpew { print("[ERROR] Image decoding failed. Final image is nil.") }
            // If the image is nil, we can throw a custom error to be displayed by Quick Look.
            struct ImageDecodingError: LocalizedError {
                var errorDescription: String? { "Could not decode IFF image." }
            }
            throw ImageDecodingError()
        }
        
        logger.log("Image decoded successfully. Preparing SwiftUI view.")
        if enableDebugSpew { print("[DEBUG] Image decoded successfully (width: \(finalImage.width), height: \(finalImage.height)). Preparing SwiftUI view.") }
        
        // Create an instance of our separate SwiftUI view.
        let swiftUIView = IFFPreviewView(image: finalImage)
        
        // Use an NSHostingController to embed the SwiftUI view.
        let hostingController = NSHostingController(rootView: swiftUIView)
        
        // Add the hosting controller's view to our main view and make it fill the space.
        self.view.addSubview(hostingController.view)
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        
        // Set the preferred content size for the Quick Look panel.
        self.preferredContentSize = NSSize(width: finalImage.width, height: finalImage.height)
        logger.log("Preview preparation complete.")
        if enableDebugSpew { print("--- QL PREVIEW END ---") }
    }
}
