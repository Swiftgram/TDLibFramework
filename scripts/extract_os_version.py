import argparse
import re
import os


def main(platform):
    # read the manifest file
    script_dir = os.path.dirname(os.path.realpath(__file__))
    manifest_path = os.path.join(script_dir, "../Package.swift")
    with open(manifest_path) as f:
        manifest_source = f.read()
    platform = platform.replace("-simulator", "")
    # extract the platform version
    pattern = r"\." + platform + r"\(\.v([\d_]+)\)"
    match = re.search(pattern, manifest_source)
    if match:
        version = match.group(1).replace("_", ".")
        if len(version.split(".")) == 1:
            version += ".0"
        return version
    else:
        if platform == "visionOS":
            return "1.0"
        raise ValueError(f"Could not find {platform} version in Package.swift")


if __name__ == "__main__":
    # parse command-line arguments
    parser = argparse.ArgumentParser(
        description="Extract minimum platform versions from Package.swift"
    )
    parser.add_argument(
        "platform",
        choices=[
            "iOS",
            "iOS-simulator",
            "macOS",
            "watchOS",
            "watchOS-simulator",
            "tvOS",
            "tvOS-simulator",
            "visionOS",
            "visionOS-simulator"
        ],
        help="the platform to extract the minimum version for",
    )
    args = parser.parse_args()

    # call the main function
    print(main(args.platform), end="")
