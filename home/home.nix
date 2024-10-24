{ pkgs, ... }: {
  home.stateVersion = "23.05";
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "flakes" "nix-command" ];
  };
  home.packages = with pkgs; [
    #texlive.combined.scheme-full
    #(agda.withPackages [ agdaPackages.standard-library agdaPackages.agda-categories ])
    zip
    unzip
    neofetch
    ack
    dua       # Disk usage analyzer
    gource    # SVC visualization
    hyperfine # Command-line benchmarking tool
    pv        # Monitor the progress of data through a pipe
    nixfmt
    nix-tree
  ];
  programs.direnv  = { enable = true; nix-direnv.enable = true; };
  #programs.atuin   = { enable = true; enableFishIntegration = true; };
  programs.zoxide  = { enable = true; enableFishIntegration = true; };
  programs.ssh     = { enable = true; package = pkgs.openssh; addKeysToAgent = "yes"; };
  programs.ripgrep = { enable = true; };
  programs.btop    = { enable = true; };
  programs.bat     = { enable = true; };
  programs.eza     = { enable = true; };
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
    userName  = "iwilare";
    userEmail = "iwilare@gmail.com";

    extraConfig.color.ui = true;
    extraConfig.core.askPass = "";
    extraConfig.core.fileMode = true;
    extraConfig.core.editor = "code --wait";
    extraConfig.credential.helper = "store";
    extraConfig.github.user = "iwilare";
    extraConfig.init.defaultBranch = "main";
    extraConfig.push.autoSetupRemote = true;
    extraConfig.pull.rebase = true;
    #extraConfig.merge.autoStash = true;
    extraConfig.url."https://github.com/".insteadOf = [ "gh:" "github:" ];
    extraConfig.commit.gpgsign = true;
    extraConfig.gpg.format = "ssh";
    extraConfig.user.signingKey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC070EeFAV0Uj5OSrIeSzPn7oj/Vr3Rj5eXAA13c/iug iwilare@gmail.com";
  };
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt.body = ''
        set -l last_status $status
        set -l prompt_nix ""
        set -l prompt_stat ""
        set -l prompt_folder (set_color $fish_color_cwd)(prompt_pwd)(set_color normal)
        if test -n "$IN_NIX_SHELL"; set prompt_nix "(nix) "; end
        if test $last_status -ne 0; set prompt_stat (set_color red)" [$last_status]"(set_color normal); end
        echo -n "λ "$prompt_nix$prompt_folder$prompt_stat"> "
      '';
      nix-run = "nix run nixpkgs#$argv[1] -- $argv[2..]";
      proj = "z $argv[1] && n";
    };
    shellInit = ''set fish_greeting'';
    shellAbbrs = {
      q  = { expansion = "git commit -am '%'"; setCursor = true; };
      a  = { expansion = "git commit -a --amend -m '%'"; setCursor = true; };
      ns = { expansion = "nix shell nixpkgs#%"; setCursor = true; };
      gg = { expansion = "git clone git@github.com:%"; setCursor = true; };
      o  = { expansion = "git remote add-url origin git@github.com:iwilare/(basename $PWD)%"; setCursor = true; };
      yt = { expansion = "nix-run youtube-dl -x --audio-format mp3 --audio-quality 0 -o 'C:\\Dropbox\\Music\\%%(title)s.%%(ext)s' '|'"; setCursor = "|"; };
    };
    shellAliases = {
      w  = "ack -il";
      e  = "explorer.exe .";
      l  = "eza --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type";
      la = "eza --git --icons --time-style=long-iso --long -s=type --all";
      t  = "eza --icons --tree -s=type --all";
      ta = "eza --icons --tree -s=type";

      d  = "git diff";
      ds = "git diff --stat";
      s  = "git status --show-stash";
      p  = "git push";
      ll = "git log --pretty=format:'%C(auto) %h %ci [%an] %s%d' -n 10 --graph";
      pf = "git push --force";
      fix = "git commit -a --amend --no-edit";
      save = "git commit -am (date '+%Y-%m-%d %H:%M:%S') && git push";

      RM = "rm -rfd";
      dn = "nextd";
      dp = "prevd";
      diff = "diff-so-fancy";

      n  = "nix develop";
      c  = "nix develop --command code .";
      b  = "nix build && cd result";
      nr = "nix-run";
      nl = "nix log";

      no  = "code /etc/nixos/";
      nod = "cd /etc/nixos/";
      nos = "sudo nixos-rebuild switch";
      hm  = "code ~/.config/home-manager";
      hmd = "cd ~/.config/home-manager";
      hms = "home-manager switch -b backup --flake ~/.config/home-manager#${if !pkgs.stdenv.isDarwin then "andrea" else "andrea-macos"}";
      hmsave = "save && hms";
    };
    plugins = [
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
  };
}
