import re

def parse_version(file_path: str = 'td/td/telegram/Td.h'):
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
    print(parse_version())