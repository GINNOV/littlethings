// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Joy1",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Joy1", targets: ["Joy1"]),
        .library(name: "Joy1UI", targets: ["Joy1UI"]),
        .executable(name: "Joy1App", targets: ["Joy1App"]),
    ],
    targets: [
        .target(name: "Joy1"),
        .target(
            name: "Joy1UI",
            dependencies: ["Joy1"],
            path: "Sources/Joy1UI"
        ),
        .executableTarget(
            name: "Joy1App",
            dependencies: ["Joy1", "Joy1UI"],
            exclude: ["App/Joy1App.entitlements"]
        ),
        .testTarget(name: "Joy1Tests", dependencies: ["Joy1"]),
    ]
)
