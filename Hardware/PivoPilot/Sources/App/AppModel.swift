import Combine
import Foundation
import simd

@MainActor
final class AppModel: ObservableObject {
    enum MotionSource: String, CaseIterable, Identifiable {
        case simulator = "Simulator"
        case iphone = "iPhone IMU"
        case airPods = "AirPods"
        case watch = "Apple Watch"

        var id: String { rawValue }
    }

    @Published var selectedSource: MotionSource = .simulator {
        didSet { handleSourceChange(from: oldValue, to: selectedSource) }
    }
    @Published var isTracking = false
    @Published var statusText = "Idle"
    @Published var manualTurnAngle = 15
    @Published var simulatedYawDegrees: Double = 0 {
        didSet {
            guard selectedSource == .simulator else { return }
            feedSimulation()
        }
    }

    let fusion = OrientationFusion()
    let motorController = PivoMotorController()

    private let airPodsTracker = AirPodsHeadTracker()
    private let phoneMotionTracker = PhoneMotionTracker()
    private let watchReceiver = WatchOrientationReceiver()
    private let motorMapper = MotorMapper()
    private var cancellables = Set<AnyCancellable>()

    init() {
        airPodsTracker.onQuaternion = { [weak self] quaternion in
            self?.handleQuaternion(quaternion)
        }

        phoneMotionTracker.onQuaternion = { [weak self] quaternion in
            self?.handleQuaternion(quaternion)
        }

        watchReceiver.onYawRadians = { [weak self] yaw in
            self?.handleWatchYaw(yaw)
        }

        motorController.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        feedSimulation()
    }

    var sourceDescription: String {
        switch selectedSource {
        case .simulator:
            return "Manual test input for rapid iteration without hardware."
        case .iphone:
            return "Uses the phone's IMU via Core Motion."
        case .airPods:
            return "Uses head tracking from supported AirPods."
        case .watch:
            return "Consumes yaw updates from a watchOS companion."
        }
    }

    func connectMotor() {
        motorController.scan()
        statusText = "Scanning for Pivo devices"
    }

    func disconnectMotor() {
        motorController.disconnect()
        statusText = "Motor disconnected"
    }

    func stopScanning() {
        motorController.stopScanning()
    }

    func connectMotor(to device: PivoDevice) {
        motorController.connect(to: device)
        statusText = "Connecting to \(device.name)"
    }

    func setMotorSpeed(_ speed: Int) {
        motorController.setSpeed(speed)
    }

    func requestBatteryLevel() {
        motorController.requestBatteryLevel()
    }

    func manualTurnLeft() {
        motorController.turnLeft(angle: manualTurnAngle)
    }

    func manualTurnRight() {
        motorController.turnRight(angle: manualTurnAngle)
    }

    func startContinuousLeft() {
        motorController.turnLeftContinuously()
    }

    func startContinuousRight() {
        motorController.turnRightContinuously()
    }

    func stopMotorMotion() {
        motorController.stopMotor()
    }

    func toggleTracking() {
        if isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }

    func recenter() {
        fusion.recenter()
        statusText = "Reference reset"
        if selectedSource == .simulator {
            feedSimulation()
        }
    }

    func nudgeSimulation(by deltaDegrees: Double) {
        simulatedYawDegrees = max(-180, min(180, simulatedYawDegrees + deltaDegrees))
    }

    private func startTracking() {
        fusion.recenter()
        isTracking = true
        startCurrentSource()
        statusText = "Tracking from \(selectedSource.rawValue)"
    }

    private func stopTracking() {
        isTracking = false
        stopCurrentSource()
        motorController.stopMotor()
        statusText = "Tracking stopped"
    }

    private func handleQuaternion(_ quaternion: simd_quatd) {
        fusion.update(current: quaternion)
        dispatchMotorCommandIfNeeded()
    }

    private func handleWatchYaw(_ yawRadians: Double) {
        fusion.update(yawRadians: yawRadians)
        dispatchMotorCommandIfNeeded()
    }

    private func dispatchMotorCommandIfNeeded() {
        guard isTracking else { return }
        let command = motorMapper.command(forYawRadians: fusion.smoothedYawRadians)
        motorController.send(command)
    }

    private func handleSourceChange(from oldSource: MotionSource, to newSource: MotionSource) {
        guard oldSource != newSource else { return }

        if isTracking {
            stopSource(oldSource)
            fusion.recenter()
            startCurrentSource()
            statusText = "Switched to \(newSource.rawValue)"
        } else if newSource == .simulator {
            feedSimulation()
        }
    }

    private func startCurrentSource() {
        switch selectedSource {
        case .simulator:
            feedSimulation()
        case .iphone:
            phoneMotionTracker.start()
            statusText = phoneMotionTracker.lastError ?? statusText
        case .airPods:
            airPodsTracker.start()
            statusText = airPodsTracker.lastError ?? statusText
        case .watch:
            watchReceiver.start()
            statusText = watchReceiver.lastError ?? statusText
        }
    }

    private func stopCurrentSource() {
        stopSource(selectedSource)
    }

    private func stopSource(_ source: MotionSource) {
        switch source {
        case .simulator:
            break
        case .iphone:
            phoneMotionTracker.stop()
        case .airPods:
            airPodsTracker.stop()
        case .watch:
            watchReceiver.stop()
        }
    }

    private func feedSimulation() {
        let radians = simulatedYawDegrees * .pi / 180
        let quaternion = simd_quatd(angle: radians, axis: SIMD3<Double>(0, 0, 1))
        handleQuaternion(quaternion)
    }
}
