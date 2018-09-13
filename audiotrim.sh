#!/bin/env bash
# Trim an audio file given a startpoint and an endpoint
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

readonly infile=${1}
readonly starttime=${2}
readonly stoptime=${3}
readonly outfile=${4}

printHelp() {
cat << EOF
Usage: audiotrim [input file] [start time] [stop time] [output file]

Options:
    -h  show this help page
EOF
}

while getopts ":h" opt; do
    case "${opt}" in
        h)
            printHelp
            ;;
    esac

ffmpeg -i "${infile}" -ss "${starttime}" -to "${stoptime}" -c copy "${outfile}"
