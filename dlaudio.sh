#!/usr/bin/env bash
# Download audio using youtube-dl, passing
# a specific set of options specified by the user
#
# Copyright (C) 2018 Eric Torres
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

printHelp() {
cat << EOF
Usage: dlaudio [options] [URLs]

Options:
    -b, --batch-dl  provide the links from a text file
    -f, --format    the format to use (default: flac)
    -h, --help      print this help page
    -n, --filename  the name of the downloaded file (without the extension)
EOF
}


declare -a opts
batchfile=
filename=
format=

# error messages
readonly nobatchfile_error="Error: no batch file entered"
readonly nofilename_error="Error: no filename entered"
readonly noformat_error="Error: no format entered"

while true; do
	case "${1}" in
		"-b"|"--batch-dl")
            batchfile="${2}"
            case "${batchfile}" in
                "")
                    echo "${nobatchfile_error}" >&2
                    exit 1
                    ;;
                -*)
                    echo "Not a file: ${batchfile}"
                    exit 1
                    ;;
                *)
                    [[ ! -f "${batchfile}" ]] && echo "Not a file: ${batchfile}" >&2 && exit 1
                    ;;
            esac
            shift 2
            continue
            ;;
        --batchfile=*)
            batchfile="${2#*=}"
            case "${batchfile}" in
                "")
                    echo "${nobatchfile_error}" >&2
                    exit 1
                    ;;
                -*)
                    echo "Not a file: ${batchfile}" >&2
                    exit 1
                    ;;
                *)
                    [[ ! -f "${batchfile}" ]] && echo "Not a file: ${batchfile}" && exit 1
                    ;;
            esac
            shift
            continue
            ;;
		"-f"|"--format")
            format="${2}"
            case "${format}" in
                "")
                    echo "No format entered" >&2
                    exit 1
                    ;;
                -*)
                    echo "Not a format: ${format}"
                    exit 1
                    ;;
            esac
            shift 2
			continue
            ;;
        --format=*)
            format="${1#*=}"
            case "${format}" in
                "")
                    echo "${noformat_error}" >&2
                    exit 1
                    ;;
                -*)
                    echo "Not a format: ${format}" >&2
                    exit 1
                    ;;
            esac
            shift
            continue
            ;;
        "-h"|"--help")
            # print help page and exit
            printHelp
            exit
            ;;
        "-n"|"--filename")
            filename="${2}"
            case "${filename}" in
                "")
                    echo "${nofilename_error}" >&2
                    exit 1
                    ;;
                -*)
                    echo "Not a filename: ${filename}" >&2
                    exit 1
                    ;;
            esac
            shift 2
            continue
            ;;
        --filename=*)
            filename="${2#*=}"
            case "${filename}" in
                "")
                    echo "${nofilename_error}" >&2
                    exit 1
                    ;;
                -*)
                    echo "Not a filename: ${filename}" >&2
                    exit 1
                    ;;
            esac
            shift
            continue
            ;;
		"--")
			shift
			break
            ;;
        -?*)
            echo "Error, not an option: ${1}" >&2
            exit 1
            ;;
        *)
            shift
            break
	esac
done

[[ -z "${*}" ]] && echo "No input given" >&2 && exit 1

# default options
opts+=("--no-part")
opts+=("--no-continue")
opts+=("--extract-audio")
opts+=("--audio-format=${format:-flac}")

# set filename to either what the user set or its original title
if [[ "${filename}" ]]; then
    opts+=("--output=${HOME}/Music/${filename}.%(ext)s")
else
    opts+=("--output=${HOME}/Music/%(title)s.%(ext)s")
fi

if [[ "${batchfile}" ]]; then
    youtube-dl "${opts[@]}" --batch-file="${batchfile}"
else
    youtube-dl "${opts[@]}" "${@}"
fi
