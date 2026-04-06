{ config, pkgs, ... }:

let
  # 秘密情報を格納するファイルのパス
  localGitConfig =
    "${config.home.homeDirectory}/dotfiles_for_nixos/.gitconfig-local";
in {

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  programs.git = {
    enable = true;

    settings = { init.defaultBranch = "main"; };

    # ローカルの設定ファイルを含める
    includes = [{ path = localGitConfig; }];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = { nixos_update = "sudo nixos-rebuild switch"; };
  };

  programs.gh = {
    enable = true;

    # 設定項目 ( ~/.config/gh/config.yml に相当 )
    settings = {
      # Git プロトコルの設定 (https または ssh)
      git_protocol = "ssh";

      # 使用するエディタ
      editor = "neovim";
    };
  };

  programs.nixvim = {

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "purescript" ];
        callback = {
          __raw = ''
            function()
              vim.opt.expandtab = true
              vim.opt.shiftwidth = 2
              vim.opt.softtabstop = 2
              vim.opt.tabstop = 2
            end
          '';
        };
      }
      {
        event = [ "TextYankPost" ];
        pattern = [ "*" ];
        callback = {
          __raw = ''
            function()
              vim.highlight.on_yank()
            end
          '';
        };
      }
    ];

    enable = true;

    opts = { shell = "${pkgs.zsh}/bin/zsh"; };

    plugins = {
      # [lsp - nixvim docs](https://nix-community.github.io/nixvim/plugins/lsp/index.html)
      lsp = {
        enable = true;
        servers = {
          lua_ls.enable = true; # Lua Language Server を有効化
          ts_ls.enable = true; # TypeScript Language Server を有効化
          purescriptls = {
            enable = true; # Purescript Language Server を有効化
            package = null;
          };
        };
      };

      # barbar.nvim
      barbar = { enable = true; };

      # img-clip.nvim
      img-clip.enable = true;

      # gitsigns.nvim
      gitsigns.enable = true;

      # lazygit.nvim
      lazygit.enable = true;

      # lualine.nvim
      lualine.enable = true;

      # neo-tree.nvim
      neo-tree.enable = true;

      # vim-sandwich
      sandwich.enable = true;

      # nvim-treesitter
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          folding.enable = true;
        };
      };

      # undotree.nvim
      undotree.enable = true;

      # barbar.nvimのためにweb-devicons を明示的に有効化（警告を解消）
      web-devicons.enable = true;

    };

    # nixvimにはないがnixpkgsにあるプラグイン
    extraPlugins = [
      pkgs.vimPlugins.iceberg-vim
      pkgs.vimPlugins.fyler-nvim
      pkgs.vimPlugins.markview-nvim
      pkgs.vimPlugins.numb-nvim
      pkgs.vimPlugins.live-preview-nvim
      pkgs.vimPlugins.open-browser-vim
    ];

    keymaps = [
      # [romgrk/barbar.nvim: The neovim tabline plugin.](https://github.com/romgrk/barbar.nvim/)
      {
        mode = "n";
        action = "<Cmd>BufferPrevious<CR>";
        key = "<A-,>";
      }
      {
        mode = "n";
        key = "<A-.>";
        action = "<Cmd>BufferNext<CR>";
      }
      {
        mode = "n";
        key = "<A-c>";
        action = "<Cmd>BufferClose<CR>";
      }
    ];

    extraConfigLua = ''
      -- カラースキームを適用
      vim.cmd("colorscheme iceberg")
    '';

  };

  programs.starship.enable = true;

  # 環境変数を設定
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    bat
    bottom
    gcc
    gemini-cli
    gh
    git
    gitleaks
    gnumake
    go-task
    husky
    lazygit
    nixfmt-classic
    nodejs_24
    opencommit
    purs # PureScript コンパイラ（overlay 提供）
    purescript-language-server # LSP サーバー（overlay 提供）
    pijul
    qwen-code
    ripgrep
    starship
    translate-shell
    trash-cli
    tree
    tree-sitter
    vhs
    yazi
    stylua
  ];

  home.stateVersion = "25.11";
}
