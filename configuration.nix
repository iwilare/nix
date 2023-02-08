{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-22.05.tar.gz}/nixos")
  ];

  #networking.interfaces.wlp2s0.useDHCP = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  security.pam.services.andrea.enableGnomeKeyring = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 0;
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  fonts.fontconfig.enable = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  networking.hostName = "iwilare";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  nixpkgs.config.allowUnfree = true;
  programs.dconf.enable = true; # https://www.reddit.com/r/NixOS/comments/b255k5/home_manager_cannot_set_gnome_themes/
  programs.nm-applet.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.illum.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];
  services.printing.enable = true;
  services.tumbler.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  sound.mediaKeys.enable = true;
  sound.mediaKeys.volumeStep = "10%";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";
  system.stateVersion = "23.05";
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Tallinn";
  };
  users.users = {
    root = {
      shell = pkgs.fish;
    };
    andrea = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
    };
  };
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=7200
  '';
  services.xserver = {
    autoRepeatDelay = 300;
    autoRepeatInterval = 25;
    desktopManager.wallpaper.mode = "fill";
    desktopManager.xterm.enable = false;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "andrea";
    displayManager.defaultSession = "none+i3";
    displayManager.lightdm.enable = true;
    dpi = 96;
    enable = true;
    layout = "it";
    libinput.enable = true;
    libinput.mouse.scrollMethod = "button";
    libinput.mouse.accelSpeed = "25";
    windowManager.i3.enable = true;
    #xkbOptions = "caps:ctrl_modifier,eurosign:e";
    xkbOptions = "caps:escape,eurosign:e";

    #videoDrivers = [ "nvidia" ];

    #screenSection = ''
    #  Option "metamodes" "DP-2: 1920x1080_144 +0+0 {rotation=left}, HDMI-0: 2560x1440_144 +1080+240, DP-0: 1920x1080_144 +3640+420"
    #'';
  };

  services.picom = {
    enable = true;
    fade = true;
    fadeDelta = 5;
    shadow = false;
    backend = "glx";
    vSync = true;
    shadowOpacity = 1.0;
    settings = {
      shadow-radius = 10;
      frame-opacity = 0;
    };
  };

  environment.variables.TERMINAL = "alacritty";
  fonts.fonts = [
    pkgs.ipafont
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    (pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVuSansMono Nerd Font"
      "IPAGothic"
    ];
    sansSerif = [
      "Noto Sans"
      "IPAPGothic"
    ];
    serif = [
      "Noto Serif"
      "IPAPMincho"
    ];
  };
  environment.systemPackages = with pkgs; [
    (agda.withPackages
       [
         agdaPackages.standard-library
         agdaPackages.agda-categories
         /*(agdaPackages.mkDerivation {
           version="1.7.1";
           meta.broken = false;
           pname = "agda-categories";
           src = /home/andrea/agda-categories;
           buildInputs = [
             agdaPackages.standard-library
           ];
           buildPhase = '''';
         })*/
       ])
    texlive.combined.scheme-full
    #ghc
    #rustup
    #stack

    dropbox
    spotify
    tdesktop
    vscode
    discord
    google-chrome
    teamviewer

    pcmanfm
    xfce.xfce4-terminal
    xfce.thunar

    rofi
    pavucontrol

    zip
    unzip
    neofetch
    git

    exa
    bat
    ack
    dua        # Disk usage analyzer
    gource     # SVC visualization
    hyperfine  # Command-line benchmarking tool
    pv         # Monitor the progress of data through a pipe
    btop
  ];
  services.teamviewer.enable = true;

  programs.noisetorch = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };
  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/${pkgs.qt5.qtbase.qtPluginPrefix}";
      QML2_IMPORT_PATH = "/run/current-system/sw/${pkgs.qt5.qtbase.qtQmlPrefix}";
    };
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };

  # -------------------------------------
  # home-manager
  # -------------------------------------

  home-manager.users.andrea = {
    nixpkgs.config.allowUnfree = true;
    home.file.".background-image".source = "/etc/nixos/background.png";
    gtk = {
      enable = true;
      font.name = "Sans 10";
      cursorTheme = {
        name = "Breeze_Snow";
        package = pkgs.breeze-gtk;
        #size = 24;
      };
      iconTheme = {
        name = "elementary-xfce";
        package = pkgs.elementary-xfce-icon-theme;
      };
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.adwaita-icon-theme;
      };
    };
    xsession.windowManager.i3 = {
      enable = true;
      config = let
        Mod           = "Mod1";
        Win           = "Mod4";
        terminal      = "alacritty";
        browser       = "google-chrome-stable";
        run           = "rofi -show drun -columns 2 -hide-scrollbar -show-icons -icon-theme elementary-xfce-dark -theme paper-float";
        filemanager   = "thunar";
        editor        = "code";
        audio         = "pavucontrol";
        screenshooter = "flameshot gui"; in {
          bars = [
            {
              colors = {
                background = "#000000CC";
                statusline = "#000000";
                separator  = "#0B0B0B";
              };
              fonts = { names = [ "DejaVuSansMono Nerd Font" ]; size = 9.0; };
              command = "i3bar --transparency";
              statusCommand = "i3status-rs ~/.config/i3status-rust/config-bar.toml";
            }
           ];
          workspaceOutputAssign = [
            { workspace = "1"; output = "HDMI-0"; }
            { workspace = "2"; output = "DP-2"; }
            { workspace = "3"; output = "DP-0"; }
          ];
          fonts = { names = [ "DejaVuSansMono Nerd Font" ]; size = 9.0; };
          focus.newWindow = "smart";
          workspaceAutoBackAndForth = true;
          #focus.wrapping = "workspace";
          startup = [
            { command = browser; }
            { command = editor;  }
            { command = "noisetorch -i"; }
            { command = "telegram-desktop"; }
          ];
          window = {
            titlebar = false;
            hideEdgeBorders = "both";
            border = 2;
          };
          floating = {
            modifier = Mod;
            border = 2;
            titlebar = false;
            criteria = [
              { title = "NixOS rebuild"; }
              { class = "Pavucontrol"; }
            ];
          };
          keybindings = {
            "${Mod}+1"             = "workspace 1";
            "${Mod}+2"             = "workspace 2";
            "${Mod}+3"             = "workspace 3";
            "${Mod}+4"             = "workspace 4";
            "${Mod}+5"             = "workspace 5";
            "${Mod}+6"             = "workspace 6";
            "${Mod}+7"             = "workspace 7";
            "${Mod}+8"             = "workspace 8";
            "${Mod}+9"             = "workspace 9";
            "${Mod}+a"             = "focus left";
            "${Mod}+b"             = "exec ${audio}";
            "${Mod}+c"             = "split v";
            "${Mod}+Control+a"     = "resize shrink width 10 px or 5 ppt";
            "${Mod}+Control+d"     = "resize grow width 10 px or 5 ppt";
            "${Mod}+Control+Down"  = "resize grow height 10 px or 5 ppt";
            "${Mod}+Control+Left"  = "resize shrink width 10 px or 5 ppt";
            "${Mod}+Control+Right" = "resize grow width 10 px or 5 ppt";
            "${Mod}+Control+s"     = "resize grow height 10 px or 5 ppt";
            "${Mod}+Control+space" = "focus Mode_toggle";
            "${Mod}+Control+Up"    = "resize shrink height 10 px or 5 ppt";
            "${Mod}+Control+w"     = "resize shrink height 10 px or 5 ppt";
            "${Mod}+d"             = "focus right";
            "${Mod}+e"             = "layout toggle split";
            "${Mod}+f"             = "fullscreen";
            "${Mod}+l"             = "focus child";
            "${Mod}+less"          = "exec ${run}";
            "${Mod}+p"             = "focus parent";
            "${Mod}+q"             = "kill";
            "${Mod}+r"             = "exec ${browser}";
            "${Mod}+Return"        = "exec ${terminal}";
            "${Mod}+s"             = "focus down";
            "${Mod}+Shift+0"       = "move container to workspace 10";
            "${Mod}+Shift+1"       = "move container to workspace 1";
            "${Mod}+Shift+2"       = "move container to workspace 2";
            "${Mod}+Shift+3"       = "move container to workspace 3";
            "${Mod}+Shift+4"       = "move container to workspace 4";
            "${Mod}+Shift+5"       = "move container to workspace 5";
            "${Mod}+Shift+6"       = "move container to workspace 6";
            "${Mod}+Shift+7"       = "move container to workspace 7";
            "${Mod}+Shift+8"       = "move container to workspace 8";
            "${Mod}+Shift+9"       = "move container to workspace 9";
            "${Mod}+Shift+a"       = "move left";
            "${Mod}+Shift+c"       = "reload; restart;";
            "${Mod}+Shift+d"       = "move right";
            "${Mod}+Shift+f"       = "exec ${filemanager}";
            "${Mod}+Shift+p"       = "border toggle";
            "${Mod}+Shift+s"       = "move down";
            "${Mod}+Shift+w"       = "move up";
            "${Mod}+space"         = "floating toggle";
            "${Mod}+t"             = "layout tabbed";
            "${Mod}+v"             = "split h";
            "${Mod}+w"             = "focus up";
            "${Mod}+x"             = "focus parent";
            "${Mod}+z"             = "exec ${terminal}";
            "$Win+Shift+s"         = "exec ${screenshooter}";
            "Print"                = "exec ${screenshooter}";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume 0 -10%";
            "XF86AudioMute"        = "exec pactl set-sink-mute 0 toggle";
            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume 0 +10%";
          };
      };
      extraConfig = ''
        popup_during_fullscreen smart
      '';
    };
    programs.vscode = {
      enable = true;
      userSettings = {
        "editor.fontFamily" = "'DejaVuSansMono Nerd Font'";
        "editor.fontSize" = 13.16;
        "editor.inlineSuggest.enabled" = true;
        "editor.letterSpacing" = -0.1;
        "editor.unicodeHighlight.ambiguousCharacters" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.sortOrder" = "type";
        "files.insertFinalNewline" = true;
        "files.restoreUndoStack" = true;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "idris.idris2Mode" = true;
        "idris.idrisPath" = "idris2";
        "security.workspace.trust.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "workbench.activityBar.visible" = false;
        "files.associations" = {
            "*.tikz" = "latex";
            "*.tikzstyles" = "latex";
        };
        "[dart]" = {
            "editor.formatOnSave" = true;
            "editor.formatOnType" = true;
            "editor.rulers" = [80];
            "editor.selectionHighlight" = false;
            "editor.suggest.snippetsPreventQuickSuggestions" = false;
            "editor.suggestSelection" = "first";
            "editor.tabCompletion" = "onlySnippets";
            "editor.wordBasedSuggestions" = false;
        };
        "latex-workshop.latex.autoBuild.run" = "onSave";
        "latex-workshop.latex.autoClean.run" = "onBuilt";
        "latex-workshop.latex.pdfWatch.delay" = 0;
        "latex-workshop.latex.recipe.default" = "lastUsed";
        "latex-workshop.latex.watch.delay" = 0;
        "latex-workshop.view.pdf.viewer" = "tab";
        "latex-workshop.latex.recipes" = [
            { "name" = "latexmk (xelatex)"; "tools" = [ "xelatexmk" ]; }
            { "name" = "latexmk";           "tools" = [ "latexmk"   ]; }
        ];
        "latex-workshop.latex.tools" = [
            {
                "name" = "xelatexmk";
                "command" = "latexmk";
                "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-xelatex" "-draftmode" "%DOC%" ];
                "env" = {};
            }
            {
                "name" = "latexmk";
                "command" = "latexmk";
                "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-pdf" "-outdir=%OUTDIR%" "-f" "-draftmode" "%DOC%" ];
                "env" = {};
            }
        ];
      };
      keybindings = [
        { "key" = "ctrl+a ctrl+q";     "command" = "agda-mode.auto";                                                "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+c";     "command" = "agda-mode.case";                                                "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+space"; "command" = "agda-mode.give";                                                "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+s";     "command" = "agda-mode.goal-type-context-and-inferred-type[Normalised]";     "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+f";     "command" = "agda-mode.goal-type-context-and-inferred-type[Simplified]";     "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+g";     "command" = "agda-mode.goal-type-context-and-inferred-type[Instantiated]";   "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+d";     "command" = "agda-mode.load";                                                "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+z";     "command" = "agda-mode.next-goal";                                           "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+w";     "command" = "agda-mode.previous-goal";                                       "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+r";     "command" = "agda-mode.refine";                                              "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+t";     "command" = "agda-mode.restart";                                             "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+e";     "command" = "agda-mode.compute-normal-form[DefaultCompute]";                 "when" = "editorTextFocus && !editorHasSelection"; }
        { "key" = "ctrl+a ctrl+v";     "command" = "agda-mode.show-constraints";                                    "when" = "editorTextFocus && !editorHasSelection"; }
      ];
      extensions = [
        pkgs.vscode-extensions.rust-lang.rust-analyzer
        pkgs.vscode-extensions.ms-vsliveshare.vsliveshare
        pkgs.vscode-extensions.jnoortheen.nix-ide
        pkgs.vscode-extensions.james-yu.latex-workshop
        pkgs.vscode-extensions.haskell.haskell
        pkgs.vscode-extensions.github.copilot
        pkgs.vscode-extensions.denoland.vscode-deno
        pkgs.vscode-extensions.dart-code.dart-code
        pkgs.vscode-extensions.bbenoist.nix
        #pkgs.vscode-extensions.vscodevim.vim
        #pkgs.vscode-extensions.ms-vsliveshare.vsliveshare-audio
        #pkgs.vscode-extensions.ms-vscode.wordcount
        #pkgs.vscode-extensions.ms-vscode-remote.remote-wsl
        #pkgs.vscode-extensions.meraymond.idris-vscode
        #pkgs.vscode-extensions.leanprover.lean4
        #pkgs.vscode-extensions.banacorn.agda-mode
      ];
    };
    services.flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
          uiColor = "#e0e0e0";
          showHelp = false;
          showSidePanelButton = false;
          autoCloseIdleDaemon = false;
        };
      };
    };
    programs.git = {
      enable = true;
      userName  = "iwilare";
      userEmail = "iwilare@gmail.com";
      extraConfig.init.defaultBranch = "main";
      extraConfig.pull.rebase = false;
    };
    programs.fish = {
      enable = true;
      functions = {
        fish_prompt.body = ''printf "λ %s%s%s> " (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)'';
      };
      shellAliases = {
        cat = "bat -p";
        ls  = "exa";
        l   = "exa --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type --all";
        la  = "exa --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type";
        t   = "exa --icons --tree -s=type --all";
        ta  = "exa --icons --tree -s=type";
        where = "ack -il";
      };
      shellInit = ''set fish_greeting'';
    };
    programs.alacritty = {
      enable = true;
      settings = {
        env = {
          WINIT_X11_SCALE_FACTOR = "1";
        };
        colors = {
          bright = {
            black   = "#555753";
            blue    = "#739fcf";
            cyan    = "#34e2e2";
            green   = "#8ae234";
            magenta = "#ad7fa8";
            red     = "#ef2929";
            white   = "#eeeeec";
            yellow  = "#fce94f";
          };
          normal = {
            black   = "#2e3436";
            blue    = "#3465a4";
            cyan    = "#06989a";
            green   = "#4e9a06";
            magenta = "#75507b";
            red     = "#cc0000";
            white   = "#d3d7cf";
            yellow  = "#c4a000";
          };
          primary = {
            background = "#000000";
            foreground = "#ffffff";
          };
        };
        cursor.blink_interval = 650;
        cursor.style = {
          shape = "beam";
          blinking = "always";
        };
        draw_bold_text_with_bright_colors = true;
        font.normal.family = "DejaVuSansMono Nerd Font";
        font.size = 10;
        selection.save_to_clipboard = true;
        window.opacity = 0.8;
        mouse_bindings = [
          {
            mouse = "Right";
            action = "PasteSelection";
          }
        ];
        key_bindings = [
          {
            key = "Return";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
          {
            key = "Z";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
        ];
      };
    };
    programs.i3status-rust = {
      enable = true;
      bars.bar = {
        icons = "awesome6";
        theme = "modern";
        blocks = [
          {
            block = "custom";
            on_click = "code /etc/nixos/configuration.nix";
            command = "echo ";
          }
          {
            block = "custom";
            on_click = "$TERMINAL -T 'NixOS rebuild' -x sudo nixos-rebuild switch";
            command = "echo ";
          }
          {
            block = "battery";
            interval = 10;
            format = "{percentage} {time} {power}";
          }
          {
            block = "disk_space";
            path = "/";
            alias = "/";
            info_type = "available";
            unit = "GB";
            interval = 60;
            warning = 20.0;
            alert = 10.0;
          }
          {
            block = "sound";
            on_click = "amixer set Master toggle";
            show_volume_when_muted = true;
            max_vol = 150;
          }
          {
            block = "time";
            interval = 1;
            format = "%F %a %T";
            locale = "ja_JP";
          }
        ];
      };
    };
    home.file.".icons/default/index.theme".text = ''
[Icon Theme]
Name=Default
Inherits=Breeze_Snow
    '';
    xdg.configFile."noisetorch/config.toml".text = ''
Threshold = 95
DisplayMonitorSources = false
EnableUpdates = true
FilterInput = true
FilterOutput = false
LastUsedInput = "alsa_input.usb-Generic_Blue_Microphones_LT_2103170103279D0305B1_111000-00.analog-stereo"
LastUsedOutput = ""
    '';
  };
}
