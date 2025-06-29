// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftLibIFF",
    products: [
        .library(
            name: "SwiftLibIFF",
            targets: ["SwiftLibIFF"]
        ),
    ],
    targets: [
        // C library target
        .target(
            name: "Clibiff",
            path: "Sources/Clibiff/src/libiff", // <-- Set the target path to the root of the C library
            exclude: [
                // Excludes are now relative to the new path
                "Makefile.am",
                "libiff.vcxproj",
                "libiff.vcxproj.filters",
                "libiff.def"
            ],
            publicHeadersPath: "include", // <-- Public headers are in the 'include' subdirectory
            cSettings: [
                // This allows C files to find their own headers via #include "iff.h"
                .headerSearchPath("include"),
                .define("HAVE_CONFIG_H"),
                .unsafeFlags(["-Wno-unused-command-line-argument"])
            ]
        ),
        
        // Swift wrapper target
        .target(
            name: "SwiftLibIFF",
            dependencies: ["Clibiff"],
            path: "Sources/SwiftLibIFF"
        ),
        
        // Test target
        .testTarget(
            name: "SwiftLibIFFTests",
            dependencies: ["SwiftLibIFF"]
        )
    ]
)
