struct AppActions {
    let navigate: @MainActor (AppDestination) -> Void
    let requestRecovery: @MainActor () -> Void
    let stop: @MainActor () -> Void
}
