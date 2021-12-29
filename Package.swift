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
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.7.12-29e8df51/TDLibFramework.zip",
            checksum: "eaf93a0103f11b70c7f0aafaa30aa6cf8029a7641f8cf563e2243817d860465d"
        ),
    ]
)
