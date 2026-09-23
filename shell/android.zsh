# Android Terminal starts Bash; install-android.sh links this file as ~/.zshrc.
autoload -Uz compinit
compinit

DOTFILES_EDITOR=nano
DOTFILES_SKIP_POWERLEVEL10K=1
DOTFILES_GHOSTTY_KEYS=0
source "$HOME/.dotfiles/shell/shared.zsh"
unset DOTFILES_EDITOR DOTFILES_SKIP_POWERLEVEL10K DOTFILES_GHOSTTY_KEYS

PROMPT='%n@%m:%~%# '
