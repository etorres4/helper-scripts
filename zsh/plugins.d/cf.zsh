# Fuzzy cd from anywhere
# Dependencies
# - fzf
# - mlocate
cf() {
    [[ -z "${*}" ]] && return 1
    [[ ! -x /usr/bin/fzf ]] && return 1

    dir="$(locate --all --ignore-case --null -- "${@}" | fzf --read0 --select-1 --exit-0)"

    [[ -z "${dir}" ]] && return 1
 
    if [[ -f "${dir}" ]]; then
        cd "${dir%/*}"
    else
        cd "${dir}"
    fi
}

autoload -Uz cf
