# Fuzzy find a file and then edit it

_fedit() {
    /usr/bin/fedit
    zle reset-prompt
}

_etcedit() {
    /usr/bin/fedit --etc
    zle reset-prompt
}

zle -N _fedit
bindkey -M viins '^o' _fedit

zle -N _etcedit
bindkey -M viins '^e' _etcedit
