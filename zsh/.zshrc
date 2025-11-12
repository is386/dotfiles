
# -------------------- FUNCTIONS -------------------
gpla() {
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
plugins=(git)
source $ZSH/oh-my-zsh.sh
clear
