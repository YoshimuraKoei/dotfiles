# dotfiles

YoshimuraKoei personal terminal and Neovim configuration for macOS and GitHub Codespaces.

## Includes

- shared zsh behavior and Ghostty key sequences
- `eza` as `ls`
- zsh-abbr shortcuts: `gc`, `gp`, `gst`, `jl`
- Powerlevel10k configuration
- AstroNvim configuration

Machine-specific paths, credentials, and application-only settings are intentionally excluded.

## Install

```bash
git clone https://github.com/YoshimuraKoei/dotfiles ~/.dotfiles
bash ~/.dotfiles/install.sh
exec zsh -l
```

The installer is safe to run again. Existing files that would be replaced by symlinks are moved to a timestamped directory under `~/.dotfiles-backup/`.

For GitHub Codespaces, select this repository under **GitHub Settings → Codespaces → Dotfiles** and enable automatic installation. GitHub runs `install.sh` for each new Codespace.

## Verify

```bash
bash scripts/check.sh
zsh -ic 'command -v eza; alias ls; abbr list; command -v nvim'
```
