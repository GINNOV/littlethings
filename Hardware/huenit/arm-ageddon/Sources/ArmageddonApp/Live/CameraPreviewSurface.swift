import AVFoundation
import AppKit
import SwiftUI

struct CameraPreviewSurface: NSViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        previewLayer.frame = view.bounds
    }
}
