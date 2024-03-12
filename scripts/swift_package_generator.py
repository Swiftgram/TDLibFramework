import argparse
import sys


def get_remote_target(url, checksum):
    return f'''            url: "{url}",
            checksum: "{checksum}"'''


def get_local_target(path):
    return f'''            path: "{path}"'''


def get_file_content(target):
    return f"""// swift-tools-version:5.3
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
{target}
        ),
        .testTarget(
            name: "TDLibFrameworkTests",
            dependencies: ["TDLibFrameworkWrapper"]
        ),
    ]
)
"""


def main(args):
    if args.url and args.checksum:
        target_content = get_remote_target(args.url, args.checksum)
    elif args.path:
        target_content = get_local_target(args.path)

    with open("Package.swift", "w") as f:
        f.write(get_file_content(target_content))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    remote_group = parser.add_argument_group("remote", "Describes remote package")
    remote_group.add_argument(
        "--url",
        help="Url of zipped xcframework",
    )
    remote_group.add_argument(
        "--checksum",
        help="Checksum of zip archive from `swift package compute-checksum <zip>`",
    )

    local_group = parser.add_argument_group("local", "Describes local package")
    local_group.add_argument("--path", help="Path to local xcframework")

    args = parser.parse_args()
    if args.path and (args.url or args.checksum):
        print("Please provide --url with --checksum or --path alone")
        sys.exit(1)

    if args.url and not args.checksum:
        print("Missing --cheksum")
        sys.exit(1)
    if args.checksum and not args.url:
        print("Missing --url")
        sys.exit(1)

    main(args)
