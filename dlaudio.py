#!/usr/bin/python3
"""Download audio using youtube-dl.

Dependencies:
=============
* youtube-dl
"""

import argparse
import pathlib
import shutil
import subprocess

# =========== Constants ==========
YOUTUBE_DL_BIN = shutil.which("youtube-dl")
DEFAULT_FILENAME = f"{pathlib.Path.home()}/Music/%(title)s.%(ext)s"

# ========== Error Codes ==========
E_NOURLS = 2

# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument("-b", "--batchfile", help="provide the links from a text file")
parser.add_argument(
    "-f", "--format", type=str, default="opus", help="the format to use"
)
parser.add_argument(
    "-n", "--filename", type=str, help="downloaded filename (without extension)"
)
parser.add_argument("urls", nargs="*", help="video URLs")
args = parser.parse_args()

dl_opts = [
    YOUTUBE_DL_BIN,
    "--no-part",
    "--no-continue",
    "--extract-audio",
    f"--audio-format={args.format}",
]

# filename handling
# if -b is used, DEFAULT_FILENAME must take precedence
if args.filename is not None and args.batchfile is None:
    dl_opts.append(f"--output={args.filename}")
else:
    dl_opts.append(f"--output={DEFAULT_FILENAME}")

# URL handling
if args.batchfile is not None:
    dl_opts.append(f"--batch-file={args.batchfile}")
elif args.urls is not None:
    dl_opts.extend(args.urls)
else:
    print("URLs are required")
    exit(E_NOURLS)

subprocess.run(dl_opts)
