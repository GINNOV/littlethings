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
            destination = .go
            notice = "Navigation recovered to Go"
        } else {
            destination = .go
            notice = nil
        }
    }

    func select(_ destination: AppDestination) {
        self.destination = destination
    }

    func stop() {
        notice = "STOP requested"
    }

    func requestRecovery() {
        notice = "Recovery requested"
    }
}
