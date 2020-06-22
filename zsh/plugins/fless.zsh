# Fuzzy-find a file and open it in less
_run_fless() {
    /usr/bin/fless && zle reset-prompt
}

zle -N _run_fless
bindkey -M viins '^n' _run_fless
