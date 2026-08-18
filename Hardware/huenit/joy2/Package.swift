// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Joy2",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "Joy2", targets: ["Joy2"]),
        .executable(name: "Joy2App", targets: ["Joy2App"]),
    ],
    dependencies: [
        .package(path: "../joy1"),
    ],
    targets: [
        .target(name: "Joy2"),
        .executableTarget(
            name: "Joy2App",
            dependencies: [
                "Joy2",
                .product(name: "Joy1", package: "joy1"),
            ],
            exclude: ["App/Joy2App.entitlements"]
        ),
        .testTarget(
            name: "Joy2Tests",
            dependencies: [
                "Joy2",
                .product(name: "Joy1", package: "joy1"),
            ]
        ),
    ]
)
