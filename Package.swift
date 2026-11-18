// swift-tools-version:5.9
// DO NOT EDIT! Generated automatically. See scripts/swift_package_generator.py
import PackageDescription


let package = Package(
    name: "TDLibFramework",
    platforms: [
        // Oldest deployment targets supported by Xcode 27
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v9),
        .tvOS(.v15), // Synced with iOS
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
            url: "https://github.com/Swiftgram/TDLibFramework/releases/download/1.8.70-fe61d641/TDLibFramework.zip",
            checksum: "3ffb7c0cc7bbd5613f6be7e46521679a4a0bda368e96d75e291ae47eeeb787b5"
        ),
        .testTarget(
            name: "TDLibFrameworkTests",
            dependencies: ["TDLibFrameworkWrapper"]
        ),
    ]
)
