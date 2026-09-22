#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$repo_dir/install.sh"
zsh -n "$repo_dir/shell/shared.zsh"
zsh -n "$repo_dir/shell/macos.zsh"
zsh -n "$repo_dir/.zshrc"

if rg -n -i \
  '(api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|password[[:space:]]*=|private[_-]?key)' \
  "$repo_dir" \
  --glob '!scripts/check.sh' \
  --glob '!shell/p10k.zsh'; then
  printf 'Potential secret marker found. Review before committing.\n' >&2
  exit 1
fi

printf 'Dotfiles checks passed.\n'
