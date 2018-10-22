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
        -*)
            printf '%s\n' "Unknown option: ${1}"
            exit 1
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

readonly infile="${1}"
readonly starttime="${2}"
readonly stoptime="${3}"
readonly outfile="${4}"
readonly format="${1%.*}"

[[ -z "${infile}" ]] && printf '%s\n' "No file entered." >&2 exit 2
[[ ! -f "${infile}" ]] && printf '%s\n' "Not a file: ${infile}" >&2 exit 3

ffmpeg -i "${infile}" -ss "${starttime}" -to "${stoptime}" -c copy "${outfile:-"${outfile%.*}-trimmed.${format}"}"
