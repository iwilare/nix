{ pkgs, ... }:
let username = "andrea";
    isDarwin = pkgs.stdenv.isDarwin; in
{
  home.username = username;
  nix.package = pkgs.nix;
  home.homeDirectory = if isDarwin then /Users/${username} else /home/${username};
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  services.ssh-agent.enable = !isDarwin;
  targets.genericLinux.enable = !isDarwin;
  programs.vscode.enable = isDarwin;
  programs.vscode.wsl = !isDarwin;
  programs = {
    fish.shellInit =
      ''
      ${if !isDarwin then
     "source /home/andrea/.nix-profile/etc/profile.d/**.fish" else ""}

      if test -z "$(pgrep ssh-agent)"
        eval (ssh-agent -c) > /dev/null
        set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
        set -Ux SSH_AGENT_PID $SSH_AGENT_PID
      end
      '';
    # Add this to /etc/shells
    #chsh -s /home/andrea/.nix-profile/bin/fish andrea
  };
}
