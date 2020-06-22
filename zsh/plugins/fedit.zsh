# Fuzzy find a file and then edit it

_fedit() {
    fedit && zle reset-prompt
}

_etcedit() {
    fedit --etc && zle reset-prompt
}

zle -N _fedit
bindkey -M viins '^o' _fedit

zle -N _etcedit
bindkey -M viins '^e' _etcedit
