import ArmageddonCore

struct DeterministicMonotonicClock: Sendable {
    private let instants: [MonotonicInstant]
    private var index = 0

    init(nanoseconds: [UInt64]) {
        instants = nanoseconds.map(MonotonicInstant.init)
    }

    mutating func now() throws -> MonotonicInstant {
        guard index < instants.count else { throw DeterministicProviderError.exhausted }
        defer { index += 1 }
        return instants[index]
    }
}

enum DeterministicProviderError: Error {
    case exhausted
}
