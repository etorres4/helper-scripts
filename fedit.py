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
BOOT_DIR = '/boot'
ETC_DIR = '/etc'

# Exit Codes
E_NOEDITORFOUND = 2
E_NOFILESELECTED = 3

# Commands
FIND_CMD = shutil.which('fd')
FIND_OPTS = ['--hidden', '--print0', '--type', 'f', '--no-ignore-vcs']
FZF_CMD = shutil.which('fzf')
FZF_OPTS = ['--read0', '--select-1', '--exit-0', '--print0']

LOCALE = 'utf-8'


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
    if editor_override is not None:
        return shutil.which(editor_override)
    elif 'EDITOR' in os.environ:
        return shutil.which(os.environ.get('EDITOR'))
    elif shutil.which('vim') is not None:
        return shutil.which('vim')
    else:
        raise FileNotFoundError('An editor could not be resolved')

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
        return ['sudo', '--edit', filename]


# ========== Main Script ==========
parser = argparse.ArgumentParser()
parser.add_argument('-b', '--boot',
                    action='store_const',
                    const=BOOT_DIR,
                    dest='dir',
                    help='edit a file in /boot')
parser.add_argument('-d', '--dir',
                    dest='dir',
                    type=str,
                    help='edit a file in a given directory')
parser.add_argument('-E', '--etc',
                    action='store_const',
                    const=ETC_DIR,
                    dest='dir',
                    help='edit a file in /etc')
parser.add_argument('-e', '--editor',
                    help='use a given editor')

args = parser.parse_args()

final_find_cmd = [FIND_CMD] + FIND_OPTS
extra_opts = []
editor = ''

try:
    editor = select_editor(args.editor)
except FileNotFoundError as e:
    print(e)
    exit(E_NOEDITORFOUND)

if args.dir is not None:
    extra_opts.extend(['.', '--', args.dir])

final_find_cmd.extend(extra_opts)

files = subprocess.run(final_find_cmd,
                       capture_output=True)
fzf_output = subprocess.run([FZF_CMD] + FZF_OPTS,
                            input=files.stdout,
                            stdout=subprocess.PIPE).stdout

# Filename is null terminated
filename = fzf_output.decode(LOCALE).strip('\x00')

if not filename == '':
    cmd = gen_editor_cmd(filename.strip('\n'))
    subprocess.run(cmd)
else:
    exit(E_NOFILESELECTED)
