{ config, pkgs, ... }@args:
let username = "andrea";
    iwiconfig = (import ./configuration.nix) args;
    home-manager-config = iwiconfig.home-manager.users.${username}; in
{
  home.username = username;
  home.homeDirectory = /home/${username};
  home.stateVersion = "23.05";
  home.packages = home-manager-config.home.packages;
  programs = {
    inherit (home-manager-config.programs) ssh git zoxide ripgrep btop bat exa;
    fish = (prev: prev // {
      # No service is running on WSL so start it
      shellInit =
        ''
          ${prev.shellInit}
          source /home/andrea/.nix-profile/etc/profile.d/*.fish

          if test -z (pgrep ssh-agent)
            eval (ssh-agent -c) > /dev/null
            set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
            set -Ux SSH_AGENT_PID $SSH_AGENT_PID
          end
        '';
    }) home-manager-config.programs.fish;
    vscode.wsl = home-manager-config.programs.vscode;
  };

  targets.genericLinux.enable = true;
  # Add this to /etc/shells
  #chsh -s /home/andrea/.nix-profile/bin/fish andrea
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);
  programs.home-manager.enable = true;
  # custom version with vscode.wsl
  programs.home-manager.path = "$HOME/home-manager";
}
