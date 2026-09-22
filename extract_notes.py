#! /usr/bin/env python3

import fileinput

if __name__ == "__main__":
    for line in fileinput.input():
        if line.startswith("%"):
            text = line[2:].rstrip()
            if text.startswith('#'):
                text = '#' + text
            print(text)

        elif line.startswith('"') and line.strip().endswith('";'):
            print('#', line[1:-3])
            print()

        elif line.startswith('vardef') and line.strip().endswith('='):
            heading = line[7:-3].strip().lower()
            heading = "`" + heading.replace('expr ', '') + "`"
            print()
            print('##', heading)



