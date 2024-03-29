{ config, pkgs, ... }: {
  home.stateVersion = "23.05";
  nix = {
    #package = pkgs.nix;
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
    extraConfig.credential.helper = "store";
    extraConfig.github.user = "iwilare";
    extraConfig.init.defaultBranch = "main";
    extraConfig.pull.rebase = false;
    extraConfig.push.autoSetupRemote = true;
    extraConfig.url."https://github.com/".insteadOf = [ "gh:" "github:" ];
    extraConfig.commit.gpgsign = true;
    extraConfig.gpg.format = "ssh";
    extraConfig.user.signingKey = "key::ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC070EeFAV0Uj5OSrIeSzPn7oj/Vr3Rj5eXAA13c/iug iwilare@gmail.com";
  };
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt.body = ''printf "λ %s%s%s> " (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)'';
      nix-run = "nix run nixpkgs#$argv[1] -- $argv[2..]";
      proj = "z $argv[1] && nc";
    };
    shellInit = ''set fish_greeting'';
    shellAbbrs = {
      m  = { expansion = "git commit -am '%'"; setCursor = true; };
      ns = { expansion = "nix shell nixpkgs#%"; setCursor = true; };
      gg = { expansion = "git clone git@github.com:%"; setCursor = true; };
      gsu = { expansion = "git remote set-url origin git@github.com:iwilare/(basename $PWD)%"; setCursor = true; };
    };
    shellAliases = {
      w  = "ack -il";
      e  = "explorer.exe .";
      d  = "git diff";
      l  = "eza --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type";
      la = "eza --git --icons --time-style=long-iso --long -s=type --all";
      t  = "eza --icons --tree -s=type --all";
      ta = "eza --icons --tree -s=type";

      sd = "git diff --stat";
      s  = "git status -sb --show-stash";
      p  = "git push";
      pp = "git push --force";
      ga = "git commit -a --amend --no-edit";
      gp = "git push --force";
      gd = "git diff";
      ll = "git log --pretty=format:'%C(auto) %h %ci [%an] %s%d' -n 10 --graph";
      save = "git commit -am (date '+%Y-%m-%d %H:%M:%S') && git push";

      RM = "rm -rfd";
      dn = "nextd";
      dp = "prevd";
      diff = "diff-so-fancy";

      n  = "nix develop";
      c  = "code .";
      nc = "nix develop --command code .";

      nr  = "nix-run";
      no  = "code /etc/nixos/";
      nos = "sudo nixos-rebuild switch";
      hm  = "cd ~/.config/home-manager; code .";
      hms = "home-manager switch -b backup";
      hemp = "hms && ga && gp";
    };
    plugins = [
      # {
      #   name = "z";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "jethrokuan";
      #     repo = "z";
      #     rev = "85f863f";
      #     sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      #   };
      # }
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
