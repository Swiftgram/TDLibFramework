// swift-tools-version:5.3
// DO NOT EDIT! Generated automatically. See scripts/swift_package_generator.py
import PackageDescription


let package = Package(
    name: "TDLibFramework",
    platforms: [
        // Minimum versions for openssl - td/example/ios/Python-Apple-support/Makefile
        .iOS(.v12),
        .macOS(.v10_15),
        .watchOS(.v4),
        .tvOS(.v12), // Synced with iOS, but actually v9
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
            url: "https://github.com/moderato-app/TDLibFramework/releases/download/1.8.48-b6303f0c/TDLibFramework.zip",
            checksum: "133454db612e8bb25eeff0bbe70a44218e667c3df4d72430aed9dd3f95d4b848"
        ),
        .testTarget(
            name: "TDLibFrameworkTests",
            dependencies: ["TDLibFrameworkWrapper"]
        ),
    ]
)
