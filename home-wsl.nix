{ config, pkgs, ... }:
let username = "andrea"; in
{
  home.username = username;
  home.homeDirectory = /home/${username};
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  services.ssh-agent.enable = true;
  targets.genericLinux.enable = true;
  programs = {
    # vscode.wsl = iwi-hm.programs.vscode;
    fish.shellInit = ''
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
      end'';
  };
  # Add this to /etc/shells
  #chsh -s /home/andrea/.nix-profile/bin/fish andrea
}
