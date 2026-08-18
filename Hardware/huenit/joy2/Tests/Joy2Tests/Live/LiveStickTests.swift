import Testing
import Joy1
@testable import Joy2

struct LiveStickTests {
    @Test func mapperThenTinyXYUndo() async throws {
        guard PortDetector.pickArm(from: PortDetector.scan()) != nil else {
            return
        }
        let ports = PortDetector.scan()
        guard let path = PortDetector.pickArm(from: ports)?.path else { return }
        let arm = HuenitArm(transport: SerialPort(path: path))
        try await arm.connect()
        let before = try await arm.queryPose()
        var mapper = JoystickMapper()
        let mapped = mapper.map(
            JoystickSample(connected: true, direction: .e, leftFire: false, rightFire: false)
        )
        guard case .jog(let vector) = mapped.intent else {
            Issue.record("expected jog")
            await arm.disconnect()
            return
        }
        #expect(vector.dx == -1)
        try await arm.step(dx: Double(vector.dx), dy: 0, dz: 0, feedMmPerMin: 300)
        try await arm.flush()
        try await arm.step(dx: Double(-vector.dx), dy: 0, dz: 0, feedMmPerMin: 300)
        try await arm.flush()
        let after = try await arm.queryPose()
        #expect(abs(after.cartesian.x - before.cartesian.x) < 2)
        try await arm.stop()
        await arm.disconnect()
    }
}
