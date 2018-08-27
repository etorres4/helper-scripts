#!/usr/bin/env bash
# Fuzzy find a file and then check which package owns it

locate --all --ignore-case --null -- "${@}" | fzf --read0 --exit-0 --select-1 | pacman -Qo -
