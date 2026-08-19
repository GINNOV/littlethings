public actor DeviceCatalog {
    private let nativeCameraDiscovery: any NativeCameraDiscovery
    private let serialDeviceDiscovery: any SerialDeviceDiscovery
    private var records: [DeviceIdentity: DeviceRecord] = [:]
    private var currentSelection: DeviceSelection = .none

    public init(
        nativeCameraDiscovery: any NativeCameraDiscovery,
        serialDeviceDiscovery: any SerialDeviceDiscovery
    ) {
        self.nativeCameraDiscovery = nativeCameraDiscovery
        self.serialDeviceDiscovery = serialDeviceDiscovery
    }

    public func refresh() async -> [DeviceEvent] {
        let discoveredNative = await nativeCameraDiscovery.discover()
        let discoveredSerial = await serialDeviceDiscovery.discover()
        var next: [DeviceIdentity: DeviceRecord] = [:]

        for camera in discoveredNative {
            let record = DeviceRecord.nativeCamera(
                stableIdentifier: camera.stableIdentifier,
                permission: camera.permission
            )
            next[record.identity] = record
        }
        for device in discoveredSerial {
            let record: DeviceRecord
            switch device.role {
            case .camera:
                record = .serialCamera(serialNumber: device.serialNumber, registryPath: device.registryPath)
            case .arm:
                record = .arm(serialNumber: device.serialNumber, registryPath: device.registryPath)
            }
            next[record.identity] = record
        }

        let removed = records.keys.filter { next[$0] == nil }.sorted { String(describing: $0) < String(describing: $1) }
        let added = next.keys.filter { records[$0] == nil }.sorted { String(describing: $0) < String(describing: $1) }
        var events = removed.map(DeviceEvent.removed)
        events.append(contentsOf: added.compactMap { next[$0] }.map(DeviceEvent.added))
        records = next

        if case let .selected(identity) = currentSelection, records[identity] == nil {
            currentSelection = .stale(identity)
            events.append(.selectionBecameStale(identity))
        }
        if case let .stale(identity) = currentSelection, records[identity] != nil {
            currentSelection = .selected(identity)
            events.append(.selectionRecovered(identity))
        }
        return events
    }

    public func devices() -> [DeviceRecord] {
        records.values.sorted { String(describing: $0.identity) < String(describing: $1.identity) }
    }

    public func select(_ identity: DeviceIdentity) throws {
        guard records[identity] != nil else {
            throw DeviceSelectionError.unavailable(identity)
        }
        currentSelection = .selected(identity)
    }

    public func selection() -> DeviceSelection {
        currentSelection
    }
}
