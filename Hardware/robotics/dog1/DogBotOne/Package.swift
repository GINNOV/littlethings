// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DogBotProtocol",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "DogBotProtocol", targets: ["DogBotProtocol"]),
    ],
    targets: [
        .target(
            name: "DogBotProtocol",
            path: "DogBotOne",
            exclude: [
                "AppSound.swift",
                "Assets.xcassets",
                "ContentView.swift",
                "DogBotOneApp.swift",
                "RemoteView.swift",
            ],
            sources: ["RobotCommand.swift"]
        ),
        .testTarget(
            name: "DogBotProtocolTests",
            dependencies: ["DogBotProtocol"],
            path: "ProtocolTests/Tests"
        ),
    ]
)
