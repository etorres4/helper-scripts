#!/usr/bin/python3
"""Download audio using youtube-dl.

Dependencies:
=============
* youtube-dl
"""

import argparse
import pathlib
import subprocess

# =========== Constants ==========
YOUTUBE_DL_BIN = '/usr/bin/youtube-dl'
DEFAULT_FILENAME = f"{pathlib.Path.home()}/Music/%(title)s.%(ext)s"

# ========== Error Codes ==========
E_NOURLS = 2

# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument('-b', '--batchfile',
                    type=str,
                    nargs=1,
                    help='provide the links from a text file')
parser.add_argument('-f', '--format',
                    type=str,
                    default='opus',
                    help='the format to use')
parser.add_argument('-n', '--filename',
                    type=str,
                    help='downloaded filename (without extension)')
parser.add_argument('urls',
                    nargs='*',
                    help='video URLs')
args = parser.parse_args()

dl_opts = [YOUTUBE_DL_BIN,
           '--no-part',
           '--no-continue',
           '--extract-audio',
           '--audio-format={args.format}']

# filename handling
# if -b is used, DEFAULT_FILENAME must take precedence
if args.filename:
    dl_opts.append('--output={args.filename}')
else:
    dl_opts.append('--output={DEFAULT_FILENAME}')

# URL handling
if args.batchfile:
    dl_opts.append(f"--batch-file={args.batchfile}")
elif not args.urls:
    print("URLs are required")
    exit(E_NOURLS)
else:
    dl_opts.extend(args.urls)

subprocess.run(dl_opts)
