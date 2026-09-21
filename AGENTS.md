# Dotfiles Instructions

- Never commit credentials, API keys, auth caches, or machine-specific secrets.
- Keep `install.sh` idempotent and compatible with macOS and GitHub Codespaces.
- Preserve existing user files by moving conflicts under `~/.dotfiles-backup/` before linking.
- Put shared interactive shell behavior in `shell/shared.zsh`; keep machine-specific behavior outside this repository.
- Run `bash scripts/check.sh` after changing shell or installer files.
