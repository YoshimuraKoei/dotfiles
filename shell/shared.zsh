# Shared interactive shell settings for macOS and GitHub Codespaces.

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

if (( $+commands[eza] )); then
  alias ls='eza --icons=auto'
  alias ll='eza --icons=auto --long --all --git'
  if (( $+functions[compdef] )); then
    compdef _eza ls
  fi
fi

# Match Ghostty Cmd+Arrow custom sequences to macOS-style movement.
bindkey $'\e[1;9D' beginning-of-line
bindkey $'\e[1;9C' end-of-line
bindkey $'\e[1;9A' beginning-of-buffer-or-history
bindkey $'\e[1;9B' end-of-buffer-or-history

ABBR_SET_EXPANSION_CURSOR=1
typeset -ga ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES
ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES+=(
  "*& "
  "*&& "
  "*| "
  "*|| "
  "*; "
  "[A-Z]*=* "
)

if (( ! $+functions[abbr] )) && [[ -r "$HOME/.local/share/zsh-abbr/zsh-abbr.zsh" ]]; then
  source "$HOME/.local/share/zsh-abbr/zsh-abbr.zsh"
fi

if (( $+functions[abbr] )); then
  abbr add --session --force --quiet 'gc=git commit -m "%"'
  abbr add --session --force --quiet 'gp=git push'
  abbr add --session --force --quiet 'gst=git status'
  abbr add --session --force --quiet 'jl=uv run --with jupyterlab jupyter lab'
fi

if [[ -r "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme"
fi
[[ -r "$HOME/.dotfiles/shell/p10k.zsh" ]] && source "$HOME/.dotfiles/shell/p10k.zsh"

if [[ "${HERDR_ENV:-}" == "1" ]]; then
  unset NO_COLOR
fi
