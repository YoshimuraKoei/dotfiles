# Interactive settings shared by this user's Macs.
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && [[ -f "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" ]]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
elif [[ -f /Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration ]]; then
  builtin source /Applications/Ghostty.app/Contents/Resources/ghostty/shell-integration/zsh/ghostty-integration
fi

if [[ -d /opt/homebrew/share/zsh-abbr ]]; then
  FPATH=/opt/homebrew/share/zsh-abbr:$FPATH
fi
autoload -Uz compinit && compinit

codex() {
  local codex_bin="$HOME/.local/bin/codex"
  local -a codex_launch_args=()
  if [[ "${HERDR_ENV:-}" == "1" ]]; then
    codex_launch_args=(-c 'shell_environment_policy.inherit=all')
  fi
  export CODEX_NOTIFY_TTY="$(tty 2>/dev/null || true)"
  export CODEX_NOTIFY_CWD="$PWD"
  command "$codex_bin" "${codex_launch_args[@]}" "$@"
}

nvim-small() {
  open -na Ghostty.app --args \
    --config-file="$HOME/.config/ghostty/nvim.config" \
    --window-save-state=never \
    --working-directory="$PWD" \
    -e nvim "$@"
}

alias kill-cursor='killall CursorUIViewService'
alias check-cursor='ps -eo pmem,rss,pid,comm | grep -i CursorUIViewService'
