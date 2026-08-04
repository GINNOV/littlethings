import AVFoundation
import Foundation
import Testing
@testable import AuDeluxe

struct ModuleActorTests {
    @Test("A valid MOD fixture produces metadata and audio frames")
    func validMODProducesMetadataAndAudioFrames() async throws {
        // Given
        let fixtureURL = try #require(
            Bundle(for: FixtureBundleToken.self).url(
                forResource: "MINISONG",
                withExtension: "MOD"
            )
        )
        let data = try Data(contentsOf: fixtureURL)
        let actor = ModuleActor()
        let format = try #require(
            AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)
        )

        // When
        let module = await actor.create(from: data)
        let buffer = await actor.render(format: format, frameCount: 1_024)

        // Then
        #expect(module.module != nil)
        #expect(module.duration > 0)
        #expect(buffer?.frameLength == 1_024)
        await actor.destroy()
    }
}

private final class FixtureBundleToken {}
