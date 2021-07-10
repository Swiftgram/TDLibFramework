import argparse

def get_file_content(url, checksum):
    return f"""// swift-tools-version:5.3
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
            url: "{url}",
            checksum: "{checksum}"
        ),
    ]
)
"""

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("url", help="Url to zipped xcframework")
    parser.add_argument("checksum", help="Checksum of zip archive from `swift package compute-checksum <zip>`")
    
    args = parser.parse_args()
    with open('Package.swift', 'w') as f:
        f.write(get_file_content(args.url, args.checksum))