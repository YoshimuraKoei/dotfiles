# Shared interactive shell settings for macOS, GitHub Codespaces, and Android.

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
export EDITOR="${DOTFILES_EDITOR:-nvim}"
export VISUAL="$EDITOR"

# A remote TUI can disappear without restoring terminal mouse tracking when an
# SSH connection drops. Disable those modes whenever zsh returns to its prompt.
reset_terminal_mouse_tracking() {
  [[ -o interactive && -t 1 ]] || return
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1004l\e[?1005l\e[?1006l\e[?1015l' > /dev/tty
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd reset_terminal_mouse_tracking

if (( $+commands[eza] )); then
  alias ls='eza --icons=auto'
  alias ll='eza --icons=auto --long --all --git'
  if (( $+functions[compdef] )); then
    compdef _eza ls
  fi
fi

# Keep existing Ghostty key sequences on Macs and remote Codespaces.
if [[ "${DOTFILES_GHOSTTY_KEYS:-1}" == 1 ]]; then
  bindkey $'\e[1;9D' beginning-of-line
  bindkey $'\e[1;9C' end-of-line
  bindkey $'\e[1;9A' beginning-of-buffer-or-history
  bindkey $'\e[1;9B' end-of-buffer-or-history
fi

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

if [[ "${DOTFILES_SKIP_POWERLEVEL10K:-0}" != 1 ]]; then
  if [[ -r "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme"
  fi
  [[ -r "$HOME/.dotfiles/shell/p10k.zsh" ]] && source "$HOME/.dotfiles/shell/p10k.zsh"
fi

if [[ "${HERDR_ENV:-}" == "1" ]]; then
  unset NO_COLOR
fi
