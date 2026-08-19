actor PoseMonitor {
    private let arm: HuenitArm
    private var task: Task<Void, Never>?

    init(arm: HuenitArm) {
        self.arm = arm
    }

    func start(onUpdate: @escaping @Sendable (Result<ArmPose, Error>) async -> Void) {
        task?.cancel()
        let arm = self.arm
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                if Task.isCancelled { break }
                do {
                    await onUpdate(.success(try await arm.queryPose()))
                } catch is CancellationError {
                    break
                } catch {
                    if Task.isCancelled { break }
                    await onUpdate(.failure(error))
                }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    var isRunning: Bool { task != nil }
}
