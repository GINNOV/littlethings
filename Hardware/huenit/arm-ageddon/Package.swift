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
        .testTarget(
            name: "ArmageddonCoreTests",
            dependencies: ["ArmageddonCore", "ArmageddonMotionBoundary"],
            swiftSettings: strictConcurrency
        ),
    ],
    swiftLanguageModes: [.v6]
)
