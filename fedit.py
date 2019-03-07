#!/usr/bin/python3
"""
Fuzzy-find a file and edit it.

Dependencies
============
* fd
* fzf
"""

import argparse
import os
import shutil
import subprocess

# ========== Constants ==========
# Paths
BOOT_DIR = "/boot"
ETC_DIR = "/etc"

# Exit Codes
E_NOEDITORFOUND = 2
E_NOFILESELECTED = 3

# Commands
FIND_CMD = "/usr/bin/fd"
FIND_OPTS = ["--hidden", "--print0", "--type", "f", "--no-ignore-vcs"]
FZF_CMD = "/usr/bin/fzf"
FZF_OPTS = ["--read0", "--select-1", "--exit-0", "--print0"]
LOCATE_CMD = "/usr/bin/locate"
LOCATE_OPTS = ["--all", "--ignore-case", "--null"]

LOCALE = "utf-8"


# ========== Functions ==========
def select_editor(editor_override=None):
    """Return a possible canonical path to an editor.
    Select an editor from one of:
    * -e, --editor
    * $EDITOR
    * Default of vim

    In this order

    If an editor cannot be resolved, then an Error is raised instead.

    :param editor_override: argument to override an editor
    :returns: path to one of these editors
    :rtype: str
    :raises: FileNotFoundError if an editor could not be resolved
    """
    editor = None

    if editor_override is not None:
        editor = shutil.which(editor_override)
    elif "EDITOR" in os.environ:
        editor = shutil.which(os.environ.get("EDITOR"))
    elif shutil.which("vim") is not None:
        editor = shutil.which("vim")

    if editor is None:
        raise FileNotFoundError("An editor could not be resolved")

    return editor


def gen_editor_cmd(filename):
    """Generate a command line to run for editing a file based on
    permissions.

    :param filename: name of file to edit
    :type filename: str or path-like object
    :returns: command to execute to edit file
    :rtype: list
    """
    # possible for a race condition to occur here
    if os.access(filename, os.W_OK):
        return [editor, filename]
    else:
        return ["sudo", "--edit", filename]


def run_fzf(files):
    """Run fzf on a stream of searched files for the user to select.

    :param files: stream of null-terminated files to read
    :type files: bytes stream (stdout of a completed process)
    :returns: selected file
    :rtype: str
    """
    selected_file = subprocess.run(
        [FZF_CMD] + FZF_OPTS, input=files, stdout=subprocess.PIPE
    ).stdout

    return selected_file.decode(LOCALE).strip("\x00")


def find_files(directory=None):
    """Use a find-based program to locate files, then pass to fzf.

    :param directory: directory to search for files
    :type directory: str
    :returns: path of user-selected file
    :rtype: bytes
    """
    cmd = [FIND_CMD] + FIND_OPTS
    if directory is not None:
        cmd.extend(["--", ".", directory])

    return subprocess.run(cmd, capture_output=True).stdout


def locate_files(patterns):
    """Use a locate-based program to locate files, then pass to fzf.

    :param patterns: patterns to pass to locate
    :type patterns: list
    :returns: path of user-selected file
    :rtype: bytes
    """
    cmd = [LOCATE_CMD] + LOCATE_OPTS
    cmd.extend(patterns)

    return subprocess.run(cmd, capture_output=True).stdout


# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument(
    "-b",
    "--boot",
    action="store_const",
    const=BOOT_DIR,
    dest="dir",
    help="edit a file in /boot",
)
parser.add_argument(
    "-d", "--dir", dest="dir", type=str, help="edit a file in a given directory"
)
parser.add_argument(
    "-E",
    "--etc",
    action="store_const",
    const=ETC_DIR,
    dest="dir",
    help="edit a file in /etc",
)
parser.add_argument("-e", "--editor", help="use a given editor")
parser.add_argument("patterns", type=str, nargs="*", help="patterns to pass to locate")

args = parser.parse_args()

final_find_cmd = [FIND_CMD] + FIND_OPTS
editor = ""

try:
    editor = select_editor(args.editor)
except FileNotFoundError as e:
    print(e)
    exit(E_NOEDITORFOUND)

# If patterns were passed, use locate
# Otherwise check for -d and use fd
if not args.patterns == []:
    files = locate_files(args.patterns)
else:
    files = find_files(args.dir)

selected_file = run_fzf(files)

if not selected_file == "":
    cmd = gen_editor_cmd(selected_file)
    subprocess.run(cmd)
else:
    exit(E_NOFILESELECTED)
