#!/usr/bin/env bash
# Download audio using youtube-dl, passing
# a specific set of options specified by the user
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
    -f, --format    the format to use (default: flac)"
    -h, --help      print this help page
    -n, --filename  the name of the downloaded file (without the extension)
EOF
}

TEMP=$(getopt -o "b:f:hn:::" --long "batch-dl:,filename:,format:,help::" -n "dlaudio" -- "${@}")

declare -a opts

eval set -- "${TEMP}"
unset TEMP

while true; do
	case "${1}" in
		"-b"|"--batch-dl")
            case "${2}" in
                "")
                    batchfile="${2}"
                    ;;
                *)
                    echo "No batch file entered" >&2
                    exit 1
            esac
            shift 2
            continue
            ;;
		"-f"|"--format")
            case "${2}" in
                "")
                    echo "No format entered" >&2
                    exit 1
                    ;;
                *)
                    format="${2}"
                    ;;
            esac
            shift 2
			continue
            ;;
        "-h"|"--help")
            # print help page and exit
            printHelp
            exit
            ;;
        "-n"|"--filename")
            case "${2}" in
                "")
                    echo "No filename entered" >&2
                    exit 1
                    ;;
                *)
                    filename="${2}"
                    ;;
            esac
            shift 2
            continue
            ;;
		"--")
			shift
			break
            ;;
	esac
done

[[ -z "${*}" ]] && echo "No input given" >&2 && exit 1

# default options
opts+=("--no-part")
opts+=("--no-continue")
opts+=("--extract-audio")
opts+=("--audio-format=${format:-flac}")

# set filename to either what the user set or its original title
if [[ -n "${filename}" ]]; then
    opts+=("--output=${HOME}/Music/${filename}.%(ext)s")
else
    opts+=("--output=${HOME}/Music/%(title)s.%(ext)s")
fi

if [[ -n "${batchfile}" ]]; then
    youtube-dl "${opts[@]}" --batch-file="${batchfile}"
else
    youtube-dl "${opts[@]}" "${@}"
fi
