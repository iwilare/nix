{
  description = "Home Manager configuration of andrea";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      homeConfigurations."andrea" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (let
            username = "andrea";
            iwi-config = (import ./configuration.nix) { pkgs = pkgs; config = { }; };
            iwi-hm = iwi-config.home-manager.users.${username};
          in {
            home.username = username;
            home.homeDirectory = /home/${username};
            home.stateVersion = "23.05";
            home.packages = iwi-hm.home.packages;
            programs.home-manager.enable = true;
            targets.genericLinux.enable = true;
            programs = {
              inherit (iwi-hm.programs)
                ssh git direnv zoxide ripgrep btop bat eza;
              fish = (prev:
                prev // {
                  # No service is running on WSL so start it
                  shellInit =
                    "${prev.shellInit}
                      source /home/andrea/.nix-profile/etc/profile.d/*.fish
                     
                      if not test -e ~/.ssh/id_ed25519
                        set temp_dir (mktemp -d)
                        echo 'Adding ssh keys...'
                        ${pkgs.git}/bin/git clone https://github.com/iwilare/ssh $temp_dir
                        cp -r $temp_dir/. ~/.ssh/
                        chmod 600 ~/.ssh/id_ed25519
                        rm -rf $temp_dir
                      end
                      
                      if test -z (pgrep ssh-agent)
                        eval (ssh-agent -c) > /dev/null
                        set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
                        set -Ux SSH_AGENT_PID $SSH_AGENT_PID
                      end";
                }) iwi-hm.programs.fish;
              vscode.wsl.enable = true;
            };
          })
          ./wsl.nix
          # Add this to /etc/shells
          #chsh -s /home/andrea/.nix-profile/bin/fish andrea
        ];
      };
    };
}
