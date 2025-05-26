{ pkgs, lib, ... }:
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
  programs.vscode.package = if isDarwin then pkgs.vscode else 
    pkgs.emptyDirectory.overrideAttrs (old: {
      pname = "vscode";
      version = "1.1000.0"; # Placeholder version
    });
  
  programs = {
    fish.shellInit =
      ''
      ${if !isDarwin then "source /home/andrea/.nix-profile/etc/profile.d/**.fish" else ""}

      if test -z "$(pgrep ssh-agent)"
        eval (ssh-agent -c) > /dev/null
        set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
        set -Ux SSH_AGENT_PID $SSH_AGENT_PID
      end
      '';
      # Add this to /etc/shells
      # chsh -s /home/andrea/.nix-profile/bin/fish andrea
  };
  home.activation.sync-vscode = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "git" ] ''

    WINDOWS_VSCODE_SETTINGS=/mnt/c/Users/Andrea/AppData/Roaming/Code/User/settings.json
    WINDOWS_VSCODE_KEYBINDINGS=/mnt/c/Users/Andrea/AppData/Roaming/Code/User/keybindings.json

    HM_VSCODE_SETTINGS=.config/Code/User/settings.json
    HM_VSCODE_KEYBINDINGS=.config/Code/User/keybindings.json

    if [ -f "$WINDOWS_VSCODE_SETTINGS" ]; then
      mv "$WINDOWS_VSCODE_SETTINGS" "$WINDOWS_VSCODE_SETTINGS"-backup
    fi
    if [ -f "$WINDOWS_VSCODE_KEYBINDINGS" ]; then
      mv "$WINDOWS_VSCODE_KEYBINDINGS" "$WINDOWS_VSCODE_SETTINGS"-backup
    fi

    # Copy the new settings file from the Nix store to the Windows path
    cp -f "$HM_VSCODE_SETTINGS" "$WINDOWS_VSCODE_SETTINGS"
    cp -f "$HM_VSCODE_KEYBINDINGS" "$WINDOWS_VSCODE_KEYBINDINGS"
  '';
}
