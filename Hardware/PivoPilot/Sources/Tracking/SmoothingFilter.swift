import Foundation

final class SmoothingFilter {
    private(set) var value: Double = 0
    private let alpha: Double
    private var hasValue = false

    init(alpha: Double = 0.15) {
        self.alpha = alpha
    }

    func reset() {
        value = 0
        hasValue = false
    }

    func update(_ input: Double) -> Double {
        if !hasValue {
            value = input
            hasValue = true
            return value
        }

        value = alpha * input + (1 - alpha) * value
        return value
    }
}
