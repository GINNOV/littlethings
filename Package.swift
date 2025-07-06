// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CILBM",
    products: [
        // This defines the single library product for this package.
        // It correctly targets "libilbm", which is the top-level library,
        // and explicitly declares its type as static.
        .library(
            name: "CILBM",
            type: .static,
            targets: ["libilbm"]),
    ],
    targets: [
        // This target builds the libiff C library. It has no dependencies.
        .target(
            name: "libiff",
            dependencies: []
        ),
        // This target builds the libilbm C library.
        // It correctly declares its dependency on "libiff".
        .target(
            name: "libilbm",
            dependencies: ["libiff"]
        )
    ]
)