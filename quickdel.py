#!/usr/bin/env python3
"""
quickdel - delete any file matching a query

Dependencies
============
* fd
* python-termcolor

Command-Line Arguments
======================
* -d, --directories-only
* -D, --directory       TODO: implement this
* -e, --empty-only
* -E, --extension
* -f, --files-only
* -F, --force-directory-delete
* -i, --no-ignore
* -I, --no-ignore-vcs
* -l, --links-only
"""

import argparse
import os
import os.path
import re
import shutil
import subprocess

from termcolor import colored

# ========== Constants ==========
FD_BIN = shutil.which("fd")
FD_OPTS = ["--hidden"]
# Matches 'y' or 'yes' only, ignoring case
USER_RESPONSE_YES = r"^[Yy]{1}([Ee]{1}[Ss]{1})?$"

E_NO_RESULTS = 1
E_USER_RESPONSE_NO = 2
E_INPUT_INTERRUPTED = 3


# ========== Functions ==========
def color_file(filename):
    """Return correct color code for filetype of filename.

    Example
    -------
    >>> color_file('Test File', 'red')
    '\x1b[31mTest String\x1b[0m'

    :param filename: file to determine color output for
    :type filename: str
    :return: filename with ANSII escape codes for color
    :rtype: str
    """
    if os.path.isdir(filename):
        return colored(filename, "blue")
    elif os.path.islink(filename):
        return colored(filename, "green")
    else:
        return filename


# ========== Main Script ==========
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-d",
        "--directories-only",
        action="store_const",
        const=["--type", "directory"],
        dest="fd_extra_opts",
        help="filter results to directories",
    )
    parser.add_argument(
        "-e",
        "--empty-only",
        action="store_const",
        const=["--type", "empty"],
        dest="fd_extra_opts",
        help="filter results to empty files and directories",
    )
    parser.add_argument(
        "-E",
        "--extension",
        action="append",
        dest="extensions",
        help="file extension",
        metavar="ext",
    )
    parser.add_argument(
        "-f",
        "--files-only",
        action="store_const",
        const=["--type", "file"],
        dest="fd_extra_opts",
        help="filter results to files",
    )
    parser.add_argument(
        "-F",
        "--force-directory-delete",
        action="store_true",
        help="do not ignore non-empty directories, delete anyways",
    )
    parser.add_argument(
        "-I",
        "--no-ignore-vcs",
        action="store_const",
        const="--no-ignore-vcs",
        dest="fd_extra_opts",
        help="do not ignore .gitignore",
    )
    parser.add_argument(
        "-i",
        "--no-ignore",
        action="store_const",
        const="--no-ignore",
        dest="fd_extra_opts",
        help="do not ignore .gitignore and .fdignore",
    )
    parser.add_argument(
        "-l",
        "--links-only",
        action="store_const",
        const=["--type", "symlink"],
        dest="fd_extra_opts",
        help="filter results to symlinks",
    )
    parser.add_argument("patterns", nargs="+", help="file matching patterns")

    args = parser.parse_args()

    if args.fd_extra_opts is not None:
        FD_OPTS.extend(args.fd_extra_opts)
    if args.extensions is not None:
        for ext in args.extensions:
            FD_OPTS.extend(["--extension", ext])

    files = set()
    for pattern in args.patterns:
        cmd = [FD_BIN, *FD_OPTS, pattern]
        files.update(
            subprocess.run(cmd, capture_output=True, text=True).stdout.splitlines()
        )
    files = sorted(files)

    if files == []:
        print(f"No results found, exiting")
        exit(E_NO_RESULTS)

    # Pretty print all filenames
    for index, filename in enumerate([color_file(f) for f in files], 1):
        print(f"{index}. {filename}")
    # Padding line
    print()

    try:
        user_response = input("Would you like to delete these files? ")
    except KeyboardInterrupt:
        exit(E_INPUT_INTERRUPTED)

    if re.match(USER_RESPONSE_YES, user_response) is None:
        print("Operation cancelled")
        exit(E_USER_RESPONSE_NO)

    # Remove files first
    for f in [fi for fi in files if os.path.isfile(fi)]:
        os.remove(f)

    # Check -f, --force-directory-delete option
    rmdir_func = shutil.rmtree if args.force_directory_delete else os.rmdir

    for d in filter(os.path.isdir, files):
        try:
            rmdir_func(d)
        except OSError:
            print(
                f"{colored('Warning', 'yellow')}: {colored(d, 'blue')} is not empty, not deleting directory"
            )

    print(colored("\nDeletions complete", "green"))
