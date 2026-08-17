import Foundation

public actor PoseMonitor {
    private let arm: HuenitArm
    private let state = MonitorState()

    public init(arm: HuenitArm) {
        self.arm = arm
    }

    public func start(onUpdate: @escaping @Sendable (Result<ArmPose, Error>) async -> Void) {
        state.cancel()
        let arm = self.arm
        let task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                if Task.isCancelled { break }
                do {
                    let pose = try await arm.queryPose()
                    await onUpdate(.success(pose))
                } catch {
                    await onUpdate(.failure(error))
                }
            }
        }
        state.set(task)
    }

    public func stop() {
        state.cancel()
    }

    nonisolated public func cancel() {
        state.cancel()
    }
}

final class MonitorState: @unchecked Sendable {
    private let lock = NSLock()
    private var task: Task<Void, Never>?

    var isRunning: Bool {
        lock.lock()
        defer { lock.unlock() }
        return task != nil
    }

    func set(_ task: Task<Void, Never>) {
        lock.lock()
        self.task = task
        lock.unlock()
    }

    func cancel() {
        lock.lock()
        let task = self.task
        self.task = nil
        lock.unlock()
        task?.cancel()
    }
}
