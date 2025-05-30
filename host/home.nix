{ pkgs, lib, inputs, ... }:
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

  programs.vscode.enable = true;
  programs.vscode.profiles.default.extensions = [];
  programs.vscode.package = if isDarwin then pkgs.vscode else
    pkgs.writeTextFile {
      name = "vscode-windows";
      executable = true;
      destination = "/bin/code";
      derivationArgs = {
        pname = "vscode";
        version = "1.1000.0"; # Placeholder version
        meta.mainProgram = "code";
      };
      text = ''
        #!/bin/sh
        '/mnt/c/Users/Andrea/AppData/Local/Programs/Microsoft VS Code/bin/code' "$@"
      '';
    };

  programs = {
    fish.shellInit = ''
      ${if !isDarwin then "source /home/andrea/.nix-profile/etc/profile.d/**.fish" else ""}
      start_ssh_agent
    '';
  };
  home.activation.sync-vscode = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "git" ] ''

    WINDOWS_VSCODE_SETTINGS=/mnt/c/Users/Andrea/AppData/Roaming/Code/User/settings.json
    WINDOWS_VSCODE_KEYBINDINGS=/mnt/c/Users/Andrea/AppData/Roaming/Code/User/keybindings.json
    WINDOWS_VSCODE_EXTENSIONS=/mnt/c/Users/Andrea/.vscode/extensions/

    HM_VSCODE_SETTINGS=.config/Code/User/settings.json
    HM_VSCODE_KEYBINDINGS=.config/Code/User/keybindings.json
    HM_VSCODE_EXTENSIONS=.vscode/extensions

    backup_file_if_exists() {
      local file="$1"
      if [ -f "$file" ]; then
        cp "$file" "$file.backup-$(date +%Y%m%d-%H%M%S)"
      fi
    }

    # Backup existing config files
    backup_file_if_exists "$WINDOWS_VSCODE_SETTINGS"
    backup_file_if_exists "$WINDOWS_VSCODE_KEYBINDINGS"

    # Ensure target directories exist
    mkdir -p "$(dirname "$WINDOWS_VSCODE_SETTINGS")"
    mkdir -p "$(dirname "$WINDOWS_VSCODE_KEYBINDINGS")"

    # Copy config files
    cp -f "$HM_VSCODE_SETTINGS" "$WINDOWS_VSCODE_SETTINGS"
    cp -f "$HM_VSCODE_KEYBINDINGS" "$WINDOWS_VSCODE_KEYBINDINGS"

    chmod 777 "$WINDOWS_VSCODE_SETTINGS" "$WINDOWS_VSCODE_KEYBINDINGS"

    # mkdir -p "$WINDOWS_VSCODE_EXTENSIONS"
    # for ext in $HM_VSCODE_EXTENSIONS; do
    #   dest=$WINDOWS_VSCODE_EXTENSIONS/$(basename "$ext")
    #   [ -e "$dest" ] || ${pkgs.rsync}/bin/rsync -aLv "$ext" "$dest"
    # done
  '';
}
