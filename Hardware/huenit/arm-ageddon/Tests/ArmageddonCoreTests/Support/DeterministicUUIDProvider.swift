import Foundation

struct DeterministicUUIDProvider: Sendable {
    private let values: [UUID]
    private var index = 0

    init(values: [UUID]) {
        self.values = values
    }

    mutating func next() throws -> UUID {
        guard index < values.count else { throw DeterministicProviderError.exhausted }
        defer { index += 1 }
        return values[index]
    }
}
