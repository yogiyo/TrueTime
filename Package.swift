// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TrueTime",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "TrueTime",
            targets: ["TrueTime", "CTrueTime"]
        )
    ],
    targets: [
        .target(
            name: "CTrueTime",
            path: "Sources/CTrueTime",
            publicHeadersPath: "include"
        ),
        .target(
            name: "TrueTime",
            dependencies: ["CTrueTime"],
            path: "Sources/TrueTime"
        )
    ]
)
