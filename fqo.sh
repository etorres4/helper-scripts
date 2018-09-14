#!/usr/bin/env bash
# Fuzzy find a file and then check which package owns it

printHelp() {
cat << EOF
fqo - fuzzy find a file and then check which package owns it
Usage: fqo [-h|--help] [patterns]

Options:
    -h  show this help page
EOF
}

while true; do
    case "${1}" in
        "-h"|"--help")
            printHelp
            exit
            ;;
        --)
            shift
            break
            ;;
        -?*)
            echo "Not an option: ${1}" >&2 && exit 1
            exit
            ;;
        *)
            break;
            ;;
    esac
done

[[ -z "${*}" ]] && echo "No patterns specified" && exit 1

locate --all --ignore-case --null -- "${@}" | fzf --read0 --exit-0 --select-1 | pacman -Qo -
