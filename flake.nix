{
  description = "flake ";

  inputs = {
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # [nix-community/nixvim: Configure Neovim with Nix! [maintainers=@GaetanLepage, @traxys, @mattsturgeon, @khaneliman]](https://github.com/nix-community/nixvim)
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      ...
    }:
    let
      mkSystem =
        { purescriptEnabled ? false }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            nixos-wsl.nixosModules.default
            {
              system.stateVersion = "25.11";
              wsl.enable = true;
              nixpkgs.overlays = [ inputs.purescript-overlay.overlays.default ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs purescriptEnabled;
                };
                users.nixos = import ./home.nix;
              };
            }
          ];
        };
    in
    {
      overlays = {
        purescript = inputs.purescript-overlay.overlays.default;
      };

      nixosConfigurations = {
        nixos = mkSystem { purescriptEnabled = false; };
        purescript = mkSystem { purescriptEnabled = true; };
      };
    };
}
