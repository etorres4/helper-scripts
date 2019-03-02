# Fuzzy-find a file and open it in less
fless() {
    /usr/bin/fless
    zle reset-prompt
}

zle -N fless
bindkey -M viins '^n' fless
