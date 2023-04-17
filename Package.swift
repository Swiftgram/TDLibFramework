// swift-tools-version:5.3
// DO NOT EDIT! Generated automatically. See scripts/swift_package_generator.py
import PackageDescription


let package = Package(
    name: "TDLibFramework",
    platforms: [
        // Minimum versions as of Xcode 14.2
        // Keep in sync with DEPLOYMENT_TARGET in builder/Project.swift
        .iOS(.v11),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "TDLibFramework",
            targets: ["TDLibFrameworkWrapper"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TDLibFrameworkWrapper",
            dependencies: [.target(name: "TDLibFramework")],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("z"),
            ]
        ),
        .binaryTarget(
            name: "TDLibFramework",
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.8.11-1543c41f/TDLibFramework.zip",
            checksum: "fc4a37505c7c0858e67e8d636479a8f8d3e725de1c67a78480e61901cbde6ec0"
        ),
        .testTarget(
            name: "TDLibFrameworkTests",
            dependencies: ["TDLibFrameworkWrapper"]
        ),
    ]
)
