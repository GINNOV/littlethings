// swift-tools-version: 6.2

import PackageDescription

let strictConcurrency: [SwiftSetting] = [
    .unsafeFlags(["-strict-concurrency=complete"]),
]

let package = Package(
    name: "Armageddon",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "ArmageddonCore", targets: ["ArmageddonCore"]),
        .executable(name: "RuntimeTraceProbe", targets: ["RuntimeTraceProbe"]),
        .executable(name: "SandboxLogProbe", targets: ["SandboxLogProbe"]),
        .executable(name: "ModelFixtureGenerator", targets: ["ModelFixtureGenerator"]),
        .executable(name: "ModelRegistryQAProbe", targets: ["ModelRegistryQAProbe"]),
        .executable(name: "CaptureQAProbe", targets: ["CaptureQAProbe"]),
        .executable(name: "DetectorQAProbe", targets: ["DetectorQAProbe"]),
        .executable(name: "VisionInferenceQAProbe", targets: ["VisionInferenceQAProbe"]),
        .executable(name: "PerformanceTelemetryQAProbe", targets: ["PerformanceTelemetryQAProbe"]),
        .executable(name: "HuenitCameraProbe", targets: ["HuenitCameraProbe"]),
    ],
    targets: [
        .target(
            name: "ArmageddonCore",
            swiftSettings: strictConcurrency
        ),
        .target(
            name: "ArmageddonMotionBoundary",
            dependencies: ["ArmageddonCore"],
            swiftSettings: strictConcurrency
        ),
        .target(
            name: "ArmageddonCaptureAdapter",
            dependencies: ["ArmageddonCore"],
            path: "Sources/ArmageddonApp",
            sources: [
                "Camera/AVFoundationNativeCaptureSession.swift",
                "Live/LivePreviewModel.swift",
            ],
            swiftSettings: strictConcurrency,
            linkerSettings: [.linkedFramework("AVFoundation")]
        ),
        .target(
            name: "EvidenceProbeSupport",
            path: "Tools/EvidenceProbeSupport",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "RuntimeTraceProbe",
            dependencies: ["EvidenceProbeSupport"],
            path: "Tools/RuntimeTraceProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "SandboxLogProbe",
            dependencies: ["EvidenceProbeSupport"],
            path: "Tools/SandboxLogProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "ModelFixtureGenerator",
            path: "Tools/ModelFixtures",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "ModelRegistryQAProbe",
            dependencies: ["ArmageddonCore"],
            path: "Tools/ModelRegistryQAProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "CaptureQAProbe",
            dependencies: ["ArmageddonCore", "ArmageddonCaptureAdapter"],
            path: "Tools/CaptureQAProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "DetectorQAProbe",
            dependencies: ["ArmageddonCore"],
            path: "Tools/DetectorQAProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "VisionInferenceQAProbe",
            dependencies: ["ArmageddonCore"],
            path: "Tools/VisionInferenceQAProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "PerformanceTelemetryQAProbe",
            dependencies: ["ArmageddonCore"],
            path: "Tools/PerformanceTelemetryQAProbe",
            swiftSettings: strictConcurrency
        ),
        .executableTarget(
            name: "HuenitCameraProbe",
            dependencies: ["ArmageddonCore"],
            path: "Tools/HuenitCameraProbe",
            swiftSettings: strictConcurrency
        ),
        .testTarget(
            name: "ArmageddonCoreTests",
            dependencies: ["ArmageddonCore", "ArmageddonMotionBoundary"],
            resources: [.copy("Fixtures")],
            swiftSettings: strictConcurrency
        ),
    ],
    swiftLanguageModes: [.v6]
)
