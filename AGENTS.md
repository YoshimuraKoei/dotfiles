# dotfilesの作業方針

- 認証情報、APIキー、認証キャッシュ、端末固有の秘密情報をコミットしない。
- `install.sh` は再実行しても安全な状態を保ち、macOSとGitHub Codespacesの両方で動作させる。Android Terminalには `install-android.sh` を使い、Neovimやtree-sitterを導入しない。
- 既存の設定とリンク先が競合する場合は、リンク作成前に `~/.dotfiles-backup/` へ退避する。
- 共通の対話シェル設定は `shell/shared.zsh`、macOS専用の設定は `shell/macos.zsh`、Android専用の設定は `shell/android.zsh` と `shell/android.bash` に置く。端末固有の設定は `~/.zshrc.local` などGit管理外に置く。
- シェル設定またはインストーラーを変更したら `bash scripts/check.sh` を実行する。
