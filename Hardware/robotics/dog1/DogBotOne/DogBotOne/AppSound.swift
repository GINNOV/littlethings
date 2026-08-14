import AppKit

enum AppSound {
    static let enabledDefaultsKey = "appSoundsEnabled"

    case connected
    case disconnected
    case commandSent
    case error

    private var systemSoundName: String {
        switch self {
        case .connected: "Glass"
        case .disconnected: "Pop"
        case .commandSent: "Tink"
        case .error: "Basso"
        }
    }

    static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: enabledDefaultsKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: enabledDefaultsKey)
    }

    func play() {
        guard Self.isEnabled else { return }
        let name = systemSoundName
        if let sound = NSSound(named: name) {
            sound.play()
            return
        }
        let url = URL(fileURLWithPath: "/System/Library/Sounds/\(name).aiff")
        NSSound(contentsOf: url, byReference: true)?.play()
    }
}
