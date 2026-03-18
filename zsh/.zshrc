# FUNCTIONS 
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

# CUSTOM PROMPT 
setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '%b'
_set_branch_display() {
  vcs_info
  if [[ -n ${vcs_info_msg_0_} ]]; then
    if [[ "$PWD" != "$_last_get_dir" ]]; then
      _last_git_dir="$PWD"
      _cached_remote_url=$(git remote get-url origin 2>/dev/null)
      _cached_remote_url=${_cached_remote_url/git@github.com:/https://github.com/}
      _cached_remote_url=${_cached_remote_url%.git}
    fi
    branch_display="%{$(echo -n "\e]8_;;${_cached_remote_url}\e\\")%}[${vcs_info_msg_0_}]%{$(echo -n "\e]8;;\e\\")%}"
  else
    branch_display=""
    _last_git_dir=""
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_branch_display
NEWLINE=$'\n'
PROMPT="${NEWLINE}%F{blue}%n%f %F{green}%(5~|…/%3~|%~)%f"
PROMPT+=' %F{cyan}${branch_display}%f'
PROMPT+=" ${NEWLINE}→ "

# ENVIRONMENT VARIABLES 
export COLORTERM=truecolor
export CLICOLOR=1
export LS_COLORS='di=36:ln=35:so=32:ex=31:bd=34;46:cd=34;43:su=30;46:tw=30;42:ow=30;43'

# ALIASES 
alias vim="nvim"
alias vi="nvim"
alias ls="ls --color=auto"
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
alias bat="$(command -v batcat &> /dev/null && echo batcat || echo bat) --theme=Nord"
alias cat="bat -p"
alias reload="clear && source ~/.zshrc"
alias profile="vi ~/.zshrc"
alias nconf="cd ~/.config/nvim"
alias ai="cd ~/ai-sandbox/"
alias repos="cd ~/repos"

# HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[OA' history-search-backward
bindkey '^[OB' history-search-forward

# COMPLETIONS
fpath=(~/.zsh/completions, $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# MISE
eval "$(~/.local/bin/mise activate zsh --shims)"
