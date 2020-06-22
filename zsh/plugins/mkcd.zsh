# Make a directory, then change into it

mkcd() {
    [[ ! -d "${1}" ]] && mkdir --parents -- "${1}"
    cd "${1}" || exit
}

autoload -Uz mkcd
