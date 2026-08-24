public enum NativeCameraSelectionPolicy {
    public static func preferredUniqueID(
        discovered: [NativeCameraDevice],
        restored: DeviceIdentity?,
        current: DeviceSelection
    ) -> String? {
        let identifiers = Set(discovered.map(\.stableIdentifier))
        if case .selected(.nativeCamera(let selected)) = current, identifiers.contains(selected) {
            return selected
        }
        if case .nativeCamera(let restoredID) = restored, identifiers.contains(restoredID) {
            return restoredID
        }
        if case .stale = current {
            return nil
        }
        if discovered.count == 1 {
            return discovered[0].stableIdentifier
        }
        return nil
    }
}
