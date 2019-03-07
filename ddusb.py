#!/usr/bin/python3
"""Write an ISO image to a usb drive using dd."""

import argparse
import pathlib
import subprocess

# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument("-b", "--bs", default=512, help="block size", metavar="bs")
parser.add_argument("input_file", help="input file to write")
parser.add_argument("output_file", help="output block device")
args = parser.parse_args()

block_size = args.bs
input_file = args.input_file
block_device = args.output_file

if not pathlib.Path(block_device).is_block_device():
    print(f"Error: {block_device} is not a block device")
    exit(1)

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
    exit(1)
else:
    subprocess.run(["sync"])
