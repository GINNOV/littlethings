// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Joy1",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Joy1", targets: ["Joy1"]),
        .executable(name: "Joy1App", targets: ["Joy1App"]),
    ],
    targets: [
        .target(name: "Joy1"),
        .executableTarget(name: "Joy1App", dependencies: ["Joy1"]),
        .testTarget(name: "Joy1Tests", dependencies: ["Joy1"]),
    ]
)
