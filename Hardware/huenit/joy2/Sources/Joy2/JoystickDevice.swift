import Foundation
import IOKit.hid

public enum SpeedlinkIDs {
    public static let vendorID = 0x0079
    public static let productID = 0x181C
}

public final class JoystickDevice: JoystickSourcing, @unchecked Sendable {
    private let manager: IOHIDManager
    private let lock = NSLock()
    private var sample = JoystickSample(connected: false, direction: .center, leftFire: false, rightFire: false)
    private var axisX = 0.5
    private var axisY = 0.5

    public init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let match: [String: Any] = [
            kIOHIDVendorIDKey as String: SpeedlinkIDs.vendorID,
            kIOHIDProductIDKey as String: SpeedlinkIDs.productID,
        ]
        IOHIDManagerSetDeviceMatching(manager, match as CFDictionary)
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, _ in
            guard let context else { return }
            Unmanaged<JoystickDevice>.fromOpaque(context).takeUnretainedValue().setConnected(true)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, _ in
            guard let context else { return }
            Unmanaged<JoystickDevice>.fromOpaque(context).takeUnretainedValue().setConnected(false)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterInputValueCallback(manager, { context, _, _, value in
            guard let context else { return }
            Unmanaged<JoystickDevice>.fromOpaque(context).takeUnretainedValue().handle(value)
        }, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    deinit {
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    public func currentSample() -> JoystickSample {
        lock.lock()
        defer { lock.unlock() }
        return sample
    }

    private func setConnected(_ connected: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if connected {
            sample.connected = true
        } else {
            sample = JoystickSample(connected: false, direction: .center, leftFire: false, rightFire: false)
            axisX = 0.5
            axisY = 0.5
        }
    }

    private func handle(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)
        let integer = IOHIDValueGetIntegerValue(value)
        let min = IOHIDElementGetLogicalMin(element)
        let max = IOHIDElementGetLogicalMax(element)

        lock.lock()
        defer { lock.unlock() }
        sample.connected = true

        if usagePage == 0x01 && (usage == 0x30 || usage == 0x31) && max > min {
            let norm = Double(integer - min) / Double(max - min)
            if usage == 0x30 { axisX = norm }
            if usage == 0x31 {
                axisY = 1 - norm
            }
            sample.direction = StickDirection.fromAxes(x: axisX, y: axisY)
        } else if usagePage == 0x09 {
            let down = integer != 0
            if usage == 1 { sample.leftFire = down }
            if usage == 2 { sample.rightFire = down }
        }
    }
}
