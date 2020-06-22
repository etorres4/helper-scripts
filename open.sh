#!/usr/bin/bash
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

[[ ! -x '/usr/bin/fzf' ]] && exit 1
[[ ! -x '/usr/bin/xdg-open' ]] && exit 1

# Error messages
readonly nodir_error="Error: no directory given"

# Pre-run correctness checks
unset find_opts
find_bin=
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

declare -a find_opts

if [[ -x '/usr/bin/fd' ]]; then
    find_bin='/usr/bin/fd'
    find_opts+=('--print0')
    find_opts+=('--type' 'f')
    [[ -n "${dir}" ]] && find_opts+=('.' -- "${dir}")
else
    find_bin='/usr/bin/find'
    [[ -n "${dir}" ]] && find_opts+=("${dir}")
    find_opts+=('-mindepth' '0')
    find_opts+=('-type' 'f')
    find_opts+=('-print0')
fi

file="$("${find_bin}" "${find_opts[@]}" | fzf --read0 --select-1 --exit-0)"
[[ -z "${file}" ]] && exit 1

xdg-open "${file}"
