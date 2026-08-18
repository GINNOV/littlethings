import Testing
@testable import Joy2

struct MapperTests {
    @Test func stickRightIsXMinusOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: -1, dy: 0, dz: 0, de: 0)))
        #expect(result.highlights.cells == [.xMinus])
    }

    @Test func stickAwayIsYPlus() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: false, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 0, dy: 1, dz: 0, de: 0)))
        #expect(result.highlights.cells == [.yPlus])
    }

    @Test func diagonalNorthEastHighlightsBoth() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.ne, leftFire: false, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: -1, dy: 1, dz: 0, de: 0)))
        #expect(result.highlights.cells == [.xMinus, .yPlus, .xyNW])
    }

    @Test func leftFireForwardIsZPlus() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: true, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 0, dy: 0, dz: 1, de: 0)))
        #expect(result.highlights.cells == [.zPlus, .zAngleMode])
    }

    @Test func leftFireRightIsEPlus() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: true, rightFire: false))
        #expect(result.intent == .jog(JogVector(dx: 0, dy: 0, dz: 0, de: 1)))
        #expect(result.highlights.cells == [.ePlus, .zAngleMode])
    }

    @Test func centerClearsJogHighlights() {
        var mapper = JoystickMapper()
        _ = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        let result = mapper.map(.idle)
        #expect(result.intent == .none)
        #expect(result.highlights.cells.isEmpty)
    }

    @Test func leftFireHeldAtCenterIsModeOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: true, rightFire: false))
        #expect(result.intent == .none)
        #expect(result.highlights.cells == [.zAngleMode])
    }

    @Test func rightFireIsEdgeToggle() {
        var mapper = JoystickMapper()
        let down = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: false, rightFire: true))
        #expect(down.intent == .toggleVacuum)
        #expect(down.highlights.cells.contains(.suction))
        let held = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: false, rightFire: true))
        #expect(held.intent == .none)
        let up = mapper.map(.idle)
        #expect(up.intent == .none)
    }

    @Test func bothFiresDoNotInventHomeOrStop() {
        var mapper = JoystickMapper()
        let result = mapper.map(JoystickSample(connected: true, direction: .center, leftFire: true, rightFire: true))
        #expect(result.intent == .toggleVacuum)
        if case .stop = result.intent { Issue.record("stop is not a stick gesture") }
    }

    @Test func disconnectedSampleIsNone() {
        var mapper = JoystickMapper()
        let result = mapper.map(JoystickSample(connected: false, direction: .e, leftFire: true, rightFire: true))
        #expect(result.intent == .none)
        #expect(result.highlights.cells.isEmpty)
    }
}
