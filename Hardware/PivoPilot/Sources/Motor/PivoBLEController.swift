import Combine
import Foundation

#if !targetEnvironment(simulator)
@preconcurrency import PivoProSDK
#endif

enum MotorConnectionState: String {
    case disconnected = "Disconnected"
    case scanning = "Scanning"
    case connecting = "Connecting"
    case connected = "Connected"
    case unavailable = "Unavailable"
}

struct PivoDevice: Identifiable, Equatable {
    let id: String
    let name: String
}

@MainActor
final class PivoMotorController: NSObject, ObservableObject {
    @Published private(set) var connectionState: MotorConnectionState = .disconnected
    @Published private(set) var lastCommand: MotorCommand = .stop
    @Published private(set) var availableDevices: [PivoDevice] = []
    @Published private(set) var connectedDevice: PivoDevice?
    @Published private(set) var batteryLevel: Int?
    @Published private(set) var supportedSpeeds: [Int] = [12, 18, 24]
    @Published private(set) var currentSpeed = 12
    @Published private(set) var lastEventDescription = "Idle"
    @Published private(set) var licenseStatus = "License file not found"

    var displayName: String {
        sdkAvailable ? "Pivo SDK" : "Mock Pivo Motor"
    }

    var sdkAvailable: Bool {
        #if !targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    #if !targetEnvironment(simulator)
    nonisolated(unsafe) private let sdk = PivoSDK.shared
    #endif

    override init() {
        super.init()
        bootstrap()
    }

    func scan() {
        guard sdkAvailable else {
            availableDevices = [PivoDevice(id: "mock-pivo", name: "Mock Pivo Pod")]
            connectionState = .unavailable
            lastEventDescription = "Pivo SDK not linked. Run pod install and open the workspace."
            return
        }

        #if !targetEnvironment(simulator)
        do {
            availableDevices.removeAll()
            connectionState = .scanning
            lastEventDescription = "Scanning for nearby Pivo devices"
            try sdk.scan()
        } catch {
            connectionState = .unavailable
            lastEventDescription = error.localizedDescription
        }
        #endif
    }

    func stopScanning() {
        #if !targetEnvironment(simulator)
        sdk.stopScan()
        #endif

        if connectionState == .scanning {
            connectionState = connectedDevice == nil ? .disconnected : .connected
        }
    }

    func connect(to device: PivoDevice) {
        guard sdkAvailable else {
            connectedDevice = device
            connectionState = .connected
            lastEventDescription = "Connected to mock device"
            return
        }

        #if !targetEnvironment(simulator)
        connectedDevice = device
        connectionState = .connecting
        lastEventDescription = "Connecting to \(device.name)"
        sdk.connect(id: device.id)
        #endif
    }

    func disconnect() {
        #if !targetEnvironment(simulator)
        sdk.disconnect()
        #endif

        connectedDevice = nil
        connectionState = .disconnected
        lastCommand = .stop
        lastEventDescription = "Disconnected"
    }

    func setSpeed(_ speed: Int) {
        currentSpeed = speed
        #if !targetEnvironment(simulator)
        if sdkAvailable {
            sdk.setSpeedBySecondsPerRound(speed)
        }
        #endif
        lastEventDescription = "Speed set to \(speed) s/r"
    }

    func send(_ command: MotorCommand) {
        lastCommand = command

        #if !targetEnvironment(simulator)
        if sdkAvailable {
            switch command {
            case .rotateLeft(let speed):
                sdk.turnLeftContinuously(speed: speed)
            case .rotateRight(let speed):
                sdk.turnRightContinuously(speed: speed)
            case .stop:
                sdk.stop()
            }
        }
        #endif

        lastEventDescription = command.description
    }

    func turnLeft(angle: Int) {
        lastCommand = .rotateLeft(speed: currentSpeed)

        #if !targetEnvironment(simulator)
        if sdkAvailable {
            do {
                try sdk.turnLeftWithFeedback(angle: angle)
            } catch {
                sdk.turnLeft(angle: angle, speed: currentSpeed)
            }
        }
        #endif

        lastEventDescription = "Turn left \(angle)°"
    }

    func turnRight(angle: Int) {
        lastCommand = .rotateRight(speed: currentSpeed)

        #if !targetEnvironment(simulator)
        if sdkAvailable {
            do {
                try sdk.turnRightWithFeedback(angle: angle)
            } catch {
                sdk.turnRight(angle: angle, speed: currentSpeed)
            }
        }
        #endif

        lastEventDescription = "Turn right \(angle)°"
    }

    func turnLeftContinuously() {
        send(.rotateLeft(speed: currentSpeed))
    }

    func turnRightContinuously() {
        send(.rotateRight(speed: currentSpeed))
    }

    func stopMotor() {
        send(.stop)
    }

    func requestBatteryLevel() {
        #if !targetEnvironment(simulator)
        if sdkAvailable {
            sdk.requestBatteryLevel()
        } else {
            batteryLevel = 100
        }
        #else
        batteryLevel = 100
        #endif
        lastEventDescription = "Battery refresh requested"
    }

    private func bootstrap() {
        if sdkAvailable {
            #if !targetEnvironment(simulator)
            sdk.addDelegate(self)
            let speeds = sdk.getSupportedSpeedsInSecondsPerRound()
            if !speeds.isEmpty {
                supportedSpeeds = speeds
                currentSpeed = speeds[0]
                sdk.setFastestSpeed()
            }
            unlockLicenseIfPossible()
            #endif
        } else {
            licenseStatus = "Pivo SDK unavailable"
        }
    }

    #if !targetEnvironment(simulator)
    private func unlockLicenseIfPossible() {
        guard let url = Bundle.main.url(forResource: "licenseKey", withExtension: "json") else {
            licenseStatus = "Missing Resources/licenseKey.json"
            return
        }

        do {
            try sdk.unlockWithLicenseKey(licenseKeyFileURL: url)
            licenseStatus = "License unlocked"
        } catch {
            licenseStatus = "License error: \(error.localizedDescription)"
            lastEventDescription = licenseStatus
        }
    }
    #endif
}

#if !targetEnvironment(simulator)
extension PivoMotorController: @preconcurrency PivoConnectionDelegate {
    nonisolated func pivoConnection(didDiscover id: String, deviceName: String) {
        Task { @MainActor in
            let device = PivoDevice(id: id, name: deviceName)
            if !availableDevices.contains(device) {
                availableDevices.append(device)
            }
            lastEventDescription = "Discovered \(deviceName)"
        }
    }

