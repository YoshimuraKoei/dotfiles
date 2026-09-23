#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR=""

if [[ "$(uname -s)" != "Linux" ]]; then
  printf 'Android setup requires Linux.\n' >&2
  exit 1
fi
case "$(uname -m)" in
  aarch64 | arm64) ;;
  *) printf 'Android setup requires ARM64.\n' >&2; exit 1 ;;
esac
if [[ ! -r /etc/os-release ]]; then
  printf 'Cannot identify the Debian VM.\n' >&2
  exit 1
fi
# shellcheck source=/dev/null
source /etc/os-release
if [[ "${ID:-}" != "debian" ]]; then
  printf 'Android setup requires a Debian VM.\n' >&2
  exit 1
fi
if [[ "$DOTFILES_DIR" != "$HOME/.dotfiles" ]]; then
  printf 'Clone this repository to ~/.dotfiles before running the Android installer.\n' >&2
  exit 1
fi
if ! command -v apt-get >/dev/null 2>&1; then
  printf 'apt-get is required in the Debian VM.\n' >&2
  exit 1
fi

bashrc="$HOME/.bashrc"
source_line='[[ -r "$HOME/.dotfiles/shell/android.bash" ]] && source "$HOME/.dotfiles/shell/android.bash"'
if [[ -e "$bashrc" && ! -f "$bashrc" ]]; then
  printf 'Cannot update ~/.bashrc because it is not a regular file.\n' >&2
  exit 1
fi
if [[ -L "$bashrc" ]] && ! grep -Fqx "$source_line" "$bashrc"; then
  printf 'Existing ~/.bashrc is a symlink. Add the Android source line manually.\n' >&2
  exit 1
fi

apt=(apt-get)
if [[ "$(id -u)" != 0 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    printf 'Install sudo or run this installer as root in the Debian VM.\n' >&2
    exit 1
  fi
  apt=(sudo apt-get)
fi
"${apt[@]}" update
packages=(zsh nano git ca-certificates)
if command -v apt-cache >/dev/null 2>&1 && apt-cache show eza >/dev/null 2>&1; then
  packages+=(eza)
fi
"${apt[@]}" install -y --no-install-recommends "${packages[@]}"

abbr_dir="$HOME/.local/share/zsh-abbr"
if [[ ! -e "$abbr_dir" ]]; then
  mkdir -p "$(dirname "$abbr_dir")"
  git clone --depth=1 --recurse-submodules --shallow-submodules \
    https://github.com/olets/zsh-abbr.git "$abbr_dir"
fi
if [[ ! -r "$abbr_dir/zsh-abbr.zsh" ]]; then
  printf 'zsh-abbr is incomplete at %s. Repair it before continuing.\n' "$abbr_dir" >&2
  exit 1
fi

ensure_backup_dir() {
  if [[ -n "$BACKUP_DIR" ]]; then
    return
  fi
  mkdir -p "$HOME/.dotfiles-backup"
  chmod 700 "$HOME/.dotfiles-backup"
  BACKUP_DIR="$(mktemp -d "$HOME/.dotfiles-backup/android-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
}

zshrc="$HOME/.zshrc"
android_zshrc="$DOTFILES_DIR/shell/android.zsh"
if [[ ! -L "$zshrc" || "$(readlink "$zshrc")" != "$android_zshrc" ]]; then
  if [[ -e "$zshrc" || -L "$zshrc" ]]; then
    ensure_backup_dir
    mv "$zshrc" "$BACKUP_DIR/.zshrc"
  fi
  ln -s "$android_zshrc" "$zshrc"
fi

if [[ ! -f "$bashrc" ]] || ! grep -Fqx "$source_line" "$bashrc"; then
  if [[ -f "$bashrc" ]]; then
    ensure_backup_dir
    cp -p "$bashrc" "$BACKUP_DIR/.bashrc"
  fi
  printf '\n# Start dotfiles zsh in Android Terminal.\n%s\n' "$source_line" >>"$bashrc"
fi

printf 'Android dotfiles installed. Start zsh now with: exec zsh -l\n'
