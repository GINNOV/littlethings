// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CILBM",
    products: [
        .library(
            name: "CILBM",
            targets: ["libilbm"]),
        .executable(
            name: "TestApp",
            targets: ["TestApp"])
    ],
    targets: [
        // Because the files are now in a conventional layout (headers in an
        // "include" subdirectory), SPM requires no extra configuration.
        // It will automatically find the headers and handle dependency linking.
        .target(
            name: "libiff",
            dependencies: []
        ),
        .target(
            name: "libilbm",
            dependencies: ["libiff"]
        ),
        .executableTarget(
            name: "TestApp",
            dependencies: ["libilbm"]
        )
    ]
)
