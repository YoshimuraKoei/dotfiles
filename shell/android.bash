# Only replace the interactive Bash started by Android Terminal.
case $- in
  *i*) ;;
  *) return ;;
esac
[[ -n "${DOTFILES_ANDROID_SHELL:-}" ]] && return
command -v zsh >/dev/null 2>&1 || return
export DOTFILES_ANDROID_SHELL=1
exec zsh -l
