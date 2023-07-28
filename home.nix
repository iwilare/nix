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
    inherit (home-manager-config.programs) ssh git;
    fish = (prev: prev // {
      shellInit =
        ''
          ${prev.shellInit}
          if test -z (pgrep ssh-agent)
            eval (ssh-agent -c) > /dev/null
            set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
            set -Ux SSH_AGENT_PID $SSH_AGENT_PID
          end
        '';
    }) home-manager-config.programs.fish;
    #vscode = home-manager-config.programs.vscode;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);
  programs.home-manager.enable = true;
  programs.home-manager.path = "$HOME/home-manager";
}
