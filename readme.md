# The Gist

There's no library on GitHub for reading IFF built in Swift. I found a portable [library](https://github.com/svanderburg/libiff/tree/master) (thank you!) and from there suffered from making it working in Swift. I won, painfully because I didn't have the proper experience to deal with the layout of the files.

## Setup
1. `chmod +x setup.sh`
2. `./setup`

it will downlaod the dependencies from github and create the correct folder structure for compiling correctly

Then you have two options to build it, depends from you target's type.

## Option One
Build a command line app. There's a test app associate in the package. It reads and process an Amiga IFF file.

You can try by using:
`swift run TestApp`

```swift
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
```

## Option Two
You can build a **static library** by using the default Package.swift

Or you can replace that with the one below to build a static library.
To build just run

`swift build --product CILBM --configuration release` 

from the root and look in the folder `.build/arm64-apple-macosx/release` for the compiled product.

```Swift
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
```

In theory you can import the package directly in XCode but I wasn't able to resolve some paths issue, and I tried hard. Nonetheless, importing the framework in a new project worked and from there you building the usual C-Bridge file and the rest is downhill.

I hope it saves a lot of time to future mes.
