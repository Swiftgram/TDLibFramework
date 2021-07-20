// swift-tools-version:5.3
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
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.7.5-c45535d/TDLibFramework.zip",
            checksum: "dab28d2fc10a76ca7fa71d02a9e3e13ff45ccba7d64fbceede68ee87d144a38f"
        ),
    ]
)
