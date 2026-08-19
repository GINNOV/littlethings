public protocol NativeCameraDiscovery: Sendable {
    func discover() async -> [NativeCameraDevice]
}

public protocol SerialDeviceDiscovery: Sendable {
    func discover() async -> [SerialDevice]
}

public actor DeterministicNativeCameraDiscovery: NativeCameraDiscovery {
    private var cameras: [NativeCameraDevice]

    public init(cameras: [NativeCameraDevice]) {
        self.cameras = cameras
    }

    public func discover() async -> [NativeCameraDevice] {
        cameras
    }

    public func setCameras(_ cameras: [NativeCameraDevice]) {
        self.cameras = cameras
    }
}

public actor DeterministicSerialDeviceDiscovery: SerialDeviceDiscovery {
    private var devices: [SerialDevice]

    public init(devices: [SerialDevice]) {
        self.devices = devices
    }

    public func discover() async -> [SerialDevice] {
        devices
    }

    public func setDevices(_ devices: [SerialDevice]) {
        self.devices = devices
    }
}
