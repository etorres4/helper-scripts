#!/bin/bash
# ef - fuzzy find a file and edit it
#
# Dependencies
#   - fzf
#   - mlocate

set -o nounset

printHelp() {
cat << done
Usage: ef [-h|--help] [-E|--editor editor] [patterns]

Options:
    -h              print this help page
    -E, --editor    use a different editor (default: ${EDITOR:-none})
done
}

# Pre-run correctness checks
editor=
file=

while true; do
    case "${1}" in
        "-E"|"--editor")
            case "${2}" in
                ""|-*)
                    printf '%s\n' "Not an editor or none entered" >&2
                    exit 1
                    ;;
                *)
                    editor="${2}"
                    ;;
            esac
            shift 2
            continue
            ;;
        --editor=*)
            editor="${1#*=}"
            [[ -z "${editor}" ]] && printf '%s\n' "Editor not entered" >&2 && exit 1
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
        -?)
            printf '%s\n' "Unknown option: ${1}" >&2
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

file="$(locate --all --ignore-case --null -- "${@}" | fzf --read0 --exit-0 --select-1 --no-mouse)"

if [[ -z "${file}" ]]; then
    exit 1
fi

if [[ -w "${file}" ]]; then
    "${editor:-${EDITOR}}" -- "${file}"
else
    sudo --edit -- "${file}"
fi
