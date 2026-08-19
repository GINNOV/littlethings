import Foundation

struct ScopeArguments: Sendable {
    let launchReceipt: URL
    let readyReceipt: URL
    let gate: URL

    init?(values: [String: String]) throws {
        let names = ["-qa-scope-launch-receipt", "-qa-scope-ready-receipt", "-qa-await-scope-gate"]
        let present = names.compactMap { values[$0] }
        if present.isEmpty { return nil }
        guard present.count == names.count else { throw LaunchArgumentError.incompleteScope }
        launchReceipt = URL(fileURLWithPath: present[0])
        readyReceipt = URL(fileURLWithPath: present[1])
        gate = URL(fileURLWithPath: present[2])
    }
}
