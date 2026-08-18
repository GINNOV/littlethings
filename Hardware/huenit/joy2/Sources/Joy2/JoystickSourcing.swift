public protocol JoystickSourcing: AnyObject, Sendable {
    func currentSample() -> JoystickSample
}

public final class FakeJoystick: JoystickSourcing, @unchecked Sendable {
    public var sample = JoystickSample(connected: false, direction: .center, leftFire: false, rightFire: false)
    public init() {}
    public func currentSample() -> JoystickSample { sample }
}
