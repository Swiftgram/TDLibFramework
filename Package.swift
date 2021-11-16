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
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.7.9-c2c49ebc/TDLibFramework.zip",
            checksum: "3ee579df09a290e4de67f70bf44cb8e49ae78faaed34185c00c074531623b9a9"
        ),
    ]
)
