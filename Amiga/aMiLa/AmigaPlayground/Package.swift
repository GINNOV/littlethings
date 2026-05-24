// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AmigaPlayground",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AmigaPlayground",
            dependencies: [],
            path: ".",
            exclude: [
                ".build",
                ".codex",
                "build",
                "AmigaPlayground.app",
                "AmigaPlaygroundTests",
                "AmigaPlayground.xcodeproj",
                "Helpers",
                "script"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "MLXServerHelper",
            dependencies: [],
            path: "Helpers/MLXServerHelper"
        ),
        .testTarget(
            name: "AmigaPlaygroundTests",
            dependencies: ["AmigaPlayground"],
            path: "AmigaPlaygroundTests"
        )
    ]
)
