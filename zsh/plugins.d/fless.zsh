# key bindings for fless script
fless() {
    /usr/bin/fless
}

zle -N fless
bindkey -M viins '^n' fless
