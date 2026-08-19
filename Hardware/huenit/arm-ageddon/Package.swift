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
        .testTarget(
            name: "ArmageddonCoreTests",
            dependencies: ["ArmageddonCore", "ArmageddonMotionBoundary"],
            swiftSettings: strictConcurrency
        ),
    ],
    swiftLanguageModes: [.v6]
)
