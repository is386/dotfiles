
# ------------------ CUSTOM PROMPT -----------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '[%b]'
NEWLINE=$'\n'
PROMPT="${NEWLINE}%F{blue}%n%f %F{green}%~%f"
PROMPT+=' %F{cyan}${vcs_info_msg_0_}%f'
PROMPT+=" ${NEWLINE}→ "

# --------------------- ALIASES --------------------
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias profile="code ~/.zshrc"
alias reload="source ~/.zshrc"

# ------------- ENVIRONMENT VARIABLES --------------
export ZSH="$HOME/.oh-my-zsh"

# -------------------- START UP --------------------
source $ZSH/oh-my-zsh.sh
plugins=(... git)
clear

