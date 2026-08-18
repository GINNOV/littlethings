import Testing
@testable import Joy2

struct GuardTests {
    let jog = PilotIntent.jog(JogVector(dx: 1, dy: 0, dz: 0, de: 0))
    let idle = GuardState(armConnected: true, motorsOn: true, busy: false)

    @Test func allowsLegalJog() {
        let decision = IntentGuard.decide(jog, state: idle)
        #expect(decision.accepted == jog)
        #expect(decision.reject == nil)
    }

    @Test func blocksWhenDisconnected() {
        let decision = IntentGuard.decide(jog, state: GuardState(armConnected: false, motorsOn: true, busy: false))
        #expect(decision.accepted == nil)
        #expect(decision.reject == .notConnected)
    }

    @Test func blocksWhenBusy() {
        let decision = IntentGuard.decide(jog, state: GuardState(armConnected: true, motorsOn: true, busy: true))
        #expect(decision.accepted == nil)
        #expect(decision.reject == .busy)
    }

    @Test func blocksJogWhenMotorsOff() {
        let decision = IntentGuard.decide(jog, state: GuardState(armConnected: true, motorsOn: false, busy: false))
        #expect(decision.accepted == nil)
        #expect(decision.reject == .motorsOff)
    }

    @Test func stopAlwaysAccepted() {
        let decision = IntentGuard.decide(.stop, state: GuardState(armConnected: false, motorsOn: false, busy: true))
        #expect(decision.accepted == .stop)
        #expect(decision.reject == nil)
    }

    @Test func noneAlwaysAccepted() {
        let decision = IntentGuard.decide(.none, state: GuardState(armConnected: false, motorsOn: false, busy: true))
        #expect(decision.accepted == PilotIntent.none)
    }

    @Test func toggleVacuumRequiresConnectNotMotors() {
        let off = GuardState(armConnected: true, motorsOn: false, busy: false)
        let decision = IntentGuard.decide(.toggleVacuum, state: off)
        #expect(decision.accepted == .toggleVacuum)
    }

    @Test func intentHasNoG28Case() {
        let intents: [PilotIntent] = [
            .none,
            .jog(JogVector(dx: 1, dy: 0, dz: 0, de: 0)),
            .toggleVacuum,
            .stop,
        ]
        for intent in intents {
            switch intent {
            case .none, .jog, .toggleVacuum, .stop:
                break
            }
        }
    }
}
