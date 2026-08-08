{
  config,
  pkgs,
  inputs,
  purescriptEnabled ? false,
  ...
}:

let
  # 秘密情報を格納するファイルのパス
  localGitConfig = "${config.home.homeDirectory}/dotfiles_for_nixos/.gitconfig-local";
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ]
  ++ (if purescriptEnabled then [ ./purescript.nix ] else [ ]);

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # shellHook を自動的に設定するか（基本は true で OK）
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.firefox.enable = true;

  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";
    };

    # ローカルの設定ファイルを含める
    includes = [ { path = localGitConfig; } ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nixos_update = "sudo nixos-rebuild switch --flake .#nixos";
      purescript_update = "sudo nixos-rebuild switch --flake .#purescript";
    };
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
    # vim-sandwich が unfreeライセンスと判定されたため Unfree ライセンスのプラグインを許可
    nixpkgs.config.allowUnfree = true;

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

    opts = {
      shell = "${pkgs.zsh}/bin/zsh";
    };

    plugins = {
      # [lsp - nixvim docs](https://nix-community.github.io/nixvim/plugins/lsp/index.html)
      lsp = {
        enable = true;
        servers = {
          lua_ls.enable = true; # Lua Language Server を有効化
          ts_ls.enable = true; # TypeScript Language Server を有効化
          idris2_lsp.enable = true;
        };
      };

      # barbar.nvim
      barbar = {
        enable = true;
      };

      # flash.nvim
      flash = {
        enable = true;
      };

      # gitsigns.nvim
      gitsigns = {
        enable = true;
        lazyLoad.settings.event = [ "BufReadPost" ];
        settings.on_attach = ''
          function(bufnr)
            vim.keymap.set('n', ']c', '<cmd>lua require"gitsigns".next_hunk()<CR>', { buffer = bufnr })
            vim.keymap.set('n', '[c', '<cmd>lua require"gitsigns".prev_hunk()<CR>', { buffer = bufnr })
          end
        '';
      };

      # idris2-nvim
      idris2 = {
        enable = true;
        settings = {
          server = {
            # ★ ここを { __raw = "..." } で囲む ★
            on_attach = {
              __raw = ''
                function(client, bufnr)
                  -- バッファローカルなキーマップを設定するヘルパー関数
                  local map = function(mode, key, action, desc)
                    vim.keymap.set(mode, key, action, { buffer = bufnr, desc = desc })
                  end

                  -- ==========================================
                  -- コードアクション
                  -- ==========================================
                  map('n', '<leader>iac', function() require('idris2.code_action').add_clause() end, 'Idris: Add clause')
                  map('n', '<leader>ics', function() require('idris2.code_action').case_split() end, 'Idris: Case split')
                  map('n', '<leader>imc', function() require('idris2.code_action').make_case() end, 'Idris: Make case')
                  map('n', '<leader>imw', function() require('idris2.code_action').make_with() end, 'Idris: Make with')
                  map('n', '<leader>iml', function() require('idris2.code_action').make_lemma() end, 'Idris: Make lemma')
                  map('n', '<leader>ies', function() require('idris2.code_action').expr_search() end, 'Idris: Expression search')

                  -- ==========================================
                  -- メタ変数（穴）のナビゲーション
                  -- ==========================================
                  map('n', '<leader>ign', function() require('idris2.metavars').goto_next() end, 'Idris: Next metavar')
                  map('n', '<leader>igp', function() require('idris2.metavars').goto_prev() end, 'Idris: Previous metavar')
                  map('n', '<leader>ira', function() require('idris2.metavars').request_all() end, 'Idris: List all metavars')
                end
              '';
            };
          };
        };
      };

      # img-clip.nvim
      img-clip = {
        enable = true;
        lazyLoad.settings.cmd = "PasteImage";
      };

      # lazygit.nvim
      lazygit = {
        enable = true;
        lazyLoad.settings.cmd = "LazyGit";
      };

      # lualine.nvim
      lualine.enable = true;

      # lz.n
      lz-n.enable = true;

      # neo-tree.nvim
      neo-tree.enable = true;

      # vim-sandwich
      sandwich.enable = true;

      # telescope.nim
      telescope = {
        enable = true;
        lazyLoad.settings.cmd = "Telescope";
      };

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
      # [folke/flash.nvim: Navigate your code with search labels, enhanced character motions and Treesitter integration](https://github.com/folke/flash.nvim)
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action.__raw = ''

          function()
            require('flash').jump()
          end
        '';
        options = {
          desc = "Flash";
          silent = true;
        };
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action.__raw = ''

          function()
            require('flash').treesitter()
          end
        '';
        options = {
          desc = "Flash Treesitter";
          silent = true;
        };
      }
      {
        mode = "o";
        key = "r";
        action.__raw = ''

          function()
            require('flash').remote()
          end
        '';
        options = {
          desc = "Remote Flash";
          silent = true;
        };
      }
      {
        mode = [
          "o"
          "x"
        ];
        key = "R";
        action.__raw = ''

          function()
            require('flash').treesitter_search()
          end
        '';
        options = {
          desc = "Treesitter Search";
          silent = true;
        };
      }
      {
        mode = "c";
        key = "<c-s>";
        action.__raw = ''

          function()
            require('flash').toggle()
          end
        '';
        options = {
          desc = "Toggle Flash Search";
          silent = true;
        };
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
    OCO_AI_PROVIDER = "ollama";
    OCO_MODEL = "qwen2.5:3b";
    OCO_API_URL = "http://localhost:11434";
  };

  home.packages = with pkgs; [
    aider-chat
    bat
    bottom
    docker
    fzf
    gcc
    geckodriver
    gitleaks
    gnumake
    go-task
    husky
    lazygit
    llama-cpp
    nixfmt
    nixfmt-tree
    nodejs_24
    opencommit
    pijul
    playwright-test
    ripgrep
    translate-shell
    trash-cli
    tree
    tree-sitter
    vhs
    yazi
    stylua
    zellij
  ];

  home.stateVersion = "25.11";
}
