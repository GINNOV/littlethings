import AppKit
import Joy1
import SwiftUI

enum WindowSnapshot {
    @MainActor
    static func write() {
        _ = NSApplication.shared
        let model = PendantModel(
            arm: HuenitArm(transport: SerialPort(path: "/dev/null")),
            detector: { [] }
        )
        model.refreshPorts()
        let view = ContentView(model: model)
            .frame(width: 980, height: 640)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.nsImage else {
            fputs("snapshot: render failed\n", stderr)
            exit(1)
        }
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("docs/joy1-window.png")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:])
        else {
            fputs("snapshot: encode failed\n", stderr)
            exit(1)
        }
        do {
            try png.write(to: url)
            print("wrote \(url.path)")
            exit(0)
        } catch {
            fputs("snapshot: \(error)\n", stderr)
            exit(1)
        }
    }
}
