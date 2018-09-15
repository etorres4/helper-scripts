#!/usr/bin/env bash
# Download audio using youtube-dl, passing
# a specific set of options specified by the user

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
declare -r default_filename="--output=${HOME}/Music/%(title)s.%(ext)s"
format=

# error messages
declare -r nobatchfile_error="Error: no batch file entered"
declare -r nofilename_error="Error: no filename entered"
declare -r noformat_error="Error: no format entered"

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
        --batch-dl=*)
            batchfile="${1#*=}"
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
            filename="${1#*=}"
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
        -*)
            echo "Error, not an option: ${1}" >&2
            exit 1
            ;;
        *)
            break
	esac
done

# default options
opts+=("--no-part")
opts+=("--no-continue")
opts+=("--extract-audio")
opts+=("--audio-format=${format:-flac}")

# filename cannot be used at the same time as batch-dl
if [[ "${filename}" && -z "${batchfile}" ]]; then
    opts+=("--output=${HOME}/Music/${filename}.%(ext)s")
elif [[ "${batchfile}" && -z "${filename}" ]]; then
    opts+=("${default_filename}")
elif [[ "${batchfile}" && "${filename}" ]]; then
    printf '%s\n' "Cannot pass '--batch-dl' and '--filename' together, ignoring"
    opts+=("${default_filename}")
fi

if [[ "${batchfile}" ]]; then
    youtube-dl "${opts[@]}" --batch-file="${batchfile}"
elif [[ "${*}" ]]; then
    youtube-dl "${opts[@]}" "${@}"
else
    printf '%s\n' "No arguments entered, cancelling"
fi