    nonisolated func pivoConnection(didConnect id: String) {
        Task { @MainActor in
            connectionState = .connecting
            lastEventDescription = "Bluetooth connected"
        }
    }

    nonisolated func pivoConnection(didDisconnect id: String) {
        Task { @MainActor in
            connectionState = .disconnected
            connectedDevice = nil
            lastCommand = .stop
            lastEventDescription = "Device disconnected"
        }
    }

    nonisolated func pivoConnection(didFailToConnect id: String) {
        Task { @MainActor in
            connectionState = .disconnected
            lastEventDescription = "Failed to connect"
        }
    }

    nonisolated func pivoConnection(didEstablishSuccessfully id: String) {
        Task { @MainActor in
            connectionState = .connected
            if let device = availableDevices.first(where: { $0.id == id }) {
                connectedDevice = device
                lastEventDescription = "Connected to \(device.name)"
            } else {
                lastEventDescription = "Connection established"
            }
        }
    }

    nonisolated func pivoConnectionDidRotate() {
        Task { @MainActor in
            lastEventDescription = "Rotation completed"
        }
    }

    nonisolated func pivoConnectionDidRotate1DegreeLeft() {
        Task { @MainActor in
            lastEventDescription = "Rotated 1° left"
        }
    }

    nonisolated func pivoConnectionDidRotate1DegreeRight() {
        Task { @MainActor in
            lastEventDescription = "Rotated 1° right"
        }
    }

    nonisolated func pivoConnection(batteryLevel: Int) {
        Task { @MainActor in
            self.batteryLevel = batteryLevel
            lastEventDescription = "Battery \(batteryLevel)%"
        }
    }

    nonisolated func pivoConnection(remoteControlerCommandReceived command: PivoEvent) {
        Task { @MainActor in
            lastEventDescription = "Remote command: \(String(describing: command))"
        }
    }

    nonisolated func pivoConnection(bluetoothIsOn: Bool) {
        Task { @MainActor in
            if bluetoothIsOn {
                if connectionState == .unavailable {
                    connectionState = .disconnected
                }
                lastEventDescription = "Bluetooth is on"
            } else {
                connectionState = .unavailable
                lastEventDescription = "Bluetooth is off"
            }
        }
    }

    nonisolated func pivoConnectionBluetoothPermissionDenied() {
        Task { @MainActor in
            connectionState = .unavailable
            lastEventDescription = "Bluetooth permission denied"
        }
    }
}
#endif
