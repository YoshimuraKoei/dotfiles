#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_path() {
  local target="$1"
  mkdir -p "$BACKUP_DIR"
  mv "$target" "$BACKUP_DIR/"
}

link_path() {
  local source="$1"
  local target="$2"

  if [[ "$source" == "$target" ]]; then
    return
  fi
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi
  ln -s "$source" "$target"
}

clone_if_missing() {
  local url="$1"
  local target="$2"

  if [[ -d "$target/.git" ]]; then
    git -C "$target" pull --ff-only
  elif [[ ! -e "$target" ]]; then
    git clone --depth=1 "$url" "$target"
  fi
}

install_linux_packages() {
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    bat \
    fd-find \
    fzf \
    ripgrep \
    zsh

  mkdir -p "$HOME/.local/bin"
  [[ -x /usr/bin/batcat ]] && ln -sfn /usr/bin/batcat "$HOME/.local/bin/bat"
  [[ -x /usr/bin/fdfind ]] && ln -sfn /usr/bin/fdfind "$HOME/.local/bin/fd"
}

install_eza() {
  command -v eza >/dev/null 2>&1 && return

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install eza
      return
    fi
    printf 'eza is missing; install Homebrew or eza manually.\n' >&2
    return 1
  fi

  local arch
  case "$(uname -m)" in
    x86_64 | amd64) arch="x86_64" ;;
    aarch64 | arm64) arch="aarch64" ;;
    *) printf 'Unsupported architecture for eza: %s\n' "$(uname -m)" >&2; return 1 ;;
  esac

  local temp_dir
  temp_dir="$(mktemp -d)"
  curl -fsSL \
    "https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-unknown-linux-gnu.tar.gz" \
    -o "$temp_dir/eza.tar.gz"
  tar -xzf "$temp_dir/eza.tar.gz" -C "$temp_dir"
  install -m 0755 "$temp_dir/eza" "$HOME/.local/bin/eza"
  rm -rf "$temp_dir"
}

install_neovim() {
  command -v nvim >/dev/null 2>&1 && return
  [[ "$(uname -s)" == "Linux" ]] || return

  local arch
  case "$(uname -m)" in
    x86_64 | amd64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *) printf 'Unsupported architecture for Neovim: %s\n' "$(uname -m)" >&2; return 1 ;;
  esac

  local temp_dir
  temp_dir="$(mktemp -d)"
  curl -fsSL \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" \
    -o "$temp_dir/nvim.tar.gz"
  tar -xzf "$temp_dir/nvim.tar.gz" -C "$temp_dir"
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  mv "$temp_dir/nvim-linux-${arch}" "$HOME/.local/opt/nvim"
  ln -sfn "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$temp_dir"
}

append_zsh_source() {
  local zshrc="$HOME/.zshrc"
  local source_line='[[ -r "$HOME/.dotfiles/shell/shared.zsh" ]] && source "$HOME/.dotfiles/shell/shared.zsh"'

  touch "$zshrc"
  if ! grep -Fq '.dotfiles/shell/shared.zsh' "$zshrc"; then
    printf '\n# Shared personal configuration\n%s\n' "$source_line" >>"$zshrc"
  fi
}

mkdir -p "$HOME/.local/bin" "$HOME/.local/share"
export PATH="$HOME/.local/bin:$PATH"

if [[ "$(uname -s)" == "Linux" ]] && command -v apt-get >/dev/null 2>&1; then
  install_linux_packages
fi

install_eza
install_neovim

clone_if_missing https://github.com/romkatv/powerlevel10k.git "$HOME/.local/share/powerlevel10k"
clone_if_missing https://github.com/olets/zsh-abbr.git "$HOME/.local/share/zsh-abbr"
git -C "$HOME/.local/share/zsh-abbr" submodule update --init --recursive --depth=1

link_path "$DOTFILES_DIR" "$HOME/.dotfiles"
link_path "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
append_zsh_source

if [[ -n "${CODESPACES:-}" ]] && [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

printf '\nDotfiles installed. Start a fresh shell with: exec zsh -l\n'
