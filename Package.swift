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
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.8.3-dc79b355/TDLibFramework.zip",
            checksum: "4d4db535eb30239c96a7281493571386aedb4f38c7ae182a0c3a42859d5af7f3"
        ),
    ]
)
