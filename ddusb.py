#!/usr/bin/python3
"""Write an ISO image to a usb drive using dd."""

import argparse
import glob
import pathlib
import re
import subprocess

# ========== Constants ==========
COMMENT_PATTERN = "[#;]"
EXCLUDE_FILE = "/etc/helper-scripts/ddusb-exclude.conf"


# ========== Functions ==========
def read_exclude_file(exclude_file):
    """Read and return a list of exclusion paths/globs,
       removing any lines that begin with COMMENT_PATTERN.

    :param exclude_file: path to the exclusion file
    :type exclude_file: str, bytes, or path-like object
    :returns: a list containing non-commented lines from the
        exclusion file
    :rtype: list
    """
    with open(exclude_file, "r") as excludes:
        lines = [
            l.strip("\n")
            for l in excludes.readlines()
            if not re.match(COMMENT_PATTERN, l)
        ]

    return lines


def expand_globs(*globs):
    """For each glob given, expand these globs and return a list
    containing each glob expanded.

    :param globs: patterns to expand
    :type globs: str
    :returns: all expanded globs aggregated together
    :rtype: list
    """
    expanded_globs = []

    for line in globs:
        expanded_globs.extend(glob.glob(line, recursive=True))

    return expanded_globs


# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument("-b", "--bs", default=512, help="block size", metavar="bs")
parser.add_argument("input_file", help="input file to write")
parser.add_argument("output_file", help="output block device")
args = parser.parse_args()

block_size = args.bs
input_file = args.input_file
block_device = args.output_file

# Ensure that block_device is really a block device
if not pathlib.Path(block_device).is_block_device():
    print(f'Error: "{block_device}" is not a block device')
    exit(1)

# Check if block_device is excluded
exclude_patterns = read_exclude_file(EXCLUDE_FILE)
device_blacklist = expand_globs(*exclude_patterns)

if block_device in device_blacklist:
    print(f'Error: "{block_device}" is blacklisted from running dd')
    exit(2)

print(f"Input file: {input_file}")
print(f"Block device: {block_device}")
print(f"Block size: {block_size}")

try:
    subprocess.run(
        [
            "dd",
            f"if={input_file}",
            f"of={block_device}",
            f"bs={block_size}",
            "status=progress",
        ],
        check=True,
    )
except subprocess.CalledProcessError:
    exit(3)
else:
    subprocess.run("sync")
