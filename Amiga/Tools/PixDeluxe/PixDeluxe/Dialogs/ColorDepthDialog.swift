//
//  ColorDepthDialog.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/7/25.
//

import AppKit

class ColorDepthDialog {
    /// Runs a modal dialog to ask the user for the desired number of bitplanes (1-8).
    /// - Returns: The selected number of bitplanes, or `nil` if the user cancels.
    func runModal() -> Int? {
        let alert = NSAlert()
        alert.messageText = "Choose Color Depth"
        alert.informativeText = "Select the number of bitplanes for the new IFF image. This will determine the maximum number of colors."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 50))
        
        let label = NSTextField(labelWithString: "Color Depth:")
        label.frame = NSRect(x: 0, y: 15, width: 100, height: 24)
        
        let popup = NSPopUpButton(frame: NSRect(x: 100, y: 10, width: 190, height: 24), pullsDown: false)
        popup.addItems(withTitles: (1...8).map { "\($0) bitplanes (\(Int(pow(2.0, Double($0)))) colors)" })
        popup.selectItem(at: 7) // Default to 8 bitplanes (256 colors)
        
        accessoryView.addSubview(label)
        accessoryView.addSubview(popup)
        
        alert.accessoryView = accessoryView
        
        if alert.runModal() == .alertFirstButtonReturn {
            return popup.indexOfSelectedItem + 1
        } else {
            return nil
        }
    }
}
