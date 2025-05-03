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
    iwi-dejavu = {
      url = "github:iwilare/iwi-dejavu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iwi-consolas = {
      url = "git+ssh://git@github.com/iwilare/iwi-consolas";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
    fuse-archive-yazi = {
      url = "github:dawsers/fuse-archive.yazi";
      flake = false;
    };
    material-fox-updated = {
      url = "https://github.com/edelvarden/material-fox-updated/releases/download/v2.0.0/chrome.zip";
      flake = false;
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, nix-vscode-extensions, iwi-dejavu, iwi-consolas, ... }:
    let
      home-modules = [
        ./home/home.nix
        ./home/vscode-settings.nix
        ./home/firefox.nix
      ];
      nixos-modules = [
        ./nixos/system.nix
        ./nixos/hardware-configuration.nix
      ];
      nixos-home-modules = [
        ./nixos/home.nix
      ];
      host-home-modules = [
        ./host/home.nix
        ./host/vscode-wsl.nix
      ];
      mkHomeConfig = system:
        let pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }; in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs system; };
          modules = home-modules ++ host-home-modules
          #  ++ {
          #   nixpkgs.config.allowUnfree = true;
          # }
          ;
        };
      mkNixosConfig = system:
        let pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }; in
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system; };
          modules = nixos-modules ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = { inherit inputs system; };
              home-manager.users."andrea".imports = home-modules ++ nixos-home-modules;
            }
          ];
        };
    in {
      nixosConfigurations."iwilare" = mkNixosConfig "x86_64-linux";
      homeConfigurations."andrea" = mkHomeConfig "x86_64-linux";
      homeConfigurations."andrea-macos" = mkHomeConfig "x86_64-darwin";
    };
}
