import Testing
@testable import Joy1

struct PortDetectorTests {
    @Test func prefersHuearmOverHuecam() {
        let ports = [
            SerialCandidate(path: "/dev/cu.usbserial-834440", product: "HUENIT_CAM", serial: "D30GSA95_HUECAM", vid: 0x0403, pid: 0x6015),
            SerialCandidate(path: "/dev/cu.usbserial-3120", product: "HUENIT_HUEARM", serial: "D30GQRUV_HUEARM", vid: 0x0403, pid: 0x6015),
            SerialCandidate(path: "/dev/cu.Bluetooth-Incoming-Port", product: nil, serial: nil, vid: nil, pid: nil),
        ]
        let picked = PortDetector.pickArm(from: ports)
        #expect(picked?.path == "/dev/cu.usbserial-3120")
    }

    @Test func refusesCameraOnly() {
        let ports = [
            SerialCandidate(path: "/dev/cu.usbserial-834440", product: "HUENIT_CAM", serial: "HUECAM", vid: 0x0403, pid: 0x6015),
        ]
        #expect(PortDetector.pickArm(from: ports) == nil)
    }
}
