import Observation

@MainActor
@Observable
final class AppShellModel {
    private(set) var notice: String?
    var destination: AppDestination

    init(requestedDestination: String?) {
        if let requestedDestination, let destination = AppDestination(rawValue: requestedDestination) {
            self.destination = destination
            notice = nil
        } else if requestedDestination != nil {
            destination = .live
            notice = "Navigation recovered to Live"
        } else {
            destination = .live
            notice = nil
        }
    }

    func select(_ destination: AppDestination) {
        self.destination = destination
        if notice == "Navigation recovered to Live" {
            notice = nil
        }
    }

    func stop() {
        notice = "STOP requested"
    }

    func requestRecovery() {
        notice = "Recovery requested"
    }
}
