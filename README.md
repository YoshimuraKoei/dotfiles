# dotfiles

macOSのターミナル、Ghostty、Herdr、Neovimの設定をGitで管理する。zshの共通設定とNeovim設定はGitHub Codespacesでも使う。

## 管理対象

- `.zshrc`：macOSのzsh起動設定。共通設定とmacOS専用設定を読み込む
- `shell/shared.zsh`：macOSとCodespacesで共通の対話シェル設定
- `shell/macos.zsh`：macOS専用の対話シェル設定
- `shell/p10k.zsh`：Powerlevel10k設定。Codespacesでは専用の表示を加える
- `.config/nvim`：AstroNvimを使うNeovim設定
- `.config/ghostty`：Ghostty設定
- `.config/herdr/config.toml`：Herdr設定。セッションやログなどの状態ファイルは含めない

端末固有のパスや非公開の環境変数は、Git管理外の `~/.zshrc.local` と `~/.dotfiles/.config/ghostty/local.config` に置く。後者はGitで無視され、存在する場合だけGhosttyが読み込む。新しいファイルをコミットする前に、秘密情報や端末固有の値が含まれていないか確認する。

## macOSでの導入

先にGitHubへ認証し、Homebrewをインストールする。GhosttyとHerdrのアプリ本体は別途用意する。

```bash
git clone https://github.com/YoshimuraKoei/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
exec zsh -l
```

`install.sh` は、必要ならHomebrewで `eza` とNeovimをインストールし、共通のシェル依存関係を用意して、管理対象へシンボリックリンクを張る。リンク先に既存の設定がある場合は、日時付きの `~/.dotfiles-backup/` に退避する。

既存の `~/.zshrc` があるMacでは、新しいシェルを起動する前にバックアップを確認し、秘密情報やその端末だけで使う設定を `~/.zshrc.local` へ移す。このファイルはGitに含めない。Ghosttyでその端末にしかない画像や音声を使う場合は、パスを `~/.dotfiles/.config/ghostty/local.config` に記載する。

## GitHub Codespacesでの導入

GitHubの **Settings → Codespaces → Dotfiles** でこのリポジトリを選び、自動インストールを有効にする。新しいCodespaceの作成時にGitHubが `install.sh` を実行する。

Linux側の処理は必要なパッケージと互換性のある `tree-sitter` CLIを用意し、Neovim設定をリンクして、既存の `~/.zshrc` に共通zsh設定の読み込みを追加する。macOS専用の設定はリンクしない。

## 確認

```bash
bash ~/.dotfiles/scripts/check.sh
zsh -ic 'command -v eza; command -v nvim; alias ls; abbr list'
```
