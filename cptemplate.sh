#!/usr/bin/env bash
# Copy a file from ~/Templates to a given name
#
# Dependencies:
#   - fd (soft)
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

# check for existence of fd and fzf binaries
if [[ ! -x '/usr/bin/fzf' ]]; then
    printf '%s\n' 'fzf is not installed on the system'
    exit 1
fi

declare -a find_opts
template_dir="${HOME}/Templates"

if [[ -x '/usr/bin/fd' ]]; then
    find_bin='/usr/bin/fd'
    find_opts+=('--print0')
    find_opts+=('--type' 'f')
    find_opts+=('.' "${template_dir}")
else
    find_bin='/usr/bin/find'
    find_opts+=("${template_dir}")
    find_opts+=('-mindepth' '0')
    find_opts+=('-type' 'f')
    find_opts+=('-print0')
fi

template_file="$("${find_bin}" "${find_opts[@]}" | fzf --read0 --select-1 --exit-0 --no-mouse)"
[[ -z "${template_file}" ]] && exit 1

cp --interactive --verbose "${template_file}" "${1:-.}"
