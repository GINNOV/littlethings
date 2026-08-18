import Testing
@testable import Joy2

struct DeviceDirectionTests {
    @Test func centerStaysCenter() {
        #expect(StickDirection.fromAxes(x: 0.5, y: 0.5) == .center)
    }

    @Test func rightIsEast() {
        #expect(StickDirection.fromAxes(x: 1.0, y: 0.5) == .e)
    }

    @Test func upIsNorth() {
        #expect(StickDirection.fromAxes(x: 0.5, y: 1.0) == .n)
    }

    @Test func northEastDiagonal() {
        #expect(StickDirection.fromAxes(x: 1.0, y: 1.0) == .ne)
    }

    @Test func deadzoneIgnoresChatter() {
        #expect(StickDirection.fromAxes(x: 0.55, y: 0.48) == .center)
    }
}
