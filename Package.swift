// swift-tools-version:5.3
// DO NOT EDIT! Generated automatically. See scripts/swift_package_generator.py
import PackageDescription


let package = Package(
    name: "TDLibFramework",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12),
        .watchOS(.v2), // Based on iOS 9 version
        .tvOS(.v9) // Based on iOS 9 version
    ],
    products: [
        .library(
            name: "TDLibFramework",
            targets: ["TDLibFramework"]
        )
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "TDLibFramework",
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.7.11-d4f5e672/TDLibFramework.zip",
            checksum: "dcbb74a077ae24bb8bbd2b7e1043f9732c84195d7181e8a7aa7a7418f5051646"
        ),
    ]
)
