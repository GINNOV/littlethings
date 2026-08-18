import Testing
@testable import Joy2

struct HighlightTests {
    @Test func stickRightHighlightsXPlusOnly() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.e, leftFire: false, rightFire: false))
        #expect(result.highlights.cells == [.xPlus])
    }

    @Test func leftPlusForwardHighlightsZPlusAndMode() {
        var mapper = JoystickMapper()
        let result = mapper.map(.deflected(.n, leftFire: true, rightFire: false))
        #expect(result.highlights.cells == [.zPlus, .zAngleMode])
    }
}
