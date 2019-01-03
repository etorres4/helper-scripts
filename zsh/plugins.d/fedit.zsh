# call the fedit script
_fedit() {
    /usr/bin/fedit
}

_etcedit() {
    /usr/bin/fedit -e
}

zle -N fedit
bindkey -M viins '^o' _fedit

zle -N _etcedit
bindkey -M viins '^e' _etcedit
