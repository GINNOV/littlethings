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
                "build",
                "AmigaPlayground.app",
                "AmigaPlaygroundTests",
                "AmigaPlayground.xcodeproj"
            ]
        ),
        .testTarget(
            name: "AmigaPlaygroundTests",
            dependencies: ["AmigaPlayground"],
            path: "AmigaPlaygroundTests"
        )
    ]
)
