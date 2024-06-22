{ config, lib, pkgs, ... }:
let username = "andrea"; in
{
  options.isMacos = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };
  config = {
    home.username = username;
    home.homeDirectory = if config.isMacos then /Users/${username} else /home/${username};
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
    services.ssh-agent.enable = !config.isMacos;
    targets.genericLinux.enable = !config.isMacos;
    programs.vscode.enable = config.isMacos;
    programs.vscode.wsl = !config.isMacos;
    programs = {
      fish.shellInit =
        (if !config.isMacos then
          "source /home/andrea/.nix-profile/etc/profile.d/**.fish"
         else "")
        + ''
        if not test -e ~/.ssh/id_ed25519
          set temp_dir (mktemp -d)
          echo 'Adding ssh keys...'
          ${pkgs.git}/bin/git clone https://github.com/iwilare/ssh $temp_dir
          cp -r $temp_dir/. ~/.ssh/
          chmod 600 ~/.ssh/id_ed25519
          rm -rf $temp_dir
        end

        if test -z "$(pgrep ssh-agent)"
          eval (ssh-agent -c) > /dev/null
          set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
          set -Ux SSH_AGENT_PID $SSH_AGENT_PID
        end'';
    };
    # Add this to /etc/shells
    #chsh -s /home/andrea/.nix-profile/bin/fish andrea
  };
}
