import Foundation
import IOKit
import IOKit.serial

struct SerialCandidate: Equatable, Sendable {
    var path: String
    var product: String?
    var serial: String?
    var vid: Int?
    var pid: Int?

    var isCamera: Bool {
        let blob = "\(product ?? "") \(serial ?? "")".uppercased()
        return blob.contains("HUECAM") || blob.contains("HUENIT_CAM")
    }

    var isArm: Bool {
        let blob = "\(product ?? "") \(serial ?? "")".uppercased()
        return blob.contains("HUEARM") || blob.contains("HUENIT_HUEARM")
    }

    var score: Int {
        if isCamera { return -100 }
        var score = 0
        if isArm { score += 10 }
        // FYSETC E4 (Joy1/Joy2 live arm) enumerates as cu.usbmodem, not FTDI usbserial.
        // The K210 camera is the FTDI cu.usbserial device. Prefer modem when names are missing.
        if path.contains("usbmodem") { score += 8 }
        if vid == 0x0403 && pid == 0x6015 { score += 2 }
        if path.contains("usbserial") { score += 1 }
        return score
    }
}

enum PortDetector {
    static func pickArm(from ports: [SerialCandidate]) -> SerialCandidate? {
        ports.filter { $0.score > 0 }.max { $0.score < $1.score }
    }

    static func scan() -> [SerialCandidate] {
        var results: [SerialCandidate] = []
        let matching = IOServiceMatching(kIOSerialBSDServiceValue)
        var iterator: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS {
            defer { IOObjectRelease(iterator) }
            var service = IOIteratorNext(iterator)
            while service != 0 {
                defer { IOObjectRelease(service); service = IOIteratorNext(iterator) }
                guard let path = string(service, kIOCalloutDeviceKey) else { continue }
                results.append(SerialCandidate(
                    path: path,
                    product: walkString(service, "USB Product Name"),
                    serial: walkString(service, "USB Serial Number"),
                    vid: walkInt(service, "idVendor"),
                    pid: walkInt(service, "idProduct")
                ))
            }
        }
        if let names = try? FileManager.default.contentsOfDirectory(atPath: "/dev") {
            for name in names where name.hasPrefix("cu.usbserial") || name.hasPrefix("cu.usbmodem") {
                let path = "/dev/\(name)"
                if !results.contains(where: { $0.path == path }) {
                    results.append(SerialCandidate(path: path, product: nil, serial: nil, vid: nil, pid: nil))
                }
            }
        }
        return results
    }

    private static func string(_ service: io_object_t, _ key: String) -> String? {
        IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String
    }

    private static func walkString(_ service: io_object_t, _ key: String) -> String? {
        IORegistryEntrySearchCFProperty(
            service, kIOServicePlane, key as CFString, kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateParents | kIORegistryIterateRecursively)
        ) as? String
    }

    private static func walkInt(_ service: io_object_t, _ key: String) -> Int? {
        (IORegistryEntrySearchCFProperty(
            service, kIOServicePlane, key as CFString, kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateParents | kIORegistryIterateRecursively)
        ) as? NSNumber)?.intValue
    }
}
