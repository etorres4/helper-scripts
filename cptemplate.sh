#!/bin/bash
# Copy a file from ~/Templates to a given name
#
# Dependencies:
#   - fd
#   - fzf

printHelp() {
cat << EOF
Usage: cptemplate [-h,--help] [options] [filename]

Options:
    -h, --help      print this help page
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
find_opts+=('.')
find_opts+=('-mindepth' '0')
find_opts+=('-type' 'f')
find_opts+=('-print0')

declare -a fd_opts
fd_opts+=('--print0')
fd_opts+=('--type' 'f')

template_file="$(fd "${fd_opts[@]}" . "${HOME}/Templates" | fzf --read0 --select-1 --exit-0 --no-mouse)"
[[ -z "${template_file}" ]] && exit 1

cp --interactive --verbose "${template_file}" "${1:-.}"
