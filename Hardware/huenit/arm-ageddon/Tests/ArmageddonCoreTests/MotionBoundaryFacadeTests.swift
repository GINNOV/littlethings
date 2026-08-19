import Testing
@testable import ArmageddonMotionBoundary

struct MotionBoundaryFacadeTests {
    @Test("Motion is denied when no internal permit can be issued")
    func deniesMotionWhenPermitIsUnavailable() async {
        // Given
        let facade = MotionBoundaryFacade()
        let intent = MotionIntent(x: 1, y: 1)

        // When
        let decision = await facade.requestMotion(intent)

        // Then
        #expect(decision == .denied(.permitUnavailable))
    }
}
