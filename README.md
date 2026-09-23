# dotfiles

macOSのターミナル、Ghostty、Herdr、Neovimの設定をGitで管理する。zshの共通設定とNeovim設定はGitHub Codespacesでも使う。Android TerminalのDebian VMではzshの共通設定を使う。

## 管理対象

- `.zshrc`：macOSのzsh起動設定。共通設定とmacOS専用設定を読み込む
- `shell/shared.zsh`：macOS、Codespaces、Androidで共通の対話シェル設定
- `shell/macos.zsh`：macOS専用の対話シェル設定
- `shell/android.zsh` と `shell/android.bash`：Android Terminal用のzsh設定とbashからの起動処理
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
既存の `~/.zshrc` があるMacでは、新しいシェルを起動する前にバックアップを確認し、秘密情報やその端末だけで使う設定を `~/.zshrc.local` へ移す。このファイルはGitに含めない。

## GitHub Codespacesでの導入

GitHubの **Settings → Codespaces → Dotfiles** でこのリポジトリを選び、自動インストールを有効にする（設定済み）。新しいCodespaceの作成時にGitHubが自動で `install.sh` を実行する。

Linux側の処理は必要なパッケージと互換性のある `tree-sitter` CLIを用意し、Neovim設定をリンクして、既存の `~/.zshrc` に共通zsh設定の読み込みを追加する。macOS専用の設定はリンクしない。

## Android Terminalでの導入（Debian ARM64）

PixelのDebian VMでは `install-android.sh` を使う。既存の `install.sh` はCodespaces向けにNeovimとtree-sitterも導入するため、Androidでは実行しない。リポジトリを取得する前にGitを用意し、非公開リポジトリへアクセスできる状態にする。

```bash
git clone https://github.com/YoshimuraKoei/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install-android.sh
exec zsh -l
```

このスクリプトはDebian ARM64であることを確認し、`apt-get` でzsh、nano、Git、証明書を導入する。Debianのパッケージ一覧にezaがあれば併せて導入し、zsh-abbrも取得する。パッケージ導入にはroot権限または `sudo` が必要。Neovim、tree-sitter、Powerlevel10k、Ghostty、Herdrは導入しない。Androidではnanoを標準エディタに使い、zshはシンプルなプロンプトで起動する。

既存の `~/.zshrc` は日時付きの `~/.dotfiles-backup/` に退避してリンクへ切り替える。対話用の `~/.bashrc` にはzshを起動する一行を追加し、変更前のファイルを同じ場所にバックアップする。次回以降、`~/.bashrc` を読む対話bashはzshへ切り替わる。既存の `~/.bashrc` がシンボリックリンクの場合は自動編集を止めるため、リンク先の管理方針を確認する。

## macOSとCodespacesでの確認

```bash
bash ~/.dotfiles/scripts/check.sh
zsh -ic 'command -v eza; command -v nvim; alias ls; abbr list'
```
