import Dispatch

protocol PriorityStopTransport: Sendable {
    func urgentWrite(_ frame: StopFrame, deadlineNanoseconds: UInt64) async -> UrgentWriteOutcome
}

protocol MonotonicStopClock: Sendable {
    func nowNanoseconds() -> UInt64
}

struct ContinuousStopClock: MonotonicStopClock {
    func nowNanoseconds() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }
}
