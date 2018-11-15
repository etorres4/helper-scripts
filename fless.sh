#!/bin/bash
# fless - fuzzy find a file and run less on it
# Dependencies
#  - fd
#  - fzf

printHelp() {
cat << EOF
Usage: fless [-h|--help] [-b|--boot] [-d|--dir directory] [-e|--etc]
Options:
    -b, --boot      edit a file in /boot/loader
    -d, --dir       edit a file in a given directory
    -e, --etc       edit a file in /etc
    -h, --help      print this help page
EOF
}

# Error messages
readonly directory_error="Error, enter a directory"

# Pre-run correctness checks
unset fd_opts
ans=
file=
dir=

declare -a fd_opts
fd_opts+=('--hidden')
fd_opts+=('--type' 'f')
fd_opts+=('--print0')
fd_opts+=('--no-ignore-vcs')

while true; do
    case "${1}" in
        '-b'|'--boot')
            dir="/boot/loader"
            shift
            continue
            ;;
        '-d'|'--dir')
            case "${2}" in
                "")
                    printf '%s\n' "${directory_error}" >&2
                    exit 1
                    ;;
                *)
                    dir="${2}"
                    [[ ! -d "${dir}" ]] && printf '%s\n' "Not a directory: ${dir}" >&2 && exit 1
                    ;;
            esac
            shift 2
            continue
            ;;
        --dir=*)
            dir="${1#*=}"
            [[ -z "${dir}" ]] && printf '%s\n' "${directory_error}" >&2 && exit 1
            [[ ! -d "${dir}" ]] && printf '%s\n' "Not a directory: ${dir}" >&2 && exit 1
            shift
            continue
            ;;
        '-e'|'--etc')
            dir='/etc'
            shift
            continue
            ;;
        '-h'|'--help')
            printHelp
            exit
            ;;
        --)
            shift
            break
            ;;
        -*)
            printf '%s\n' "Unknown option: ${1}"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ "${dir}" ]]; then
    file="$(fd "${fd_opts[@]}" . -- "${dir}" | fzf --read0 --select-1 --exit-0 --no-mouse)"
else
    file="$(fd "${fd_opts[@]}" | fzf --read0 --select-1 --exit-0 --no-mouse)"
fi

[[ ! "${file}" ]] && exit 1

"${PAGER:-/usr/bin/less}" -- "${file}"
