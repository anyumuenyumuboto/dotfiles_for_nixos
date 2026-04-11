# nixosとhome managerの設定

wsl上のnixosで試しています

以下を参考にしました
[nixos入門1: wslで使うnixos (Linux初心者のための究極なOS)](https://zenn.dev/tositada/books/1c1564531ec8fc)

## ディレクトリ構成

Flakesベースの設定です

```
.
├── configuration.nix
├── flake.lock
├── flake.nix
├── home.nix
└── README.md
```


## Usage

各ファイルを編集したら

```console
sudo nixos-rebuild switch --flake ~/dotfiles_for_nixos
```

で更新

以下のコマンドを使えば、flake.lockも更新できる

```console
sudo nixos-rebuild switch --flake ~/dotfiles_for_nixos --upgrade
```

### format

ディレクトリ全体を再帰的にフォーマット

```console
treefmt
```

### システム自体のアップデート

```
# flake.lock のアップデート
nix flake update
# アップデートの適用
sudo nixos-rebuild switch --flake .
```

参考: 
- [Updating NixOS - Official NixOS Wiki](https://wiki.nixos.org/wiki/Updating_NixOS)
- [システムのアップデート | NixOS & Flakes Book](https://nixos-and-flakes-ja.hayao0819.com/nixos-with-flakes/update-the-system)

