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
    iwi-font = {
      url = "git+ssh://git@github.com/iwilare/font.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-vscode-extensions, iwi-dejavu, iwi-font, ... }:
    let
      home-modules = [
        ./home/home.nix
        ./home/vscode-settings.nix
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
      arguments = { inherit nix-vscode-extensions iwi-dejavu; };
      mkHomeConfig = system:
        let pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }; in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = arguments // { inherit pkgs; };
          modules = home-modules ++ host-home-modules;
        };
      mkNixosConfig = system:
        let pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }; in
        nixpkgs.lib.nixosSystem {
          specialArgs = arguments // { inherit pkgs; };
          modules = nixos-modules ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = arguments // { inherit pkgs; };
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
