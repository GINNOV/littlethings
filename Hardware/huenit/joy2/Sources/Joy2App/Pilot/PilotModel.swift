import Foundation
import Joy1
import Joy2
import Observation

@MainActor
@Observable
final class PilotModel {
    var pendant: PendantModel
    private(set) var highlights = Set<PadCell>()
    private(set) var stickConnected = false
    private(set) var stickMessage: String? = "Plug in the Speedlink stick"
    private(set) var lastGuardReject: GuardReject?

    private var mapper = JoystickMapper()
    private let stick: any JoystickSourcing
    private var tickTask: Task<Void, Never>?
    private var lastStickConnected = false

    init(pendant: PendantModel, stick: any JoystickSourcing) {
        self.pendant = pendant
        self.stick = stick
        pendant.setControlMode(.hold)
    }

    func start() {
        pendant.refreshPorts()
        pendant.setControlMode(.hold)
        pendant.startJogLoop()
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.tick()
                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }

    func emergencyStop() async {
        mapper = JoystickMapper()
        highlights = []
        lastGuardReject = nil
        applyHold(JogVector(dx: 0, dy: 0, dz: 0, de: 0))
        await pendant.stop()
    }

    func tick() async {
        let sample = stick.currentSample()
        if lastStickConnected && !sample.connected {
            await emergencyStop()
            stickConnected = false
            stickMessage = "Plug in the Speedlink stick"
            lastStickConnected = false
            return
        }
        lastStickConnected = sample.connected
        stickConnected = sample.connected
        stickMessage = sample.connected ? nil : "Plug in the Speedlink stick"

        let mapped = mapper.map(sample)
        highlights = mapped.highlights.cells

        let state = GuardState(
            armConnected: pendant.isConnected,
            motorsOn: pendant.motorsOn,
            busy: false
        )
        let decision = IntentGuard.decide(mapped.intent, state: state)
        lastGuardReject = decision.reject
        guard let accepted = decision.accepted else {
            applyHold(JogVector(dx: 0, dy: 0, dz: 0, de: 0))
            return
        }
        await apply(accepted)
    }

    private func apply(_ intent: PilotIntent) async {
        switch intent {
        case .none:
            applyHold(JogVector(dx: 0, dy: 0, dz: 0, de: 0))
        case .stop:
            await emergencyStop()
        case .toggleVacuum:
            await pendant.setVacuum(!pendant.vacuumOn)
        case .jog(let vector):
            applyHold(vector)
        }
    }

    private func applyHold(_ vector: JogVector) {
        pendant.setHeld(.x, .pos, down: vector.dx > 0)
        pendant.setHeld(.x, .neg, down: vector.dx < 0)
        pendant.setHeld(.y, .pos, down: vector.dy > 0)
        pendant.setHeld(.y, .neg, down: vector.dy < 0)
        pendant.setHeld(.z, .pos, down: vector.dz > 0)
        pendant.setHeld(.z, .neg, down: vector.dz < 0)
        pendant.setHeld(.e, .pos, down: vector.de > 0)
        pendant.setHeld(.e, .neg, down: vector.de < 0)
    }
}
