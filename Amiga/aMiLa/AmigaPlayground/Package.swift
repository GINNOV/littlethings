// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AmigaPlayground",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.7.1")
    ],
    targets: [
        .executableTarget(
            name: "AmigaPlayground",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: ".",
            exclude: [
                ".build",
                ".codex",
                "AGENTIC_AMIGA_CODE_PRODUCER_GOAL.md",
                "App/Info.plist",
                "Assets.xcassets",
                "aMiLa",
                "build",
                "docs",
                "AmigaPlaygroundTests",
                "AmigaPlaygroundUITests",
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
