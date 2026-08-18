import Testing
@testable import Joy1

struct JogEngineTests {
    @Test func holdXPlusEmitsStep() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.x, .pos, down: true)
        let steps = engine.tick(dt: 0.1)
        #expect(steps.count == 1)
        #expect(steps[0].axis == .x)
        #expect(abs(steps[0].delta - 1.0) < 0.0001)
        #expect(abs(steps[0].feedMmPerMin - 600) < 0.1)
    }

    @Test func releaseStopsStepsAndRequestsFlushAfterIdle() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.x, .pos, down: true)
        _ = engine.tick(dt: 0.1)
        engine.setHeld(.x, .pos, down: false)
        let immediate = engine.tick(dt: 0.1)
        #expect(immediate.isEmpty)
        #expect(engine.wantsFlush == false)
        _ = engine.tick(dt: 0.6)
        #expect(engine.wantsFlush == true)
        engine.didFlush()
        #expect(engine.wantsFlush == false)
    }

    @Test func twoAxesHeldEmitTwoSteps() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.x, .pos, down: true)
        engine.setHeld(.y, .neg, down: true)
        let steps = engine.tick(dt: 0.1)
        #expect(steps.count == 2)
        #expect(steps.contains(where: { $0.axis == .x && $0.delta > 0 }))
        #expect(steps.contains(where: { $0.axis == .y && $0.delta < 0 }))
    }

    @Test func stopClearsHolds() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 10)
        engine.setHeld(.a, .pos, down: true)
        engine.clearAll()
        #expect(engine.tick(dt: 0.1).isEmpty)
    }

    @Test func cartesianUsesMmSpeedJointsUseDegSpeedAndFeedIsAlwaysMmPerMin() {
        var engine = JogEngine(speedMmPerSec: 10, speedDegPerSec: 30)
        engine.setHeld(.x, .pos, down: true)
        engine.setHeld(.a, .neg, down: true)
        let steps = engine.tick(dt: 0.1)
        #expect(steps.count == 2)
        let cartesian = steps.first { $0.axis == .x }
        let joint = steps.first { $0.axis == .a }
        #expect(abs((cartesian?.delta ?? 0) - 1.0) < 0.0001)
        #expect(abs((joint?.delta ?? 0) - (-3.0)) < 0.0001)
        #expect(abs((cartesian?.feedMmPerMin ?? 0) - 600) < 0.1)
        #expect(abs((joint?.feedMmPerMin ?? 0) - 600) < 0.1)
    }
}
