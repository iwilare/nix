{
  description = "everything is here";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iwi-font = {
      url = "github:iwilare/font";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-vscode-extensions, iwi-font, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      arguments = { inherit pkgs system nix-vscode-extensions iwi-font; };
    in {
      nixosConfigurations."iwilare" = nixpkgs.lib.nixosSystem {
        specialArgs = arguments;
        modules = [
          ./system.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = arguments;
            home-manager.users."andrea".imports = [
              ./home.nix
              ./home-system.nix
            ];
          }
        ];
      };
      homeConfigurations."andrea" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = arguments;
        modules = [
          ./home.nix
          ./home-wsl.nix
          ./vscode-wsl.nix
        ];
      };
    };
}
