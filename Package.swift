// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-nanoid",
    products: [
        .library(name: "NanoID", targets: ["NanoID"]),
    ],
    targets: [
        .target(name: "NanoID"),
        .testTarget(
            name: "NanoIDTests",
            dependencies: [
                .target(name: "NanoID"),
            ]
        ),
    ]
)
