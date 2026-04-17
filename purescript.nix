{ pkgs, ... }:

{
  # PureScript 関連のパッケージ
  home.packages = with pkgs; [
    purs
    purescript-language-server
  ];

  # Neovim (nixvim) の PureScript 用設定
  programs.nixvim.plugins.lsp.servers.purescriptls = {
    enable = true;
    package = null;
  };
}
