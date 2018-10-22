#!/bin/env bash
# Trim an audio file given a startpoint and an endpoint

printHelp() {
cat << EOF
Usage: audiotrim [input file] [start time] [stop time] [output file]

Options:
    -h  show this help page
EOF
}

while true; do
    case "${1}" in
        '-h'|'--help')
            printHelp
            exit
            ;;
        --)
            shift
            continue
            ;;
        *)
            break
            ;;
    esac
done

readonly infile=${1}
readonly starttime=${2}
readonly stoptime=${3}
readonly outfile=${4}

ffmpeg -i "${infile}" -ss "${starttime}" -to "${stoptime}" -c copy "${outfile}"
