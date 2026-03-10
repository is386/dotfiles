# -------------------- FUNCTIONS -------------------
gla() {
  local owner="is386"
  echo "Fetching repo list for owner: $owner"
  gh repo list "$owner" --limit 500 --json name,sshUrl --jq '.[] | "\(.name) \(.sshUrl)"' |
  while IFS=' ' read -r name sshUrl; do
    if [ -d "$name/.git" ]; then
      echo "==> [$name] exists — pulling updates"
      ( cd "$name" && git pull )
    else
      echo "==> [$name] not found — cloning $sshUrl"
      git clone "$sshUrl" "$name"
    fi
  done
}

# ------------------ CUSTOM PROMPT -----------------
autoload -Uz vcs_info
_set_branch_display() {
  vcs_info
  if [[ -n ${vcs_info_msg_0_} ]]; then
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null)
    remote_url=${remote_url/git@github.com:/https://github.com/}
    remote_url=${remote_url%.git}
    branch_display="%{$(echo -n "\e]8;;${remote_url}\e\\")%}[${vcs_info_msg_0_}]%{$(echo -n "\e]8;;\e\\")%}"
  else
    branch_display=""
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_branch_display
zstyle ':vcs_info:git:*' formats '%b'
NEWLINE=$'\n'
PROMPT="${NEWLINE}%F{blue}%n%f %F{green}%(5~|…/%3~|%~)%f"
PROMPT+=' %F{cyan}${branch_display}%f'
PROMPT+=" ${NEWLINE}→ "

# --------------------- ALIASES --------------------
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias bat="$(command -v batcat &> /dev/null && echo batcat || echo bat) --theme=Nord"
alias cat="bat -p"
alias vim="nvim"
alias vi="nvim"
alias profile="vi ~/.zshrc"
alias reload="source ~/.zshrc"
alias repos="cd ~/repos/"
alias ai="cd ~/ai-sandbox/"
alias nconf="cd ~/.config/nvim"

# ------------- ENVIRONMENT VARIABLES --------------
export ZSH="$HOME/.oh-my-zsh"

# -------------------- START UP --------------------
# ZSH
plugins=(git)
source $ZSH/oh-my-zsh.sh

clear
