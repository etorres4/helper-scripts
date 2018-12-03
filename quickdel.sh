#!/bin/bash
# quickdel - delete any file matching a query
# Dependencies:
# fd

set -o nounset

printHelp() {
cat << EOF
Fuzzy find and delete files matching patterns

Usage: quickdel [-h] [-i] [-I] [patterns]

Options:
    -d, --directories-only  only delete directories
    -h, --help              print this help page
    -i, --no-ignore         do not ignore .gitignore and .fdignore
    -I, --no--ignore-vcs    do not ignore .gitignore
EOF
}

# Pre-run correctness checks
unset files
unset fd_opts

declare -a files
declare -a fd_opts
declare -r blue='\033[0;34m'
declare -r nocolor='\033[0;0m'

while true; do
    case "${1}" in
        '-d'|'--directories-only')
            fd_opts+=('--type' 'd')
            shift
            continue
            ;;
        '-h'|'--help')
            printHelp
            exit
            ;;
        '-i'|'--no-ignore')
            fd_opts+=('--no-ignore')
            shift
            continue
            ;;
        '-I'|'--no-ignore-vcs')
            fd_opts+=('--no-ignore-vcs')
            shift
            continue
            ;;
        --)
            shift
            break
            ;;
        -*)
            printf '%s\n' "Unknown option: ${1}" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Prevent fd from selecting everything
[[ -z "${*}" ]] && printf '%s\n' "No queries entered, cancelling" >&2 && exit 1

for pattern in "${@}"; do
    while IFS= read -r -d '' file; do
        files+=("${file}")
    done < <(fd --hidden --print0 "${fd_opts[@]}" -- "${pattern}")
done

[[ -z "${files[*]}" ]] && printf '%s\n' "No results found" >&2 && exit 1

# List all filenames, pretty print them
for filename in "${files[@]}"; do
    if [[ -f "${filename}" ]]; then
        printf '%s\n' "${filename}" 
    elif [[ -d "${filename}" ]]; then
        printf '%b%s%b\n' "${blue}" "${filename}" "${nocolor}" 
    fi
done

printf '%s' "Would you like to delete these files? "
read -r -n 1 ans

if [[ "${ans:-n}" =~ (Y|y) ]]; then
    rm --recursive --force -- "${files[@]}"
else
    printf '\n%s\n' "Operation cancelled" >&2
    exit 1
fi
