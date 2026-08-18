import Testing
@testable import Joy2

struct HighlightTests {
    @Test func stickRightHighlightsXMinusOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        #expect(result.highlights.cells == [.xMinus])
    }

    @Test func leftPlusForwardHighlightsZPlusAndMode() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: true, rightFire: false))
        #expect(result.highlights.cells == [.zPlus, .zAngleMode])
    }
}
