#!/usr/bin/bash
# fedit - fuzzy find a file and edit it
# Dependencies
# - fd
# - fzf

help() {
cat << EOF
Usage: fedit [-h|--help] [-b|--boot] [-d|--dir directory] [-e|--etc] [-E|--editor editor] 
Options:
    -b, --boot      edit a file in /boot/loader
    -d, --dir       edit a file in a given directory
    -e, --etc       edit a file in /etc
    -E, --editor    use a given editor (default: ${EDITOR:-none})
    -h, --help      print this help page
EOF
}

[[ ! -f /usr/bin/fzf ]] && exit 1

# Error messages
readonly directory_error="Error, enter a directory"
readonly noeditor_error="Error, no editor entered"

# Pre-run correctness checks
unset find_opts
file=
dir=
editor=

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
            help
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

declare -a find_opts
if [[ -x '/usr/bin/fd' ]]; then
    find_bin='/usr/bin/fd'
    find_opts+=('--hidden')
    find_opts+=('--print0')
    find_opts+=('--type' 'f')
    find_opts+=('--no-ignore-vcs')
    [[ -n "${dir}" ]] && find_opts+=('.' -- "${dir}")
else
    find_bin='/usr/bin/find'
    [[ -n "${dir}" ]] && find_opts+=("${dir}") || find_opts+=('.')
    find_opts+=('-mindepth' '0')
    find_opts+=('-type' 'f')
    find_opts+=('-print0')
fi

if [[ -z "${editor:-${EDITOR}}" ]]; then
    printf '%s\n' "No editor found" >&2
    exit 1
fi

file="$("${find_bin}" "${find_opts[@]}" 2> /dev/null | fzf --read0 --select-1 --exit-0)"

[[ ! "${file}" ]] && exit 1

if [[ -w "${file}" ]]; then
    "${editor:-${EDITOR}}" -- "${file}"
else
    sudo --edit -- "${file}"
fi
