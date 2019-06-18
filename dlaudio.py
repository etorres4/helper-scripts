#!/usr/bin/python3
"""Download audio using youtube-dl.

Dependencies:
=============

* youtube-dl
"""

import argparse
from pathlib import Path
import subprocess

# =========== Constants ==========
YOUTUBE_DL_BIN = "/usr/bin/youtube-dl"
DEFAULT_FILENAME = f"{Path.home() / 'Music'}/%(title)s.%(ext)s"
DEFAULT_YOUTUBE_DL_OPTS = (
    "--no-part",
    "--audio-quality=0",
    "--no-continue",
    "--extract-audio",
)

# ----- Error Codes -----
E_NOURLS = 2


# ========== Functions ==========
def parse_cmdline_arguments(**kwargs):
    """Parse command line arguments passed to the script.
        All kwargs are passed to ArgumentParser.parse_args().

    :rtype: argparse.Namespace object
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--batchfile", help="provide the links from a text file")
    parser.add_argument(
        "-f", "--format", type=str, default="opus", help="the format to use"
    )
    parser.add_argument(
        "-n", "--filename", type=str, help="downloaded filename (without extension)"
    )
    parser.add_argument("urls", nargs="*", help="video URLs")

    return parser.parse_args()


# ========== Main Script ==========
if __name__ == "__main__":
    args = parse_cmdline_arguments()

    dl_opts = [
        YOUTUBE_DL_BIN,
        *DEFAULT_YOUTUBE_DL_OPTS,
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
