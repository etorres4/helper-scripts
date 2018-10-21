#!/usr/bin/env python
"""Download audio using youtube-dl, passing
   a specific set of options specified by the user.
=====
Usage
=====
>>> dlaudio -f flac -n something "www.youtube.com"
"""

import argparse
import pathlib
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--batch-dl',
                    dest='batchfile',
                    type=str,
                    help='provide the links from a text file')
parser.add_argument('-f', '--format',
                    type=str,
                    default='ogg',
                    help='the format to use (default:ogg)')
parser.add_argument('-n', '--filename',
                    type=str,
                    help='the name of the downloaded file (without extension)')
parser.add_argument('urls',
                    nargs='*',
                    help='video URLs')
args = parser.parse_args()

default_filename = f"{pathlib.Path.home()}/Music/%(title)s.%(ext)s"

dl_opts = []
dl_opts.append('--no-part')
dl_opts.append('--no-continue')
dl_opts.append('--extract-audio')
dl_opts.append(f"--audio-format={args.format}")

dl_opts.append(f"--output={args.filename}")

# filename handling
# -b and -n should not be used together
if args.filename and args.batchfile:
    print('Ignoring --batch-dl and --filename')
    dl_opts.append(f"--output={default_filename}")
elif args.filename:
    dl_opts.append(f"--output={pathlib.Path.home()}/Music/{args.filename}.%(ext)s")
else:
    dl_opts.append(f"--output={default_filename}")

# URL handling
if args.batchfile:
    dl_opts.append(f"--batch-file={args.batchfile}")
elif len(args.urls) == 0:
    print("URLs are required")
    exit(2)
else:
    dl_opts += args.urls

dl = subprocess.run(['youtube-dl'].extend(dl_opts))
