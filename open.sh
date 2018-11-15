#!/bin/bash
# open - fuzzy find, select, and open a file using xdg-open
#
# Dependencies:
#   - fd
#   - fzf
#   - xdg-utils (xdg-open executable)

printHelp() {
cat << done
Fuzzy find and run xdg-open on a file

Usage: open [-h|--help] [-d|--dir directory]

Options:
    -d, --dir   select a directory to search in
    -h, --help  show this help page
done
}

# Error messages
readonly nodir_error="Error: no directory given"

# Pre-run correctness checks
dir=
file=

while true; do
    case "${1}" in
        "-d"|"--dir")
            case "${2}" in
                "")
                    printf '%s\n' "${nodir_error}" >&2 && exit 1
                    ;;
                *)
                    dir="${2}"
                    [[ ! -d "${dir}" ]] && printf '%s\n' "Error, not a directory: ${dir}" >&2 && exit 1
                    ;;
            esac
            shift 2
            continue
            ;;
        --dir=*)
            dir="${2#*=}"
            case "${dir}" in
                "")
                    printf '%s\n' "${nodir_error}" >&2
                    exit 1
                    ;;
                *)
                    [[ ! -d "${dir}" ]] && printf '%s\n' "Error, not a directory: ${dir}" >&2
                    exit 1
                    ;;
            esac
            shift
            continue
            ;;
        "-h"|"--help")
            printHelp
            exit
            ;;
        --)
            shift
            break
            ;;
        -*)
            printf '%s\n' "Error, unknown option: ${1}" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ -n "${dir}" ]]; then
    file="$(fd --hidden --type f --print0 . -- "${dir}" | fzf --read0 --select-1 --exit-0 --no-mouse)"
else
    file="$(fd --hidden --type f --print0 | fzf --read0 --select-1 --exit-0 --no-mouse)"
fi

if [[ -z "${file}" ]]; then
    exit 1
fi

xdg-open "${file}"
