import Testing
@testable import AuDeluxe

@MainActor
struct AppSceneStabilityTests {
    @Test("The app scene owns the engine without observing playback ticks")
    func appSceneDoesNotObserveEngine() {
        // Given
        let app = AuDeluxeApp()

        // When
        let engineProperty = Mirror(reflecting: app).children.first { $0.label == "engine" }

        // Then
        #expect(engineProperty?.value is OpenMPTEngine)
    }
}
