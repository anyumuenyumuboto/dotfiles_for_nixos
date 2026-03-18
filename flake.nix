{
  description = "flake ";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # [nix-community/nixvim: Configure Neovim with Nix! [maintainers=@GaetanLepage, @traxys, @mattsturgeon, @khaneliman]](https://github.com/nix-community/nixvim)
      # url = "github:nix-community/nixvim";
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, home-manager, ... }: {

    # 🔹 overlay を outputs にエクスポート（任意だが推奨）
    overlays = { purescript = inputs.purescript-overlay.overlays.default; };

    # The host with the hostname `nixos` will use this configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # 🔹 nixpkgs に overlay を適用
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

        #wsl-setting
        nixos-wsl.nixosModules.default
        {
          system.stateVersion = "25.11";
          wsl.enable = true;
        }

        # 🔹 overlay を適用するためのモジュール
        {
          nixpkgs.overlays = [ inputs.purescript-overlay.overlays.default ];
        }

        # home-manager settings
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.nixos = { pkgs, ... }: {
            imports = [
              ./home.nix # 既存の設定ファイル
              # nixvim の Home Manager モジュールを追加
              inputs.nixvim.homeModules.nixvim
            ];
          };
        }
      ];
    };
  };
}

