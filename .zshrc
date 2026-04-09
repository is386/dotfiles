#!/bin/bash

source ~/.localrc

# Plugin Setup
ZSH_PLUGINS="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-plugins"
mkdir -p "$ZSH_PLUGINS"
  
_install_plugin() {
  local url="$1"
  local dir="$ZSH_PLUGINS/${url##*/}"
  [ -d "$dir" ] || git clone "$url" "$dir"
}

# Completions
_install_plugin https://github.com/zsh-users/zsh-completions
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
_install_plugin https://github.com/Aloxaf/fzf-tab
source "$ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh"

# History Substring Search
_install_plugin https://github.com/zsh-users/zsh-history-substring-search
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
source "$ZSH_PLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Vim Mode
_install_plugin https://github.com/jeffreytse/zsh-vi-mode
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
alias grep="rg"
alias lrc="vi ~/.localrc"
alias ls="ls --color"
alias mv="mv -i"
alias zrc="vi ~/.zshrc"
alias rl="source ~/.zshrc"
alias rm="rm -i"
alias vi="nvim"
alias vim="nvim"

# Shell Integrations
eval "$(~/.local/bin/mise activate zsh --shims)"

eval "$(zoxide init zsh)"

zvm_after_init() {
  source <(fzf --zsh)
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
}

