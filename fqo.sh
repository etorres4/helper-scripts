#!/usr/bin/env bash
# Fuzzy find a file and then check which package owns it

printHelp() {
cat << EOF
    fqo - fuzzy find a file and then check which package owns it
    Usage: fqo [patterns]

    Options:
        -h  show this help page
EOF
}

[[ -z "${*}" ]] && echo "No patterns specified" && exit 1

locate --all --ignore-case --null -- "${@}" | fzf --read0 --exit-0 --select-1 | pacman -Qo -
