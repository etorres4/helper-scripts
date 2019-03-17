#!/usr/bin/python3
"""Wrapper script for using dd to write to a USB drive."""

import argparse
import os
import pathlib
import re
import subprocess

# ========== Constants ==========
COMMENT_PATTERN = "^[#;]"
EXCLUDE_FILE = "/etc/helper-scripts/ddusb-exclude.conf"

E_BLOCKDEVICE_ERROR = 1
E_EXCLUDE_ERROR = 2
E_DD_ERROR = 3


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


# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument("-b", "--bs", default=512, help="block size", metavar="bs")
parser.add_argument("input_file", help="input file to write")
parser.add_argument("output_file", help="output block device")
args = parser.parse_args()

block_size = args.bs
input_file = args.input_file
block_path = args.output_file

# Ensure that block_path is really a block device
if not pathlib.Path(block_path).is_block_device():
    print(f'Error: "{block_path}" is not a block device')
    exit(E_BLOCKDEVICE_ERROR)

# Check if block_path is excluded
exclude_patterns = read_exclude_file(EXCLUDE_FILE)

for pattern in exclude_patterns:
    if re.fullmatch(pattern, block_path):
        print(f'Error: "{block_path}" is blacklisted from running dd')
        exit(E_EXCLUDE_ERROR)

print(f"Input file: {input_file}")
print(f"Block device: {block_path}")
print(f"Block size: {block_size}")

try:
    subprocess.run(
        [
            "dd",
            f"if={input_file}",
            f"of={block_path}",
            f"bs={block_size}",
            "status=progress",
        ],
        check=True,
    )
except subprocess.CalledProcessError:
    exit(E_DD_ERROR)
else:
    os.sync()
