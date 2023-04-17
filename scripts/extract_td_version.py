import re
import argparse


def parse_version(file_path: str) -> str:
    """
    Parse Tdlib version from CmakeLists.txt file
    """
    with open(file_path) as file:
        content = file.read()

        m = re.search("project\(TDLib VERSION (.*) LANGUAGES CXX C\)", content)
        if m:
            return m.group(1)
        else:
            raise ValueError("Unable to find TDLIB VERSION in " + file_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source_path", help="Path to td/CMakeLists.txt souce file")

    args = parser.parse_args()
    print(parse_version(args.source_path), end="")
