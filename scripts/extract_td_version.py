import re
import argparse

def parse_version(file_path: str) -> str:
    """
        Parse Tdlib version from header file
    """
    with open(file_path) as file:
        content = file.read()

        m = re.search("TDLIB_VERSION = \"(.*)\";", content)
        if m:
            return(m.group(1))
        else:
            raise ValueError("Unable to find TDLIB_VERSION in " + file_path)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("header_path", help="Path to td/td/telegram/Td.h header file")
    
    args = parser.parse_args()
    print(parse_version(args.header_path))