# Keep the instant prompt before other startup work.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  source "$HOME/.dotfiles/shell/macos.zsh"
fi
source "$HOME/.dotfiles/shell/shared.zsh"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
