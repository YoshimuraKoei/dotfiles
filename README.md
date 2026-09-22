# dotfiles

Personal terminal, Ghostty, Herdr, and Neovim configuration for macOS, with a shared shell and Neovim setup for GitHub Codespaces.

## Layout

- `.zshrc`, `shell/macos.zsh`, and `shell/shared.zsh`: macOS shell entry point and shared interactive behavior
- `shell/p10k.zsh`: Powerlevel10k, including the Codespaces prompt indicator
- `.config/nvim`: AstroNvim configuration
- `.config/ghostty`: macOS terminal settings
- `.config/herdr/config.toml`: Herdr preferences; sessions, logs, and other state stay local

Machine-specific paths and private environment values belong in `~/.zshrc.local` and `.config/ghostty/local.config`. The latter is ignored by Git and loaded optionally by Ghostty. Review every new file before committing it.

## macOS

Authenticate to GitHub and install Homebrew first. Ghostty and Herdr are separate applications; this repository configures them when installed.

```bash
git clone https://github.com/YoshimuraKoei/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
exec zsh -l
```

The installer installs `eza` and Neovim with Homebrew when missing, installs the shared shell dependencies, and links the managed settings. Existing link targets are moved under a timestamped `~/.dotfiles-backup/` directory. On a Mac with an existing shell setup, review the backup and move private or machine-specific lines into `~/.zshrc.local` before starting a new shell. This file stays outside Git.

For optional Ghostty assets that exist only on one Mac, put their settings in `~/.dotfiles/.config/ghostty/local.config`. For example, a custom image or bell sound can be configured there without adding its path to Git.

## GitHub Codespaces

Select this repository under **GitHub Settings → Codespaces → Dotfiles** and enable automatic installation. GitHub runs `install.sh` for each new Codespace. The Linux branch retains package installation, builds a compatible `tree-sitter` CLI, links Neovim, and adds the shared zsh settings to the Codespace's existing `.zshrc`. macOS-only configuration is not linked there.

## Verify

```bash
bash ~/.dotfiles/scripts/check.sh
zsh -ic 'command -v eza; command -v nvim; alias ls; abbr list'
```
