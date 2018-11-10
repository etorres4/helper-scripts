#!/usr/bin/env bash
# edit - fuzzy find a file and edit it
# Dependencies
#  - fd
#  - fzy

printHelp() {
cat << EOF
Usage: edit [-h|--help] [-b|--boot] [-d|--dir directory] [-e|--etc] [-E|--editor editor] 
Options:
    -b, --boot      edit a file in /boot/loader
    -d, --dir       edit a file in a given directory
    -e, --etc       edit a file in /etc
    -E, --editor    use a given editor (default: ${EDITOR:-none})
    -h, --help      print this help page
EOF
}

# Error messages
readonly directory_error="Error, enter a directory"
readonly noeditor_error="Error, no editor entered"

# Pre-run correctness checks
unset fd_opts
ans=
file=
dir=
editor=

declare -a fd_opts
fd_opts+=('--hidden')
fd_opts+=('--type' 'f')
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
        '-E'|'--editor')
            editor="${2}"
            case "${2}" in
                "")
                    printf '%s\n' "${noeditor_error}" >&2
                    exit 1
                    ;;
                -*)
                    printf '%s\n' "Not an editor: ${editor}" >&2
                    exit 1
                    ;;
            esac
            shift 2
            continue
            ;;
        --editor=*)
            editor="${1#*=}"
            [[ -z "${editor}" ]] && printf '%s\n' "${noeditor_error}" >&2 && exit 1
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

if [[ -z "${editor:-${EDITOR}}" ]]; then
    printf '%s\n' "No editor found" >&2
    exit 1
fi

if [[ "${dir}" ]]; then
    file="$(fd "${fd_opts[@]}" . -- "${dir}" | fzy)"
else
    file="$(fd "${fd_opts[@]}" | fzy)"
fi

[[ ! "${file}" ]] && exit 1

if [[ -w "${file}" ]]; then
    "${editor:-${EDITOR}}" -- "${file}"
else
    sudo --edit -- "${file}"
fi
