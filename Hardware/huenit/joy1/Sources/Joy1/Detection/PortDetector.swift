import Foundation
import IOKit
import IOKit.serial

public struct SerialCandidate: Equatable, Sendable {
    public var path: String
    public var product: String?
    public var serial: String?
    public var vid: Int?
    public var pid: Int?

    public init(path: String, product: String?, serial: String?, vid: Int?, pid: Int?) {
        self.path = path
        self.product = product
        self.serial = serial
        self.vid = vid
        self.pid = pid
    }

    public var isCamera: Bool {
        let blob = "\(product ?? "") \(serial ?? "")".uppercased()
        return blob.contains("HUECAM") || blob.contains("HUENIT_CAM")
    }

    public var isArm: Bool {
        let blob = "\(product ?? "") \(serial ?? "")".uppercased()
        return blob.contains("HUEARM") || blob.contains("HUENIT_HUEARM")
    }

    public var score: Int {
        if isCamera { return -100 }
        var s = 0
        if isArm { s += 10 }
        // FYSETC E4 enumerates as cu.usbmodem. The K210 camera is cu.usbserial.
        if path.contains("usbmodem") { s += 8 }
        if vid == 0x0403 && pid == 0x6015 { s += 3 }
        if path.contains("usbserial") { s += 1 }
        return s
    }
}

public enum PortDetector {
    public static func pickArm(from ports: [SerialCandidate]) -> SerialCandidate? {
        ports.filter { $0.score > 0 }.max(by: { $0.score < $1.score })
    }

    public static func scan() -> [SerialCandidate] {
        var results: [SerialCandidate] = []
        let matching = IOServiceMatching(kIOSerialBSDServiceValue)
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return results
        }
        defer { IOObjectRelease(iterator) }
        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            let path = string(service, kIOCalloutDeviceKey)
            guard let path else { continue }
            let product = walkString(service, "USB Product Name")
            let serial = walkString(service, "USB Serial Number")
            let vid = walkInt(service, "idVendor")
            let pid = walkInt(service, "idProduct")
            results.append(SerialCandidate(path: path, product: product, serial: serial, vid: vid, pid: pid))
        }
        return results
    }

    private static func string(_ service: io_object_t, _ key: String) -> String? {
        let unmanaged = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)
        return unmanaged?.takeRetainedValue() as? String
    }

    private static func walkString(_ service: io_object_t, _ key: String) -> String? {
        let value = IORegistryEntrySearchCFProperty(
            service, kIOServicePlane, key as CFString, kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateParents | kIORegistryIterateRecursively)
        )
        return value as? String
    }

    private static func walkInt(_ service: io_object_t, _ key: String) -> Int? {
        let value = IORegistryEntrySearchCFProperty(
            service, kIOServicePlane, key as CFString, kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateParents | kIORegistryIterateRecursively)
        )
        if let n = value as? NSNumber { return n.intValue }
        return nil
    }
}
