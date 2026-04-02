# Functions
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

ZSH_PLUGINS="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-plugins"

# Completions
if [ ! -d "$ZSH_PLUGINS/zsh-completions" ]; then
  mkdir -p "$ZSH_PLUGINS"
  git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_PLUGINS/zsh-completions"
fi
fpath=($ZSH_PLUGINS/zsh-completions/src ~/.zsh/completions $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z} l:|=* r:|=*'

# FZF Tab
if [ ! -d "$ZSH_PLUGINS/fzf-tab" ]; then
  mkdir -p "$ZSH_PLUGINS"
  git clone https://github.com/Aloxaf/fzf-tab.git "$ZSH_PLUGINS/fzf-tab"
fi
source "$ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh"

# Vim Mode 
if [ ! -d "$ZSH_PLUGINS/zsh-vi-mode" ]; then
  mkdir -p "$ZSH_PLUGINS"
  git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_PLUGINS/zsh-vi-mode"
fi
ZVM_VI_HIGHLIGHT_FOREGROUND=default
ZVM_VI_HIGHLIGHT_BACKGROUND=default
ZVM_VI_HIGHLIGHT_EXTRASTYLE=standout
source "$ZSH_PLUGINS/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

# Prompt
autoload -Uz add-zsh-hook vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats ' %F{6}[%b]%f'
zstyle ':vcs_info:*' actionformats ' %F{6}[%b|%a]%f'

_lean_precmd() { vcs_info }
add-zsh-hook precmd _lean_precmd
setopt prompt_subst

PROMPT='
%F{4}%n%f %F{2}%4(~|…/%3~|%~)%f${vcs_info_msg_0_}
%F{5}→%f '
RPROMPT=''

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Misc Options
setopt globdots
setopt ignoreeof

# Aliases
alias bat="bat --theme=Nord"
alias cat="bat -p"
alias cd="z"
alias cp="cp -i"
alias ls="ls --color"
alias mv="mv -i"
alias profile="vi ~/.zshrc"
alias reload="source ~/.zshrc"
alias rm="rm -i"
alias vi="nvim"
alias vim="nvim"

# Shell Integrations
eval "$(~/.local/bin/mise activate zsh --shims)"

eval "$(zoxide init zsh)"

zvm_after_init() {
  source <(fzf --zsh)
  bindkey '^[[A' history-search-backward
  bindkey '^[[B' history-search-forward
  bindkey '^[OA' history-search-backward
  bindkey '^[OB' history-search-forward
}

