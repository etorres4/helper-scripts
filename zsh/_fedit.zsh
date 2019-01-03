#!/usr/bin/bash

_etcedit() {
    fedit -e
}

zle -N fedit
bindkey -M viins '^o' fedit

zle -N _etcedit
bindkey -M viins '^e' _etcedit
