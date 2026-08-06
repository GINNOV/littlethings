// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AmigaPlayground",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MLXServerHelper", targets: ["MLXServerHelper"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MLXServerHelper",
            path: "Helpers/MLXServerHelper"
        ),
        .executableTarget(
            name: "AmigaPlayground",
            dependencies: [],
            path: ".",
            exclude: [
                ".build",
                ".codex",
                "build",
                "Helpers",
                "AmigaPlayground.app",
                "Amiga Playground.app",
                "AmigaPlaygroundTests",
                "AmigaPlaygroundUITests",
                "AmigaPlayground.xcodeproj",
                "script",
                "distribution",
                "tutorials",
                "Resources/tutorials",
                "AGENTIC_AMIGA_CODE_PRODUCER_GOAL.md"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AmigaPlaygroundTests",
            dependencies: ["AmigaPlayground"],
            path: "AmigaPlaygroundTests"
        )
    ]
)
