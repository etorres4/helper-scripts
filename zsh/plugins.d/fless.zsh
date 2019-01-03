# key bindings for fless script
_fless() {
    /usr/bin/fless
}

zle -N fless
bindkey -M viins '^n' fless
