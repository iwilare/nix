{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-23.05.tar.gz}/nixos")
  ];
  system.stateVersion = "23.05";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";
  nixpkgs.config.allowUnfree = true;
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  environment.systemPackages = with pkgs; [
    (agda.withPackages
      [
        agdaPackages.standard-library
        agdaPackages.agda-categories
      ])
    dropbox
    spotify
    tdesktop

    discord
    google-chrome
    teamviewer

    pcmanfm
    xfce.xfce4-terminal

    rofi
    pavucontrol

    lxde.lxrandr
    arandr
    #autorandr

    #ghc rustup stack

    texlive.combined.scheme-full

    obsidian

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

    cinnamon.nemo
    #cinnamon.nemo-with-extensions
    #cinnamon.folder-color-switcher
    #cinnamon.nemo-fileroller
    #cinnamon.nemo-python
  ];

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc ];
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  fonts.fontconfig.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";
  networking.hostName = "iwilare";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  programs.nm-applet.enable = true;
  programs.ssh.startAgent = true;
  security.pam.services.andrea.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  environment.variables.TERMINAL = "alacritty";
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
  security.sudo.extraConfig = ''Defaults timestamp_timeout=7200'';
  services.autorandr.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.illum.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];
  services.printing.enable = true;
  services.teamviewer.enable = true;
  services.tumbler.enable = true;
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
    libinput.mouse.accelSpeed = "20";
    xkbOptions = "caps:ctrl_modifier,eurosign:e"; #caps:super
    windowManager.i3.enable = true;

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
  services.dbus.packages = with pkgs; [
    xfce.xfconf
  ];

  fonts.fonts = [
    pkgs.ipafont
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    (pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVuSansM Nerd Font"
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

  # ------------ programs ------------

  programs.fish.enable = true;
  programs.noisetorch = {
    enable = true;
  };
  #programs.thunar = {
  #  enable = true;
  #  plugins = with pkgs.xfce; [
  #    thunar-archive-plugin
  #    thunar-volman
  #  ];
  #};

  # ------------ services ------------

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

  # ------------ home-manager ------------

  home-manager.users.andrea = {
    home.stateVersion = "23.05";
    nix.settings.extra-experimental-features = "flakes nix-command";
    home.file.".background-image".source = (pkgs.fetchurl {
      url = "https://github.com/iwilare/backgrounds/raw/main/iss.png";
      sha256 = "/r/R1tTzvbivSepmYa2nA4Otq3CSuvqjr3J4sY0Sqxg=";
    });
    gtk = {
      enable = true;
      font.name = "Sans 10";
      cursorTheme = { name = "Breeze_Snow";     package = pkgs.breeze-gtk;                 }; #size = 24; };
      iconTheme   = { name = "elementary-xfce"; package = pkgs.elementary-xfce-icon-theme; };
      theme       = { name = "Adwaita-dark";    package = pkgs.gnome.adwaita-icon-theme;   };
    };
    xsession.windowManager.i3 = {
      enable = true;
      config = let
        Mod           = "Mod1";
        Win           = "Mod4";
        terminal      = "alacritty";
        browser       = "google-chrome-stable";
        run           = "rofi -show drun -columns 2 -hide-scrollbar -show-icons -icon-theme elementary-xfce-dark -theme paper-float";
        filemanager   = "nemo";
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
              fonts = { names = [ "DejaVuSansM Nerd Font" ]; size = 9.0; };
              command = "i3bar --transparency";
              statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bar.toml";
            }
          ];
          workspaceOutputAssign = [
            { workspace = "1"; output = "HDMI-0"; }
            { workspace = "2"; output = "DP-2"; }
            { workspace = "3"; output = "DP-0"; }
          ];
          fonts = { names = [ "DejaVuSansM Nerd Font" ]; size = 9.0; };
          focus.newWindow = "smart";
          #workspaceAutoBackAndForth = true;
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
            "${Mod}+v"             = "split h";
            "${Mod}+c"             = "split v";
            "${Mod}+z"             = "exec ${terminal}";
            "${Mod}+r"             = "exec ${browser}";
            "${Mod}+b"             = "exec ${audio}";
            "${Mod}+x"             = "focus parent";
            "${Mod}+w"             = "focus up";
            "${Mod}+s"             = "focus down";
            "${Mod}+p"             = "focus parent";
            "${Mod}+l"             = "focus child";
            "${Mod}+d"             = "focus right";
            "${Mod}+a"             = "focus left";
            "${Mod}+e"             = "layout toggle split";
            "${Mod}+t"             = "layout tabbed";
            "${Mod}+f"             = "fullscreen";
            "${Mod}+q"             = "kill";
            "${Mod}+Return"        = "exec ${terminal}";
            "${Mod}+less"          = "exec ${run}";
            "${Mod}+space"         = "floating toggle";
            "${Mod}+Control+space" = "focus Mode_toggle";
            "${Mod}+Control+a"     = "resize shrink width 10 px or 5 ppt";
            "${Mod}+Control+d"     = "resize grow width 10 px or 5 ppt";
            "${Mod}+Control+Down"  = "resize grow height 10 px or 5 ppt";
            "${Mod}+Control+Left"  = "resize shrink width 10 px or 5 ppt";
            "${Mod}+Control+Right" = "resize grow width 10 px or 5 ppt";
            "${Mod}+Control+s"     = "resize grow height 10 px or 5 ppt";
            "${Mod}+Control+Up"    = "resize shrink height 10 px or 5 ppt";
            "${Mod}+Control+w"     = "resize shrink height 10 px or 5 ppt";
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
            "${Mod}+Shift+d"       = "move right";
            "${Mod}+Shift+s"       = "move down";
            "${Mod}+Shift+w"       = "move up";
            "${Mod}+Shift+c"       = "reload; restart;";
            "${Mod}+Shift+p"       = "border toggle";
            "${Win}+f"             = "exec ${filemanager}";
            "${Win}+s"             = "exec ${screenshooter}";
            "${Win}+c"             = "exec ${browser}";
            "${Win}+b"             = "exec ${audio}";
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
    programs.i3status-rust = {
      enable = true;
      bars.bar = {
        icons = "awesome6";
        theme = "modern"; # https://github.com/greshake/i3status-rust/blob/master/files/themes/modern.toml
        blocks =
        let transparent = { idle_bg = "#333F46A0"; };
            button = { icon, cmd }: {
              block = "custom";
              command = "";
              format = icon;
              click = [{ button = "left"; cmd = cmd; }];
            };
            separation = { block = "custom"; command = "echo ' '"; theme_overrides = { idle_bg = "#50505030"; }; }; in [
          (button { icon = "   "; cmd =  "code -n /etc/nixos/configuration.nix"; })
          (button { icon = "  " ; cmd =  "alacritty --hold -t 'NixOS rebuild' -e sudo nixos-rebuild switch"; })
          (button { icon = "  " ; cmd =  "lxrandr"; })
          (button { icon = "   "; cmd =  "pavucontrol"; })
          # {
          #   block = "menu";
          #   text = " ⏻ ";
          #   items = [{ display = "[Are you sure?]"; cmd = "google-chrome-stable"; }];
          # }
          separation
          { block = "battery"; format = " $icon $percentage $time $power "; missing_format = ""; }
          { block = "net"; format = " $icon  $ssid"; }
          # {
          #   block = "net";
          #   format = " ^icon_net_down $speed_down.eng(w:4,p:K) ^icon_net_up $speed_up.eng(w:4,p:K) ";
          #   theme_overrides = { idle_bg = "#505050e0"; idle_fg = "#e0e0e0ff"; };
          # }
          # {
          #   block = "cpu";
          #   format = " $utilization @$frequency ";
          #   merge_with_next = true;
          # }
          { block = "memory"; format = " $icon $mem_avail"; }
          { block = "disk_space"; }
          separation
          {
            block = "sound";
            max_vol = 150;
            show_volume_when_muted = true;
            headphones_indicator = true;
            theme_overrides = { idle_bg = "#449CDB"; idle_fg = "#1D1F21"; };
            click = [{ button = "left"; cmd = "pavucontrol"; }];
          }
          {
            block = "time";
            interval = 1;
            format.full = " $icon $timestamp.datetime(f:'%F %a %T', l:ja_JP) ";
          }
        ];
      };
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
        font.normal.family = "DejaVuSansM Nerd Font";
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
    programs.ssh = {
      enable = true;
      extraConfig = "AddKeysToAgent yes";
    };
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
        get.body = "git clone git@github.com:$argv[1]";
      };
      shellAliases = {
        cat = "bat -p";
        ls  = "exa";
        la  = "exa --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type --all";
        l   = "exa --git --icons --time-style=long-iso --long --no-user --no-permissions -s=type";
        t   = "exa --icons --tree -s=type --all";
        ta  = "exa --icons --tree -s=type";
        w   = "ack -il";
        gl  = "git log --pretty=format:'%C(auto) %h %ci [%an] %s%d' --graph";
        gs  = "git commit -m \"`date '+%Y-%m-%d %H:%M:%S'`\" && git push";
      };
      shellInit = ''set fish_greeting'';
    };
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.overrideAttrs (oldAttrs: rec { version = "stable"; });
      userSettings = {
        "editor.bracketPairColorization.enabled" = true;
        "editor.fontFamily" = "'DejaVuSansM Nerd Font'";
        "editor.fontSize" = 13.16;
        "editor.glyphMargin" = false;
        "editor.guides.bracketPairs" = true;
        "editor.hover.delay" = 250;
        "editor.inlineSuggest.enabled" = true;
        "editor.insertSpaces" = true;
        "editor.letterSpacing" = -0.3;
        "editor.linkedEditing" = true;
        "editor.minimap.maxColumn" = 60;
        "editor.minimap.scale" = 2;
        "editor.smoothScrolling" = true;
        "editor.stickyScroll.enabled" = true;
        "editor.suggest.localityBonus" = true;
        "editor.suggest.preview" = true;
        "editor.tabSize" = 2;
        "explorer.compactFolders" = false;
        "explorer.confirmDragAndDrop" = false;
        "explorer.incrementalNaming" = "smart";
        "explorer.sortOrderLexicographicOptions" = "upper";
        "files.eol" = "\n";
        "files.insertFinalNewline" = true;
        "files.restoreUndoStack" = true;
        "files.simpleDialog.enable" = true;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "liveshare.notebooks.allowGuestExecuteCells" = true;
        "search.smartCase" = true;
        "search.sortOrder" = "fileNames";
        "security.workspace.trust.enabled" = false;
        "security.workspace.trust.untrustedFiles" = "open";
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.cursorStyle" = "line";
        "terminal.integrated.enableMultiLinePasteWarning" = false;
        "terminal.integrated.rightClickBehavior" = "copyPaste";
        "terminal.integrated.scrollback" = 10000;
        "terminal.integrated.smoothScrolling" = true;
        "update.mode" = "none";
        "window.menuBarVisibility" = "hidden";
        "workbench.editor.splitSizing" = "split";
        "workbench.editor.tabSizing" = "shrink";
        "workbench.list.smoothScrolling" = true;
        "workbench.startupEditor" = "none";
        "workbench.tree.indent" = 16;
        "workbench.tree.renderIndentGuides" = "always";
        # Idris
        "idris.idris2Mode" = true;
        "idris.idrisPath" = "idris2";
        # Agda
        "agdaMode.view.panelMountPosition" = "right";
        "[agda]" = {
          "editor.unicodeHighlight.ambiguousCharacters" = false;
        };
        "[dart]" = {
          "editor.formatOnSave" = true;
          "editor.formatOnType" = true;
          "editor.rulers" = [
            80
          ];
          "editor.selectionHighlight" = false;
          "editor.suggest.snippetsPreventQuickSuggestions" = false;
          "editor.suggestSelection" = "first";
          "editor.tabCompletion" = "onlySnippets";
          "editor.wordBasedSuggestions" = false;
        };
        # LaTeX
        "files.associations" = {
          "*.tikz" = "latex";
          "*.tikzstyles" = "latex";
        };
        "latex-workshop.latex.autoBuild.run" = "onSave";
        "latex-workshop.latex.autoClean.run" = "onBuilt";
        "latex-workshop.latex.recipe.default" = "lastUsed";
        "latex-workshop.view.pdf.viewer" = "tab";
        "latex-workshop.latex.recipes" = [
          { "name" = "latexmk (xelatex)"; "tools" = [ "xelatexmk" ]; }
          { "name" = "latexmk";           "tools" = [ "latexmk"   ]; }
          { "name" = "pdflatex";          "tools" = [ "pdflatex"  ]; }
        ];
        "latex-workshop.latex.tools" = [
          { "command" = "latexmk";  "env" = {}; "name" = "xelatexmk"; "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-xelatex"  "-draftmode" "%DOC%" ]; }
          { "command" = "latexmk";  "env" = {}; "name" = "latexmk";   "args" = [ "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-outdir=%OUTDIR%" "-pdf" "-f" "-draftmode" "%DOC%" ]; }
          { "command" = "pdflatex"; "env" = {}; "name" = "pdflatex";  "args" = [ "-synctex=1" "-outdir=%OUTDIR%" "-draftmode" "%DOC%" ]; }
        ];
        "workbench.editor.autoLockGroups" = {
          "latex-workshop-pdf-hook" = true;
          "mainThreadWebview-markdown.preview" = true;
        };
      };
      keybindings = [

        # Movement

        { "command" = "cursorDown";                "key" = "ctrl+k";                 }
        { "command" = "cursorDownSelect";          "key" = "ctrl+shift+k";           }
        { "command" = "cursorLeft";                "key" = "ctrl+alt+j";             }
        { "command" = "cursorLeftSelect";          "key" = "ctrl+shift+j";           }
        { "command" = "cursorRight";               "key" = "ctrl+alt+l";             }
        { "command" = "cursorRightSelect";         "key" = "ctrl+shift+l";           }
        { "command" = "cursorUp";                  "key" = "ctrl+i";                 }
        { "command" = "cursorUpSelect";            "key" = "ctrl+shift+i";           }

        { "command" = "cursorWordPartLeft";        "key" = "ctrl+j";                 }
        { "command" = "cursorWordPartLeftSelect";  "key" = "ctrl+alt+shift+j";       }
        { "command" = "cursorWordPartRight";       "key" = "ctrl+l";                 }
        { "command" = "cursorWordPartRightSelect"; "key" = "ctrl+alt+shift+l";       }

        { "command" = "deleteLeft";                "key" = "ctrl+alt+h";             }
        { "command" = "deleteRight";               "key" = "ctrl+alt+[semicolon]";   }
        { "command" = "deleteWordLeft";            "key" = "ctrl+h";                 }
        { "command" = "deleteWordPartLeft";        "key" = "ctrl+shift+h";           }
        { "command" = "deleteWordPartRight";       "key" = "ctrl+shift+[semicolon]"; }
        { "command" = "deleteWordRight";           "key" = "ctrl+[semicolon]";       }

        { "command" = "cursorHome";                "key" = "ctrl+q";                 }
        { "command" = "cursorHomeSelect";          "key" = "ctrl+alt+q";             }
        { "command" = "cursorLineEnd";             "key" = "ctrl+e";                 }
        { "command" = "cursorLineEndSelect";       "key" = "ctrl+alt+e";             }

        # Selection

        { "command" = "expandLineSelection";                       "key" = "ctrl+m";                                           }
        { "command" = "editor.action.smartSelect.expand";          "key" = "ctrl+r";                                           }
        { "command" = "editor.action.smartSelect.shrink";          "key" = "ctrl+shift+r";      "when" = "editorHasSelection"; }
        { "command" = "editor.action.moveLinesUpAction";           "key" = "ctrl+alt+i";        "when" = "editorHasSelection"; }
        { "command" = "editor.action.moveLinesDownAction";         "key" = "ctrl+alt+k";        "when" = "editorHasSelection"; }
        { "command" = "cancelSelection";                           "key" = "ctrl+w";            "when" = "editorHasSelection"; }
        { "command" = "editor.action.selectHighlights";            "key" = "ctrl+space ctrl+d";                                }
        { "command" = "editor.action.selectAll";                   "key" = "ctrl+space ctrl+a";                                }

        # Clipboard and undoing

        { "command" = "editor.action.clipboardCutAction";          "key" = "ctrl+x";            "when" = "editorHasSelection"; }
        { "command" = "editor.action.clipboardCopyAction";         "key" = "ctrl+c";            "when" = "editorHasSelection"; }
        { "command" = "editor.action.clipboardPasteAction";        "key" = "ctrl+v";                                           }
        { "command" = "redo";                                      "key" = "ctrl+alt+z";                                       }
        { "command" = "undo";                                      "key" = "ctrl+z";                                           }
        { "command" = "cursorRedo";                                "key" = "ctrl+space ctrl+u";                                }

        # Multi cursor

        { "command" = "yo1dog.cursor-align.alignCursors";          "key" = "ctrl+t";                                                }
        { "command" = "editor.action.insertCursorAbove";           "key" = "ctrl+alt+i";            "when" = "!editorHasSelection"; }
        { "command" = "editor.action.insertCursorBelow";           "key" = "ctrl+alt+k";            "when" = "!editorHasSelection"; }
        { "command" = "editor.action.insertLineBefore";            "key" = "ctrl+alt+enter";                                        }
        { "command" = "editor.action.insertLineAfter";             "key" = "ctrl+enter";                                            }
        { "command" = "editor.action.copyLinesDownAction";         "key" = "ctrl+alt+c";                                            }
        { "command" = "editor.action.selectHighlights";            "key" = "ctrl+shift+d";                                          }
        { "command" = "editor.action.startFindReplaceAction";      "key" = "ctrl+alt+f";                                            }
        { "command" = "editor.action.joinLines";                   "key" = "ctrl+g";                "when" = "!editorHasSelection"; }
        { "command" = "editor.action.commentLine";                 "key" = "ctrl+b";                                                }
        { "command" = "editor.action.triggerSuggest";              "key" = "ctrl+y";                "when" = "!editorHasSelection"; }
        { "command" = "removeSecondaryCursors";                    "key" = "ctrl+;";                "when" = "multiCursorModifier"; }
        { "command" = "editor.action.startFindReplaceAction";      "key" = "ctrl+space ctrl+f";     "when" = "!editorHasSelection"; }
        { "command" = "editor.action.triggerSuggest";              "key" = "ctrl+space ctrl+space"; "when" = "!editorHasSelection"; }

        { "command" = "removeSecondaryCursors";                    "key" = "ctrl+;";                "when" = "multiCursorModifier"; }

        # { "command" = "editor.action.deleteLines";                 "key" = "ctrl+n";                                              }
        # { "command" = "editor.action.indentLines";                 "key" = "tab";                "when" = "editorHasSelection";   }
        # { "command" = "editor.action.outdentLines";                "key" = "shift+tab";          "when" = "editorHasSelection";   }

        # Windows

        { "command" = "workbench.action.closeActiveEditor";        "key" = "ctrl+space ctrl+w";     "when" = "!editorHasSelection"; }
        { "command" = "workbench.action.closeActiveEditor";        "key" = "ctrl+w";                "when" = "multiCursorModifier"; }
        { "command" = "workbench.action.files.newUntitledFile";    "key" = "ctrl+space ctrl+s";     "when" = "!editorHasSelection"; }
        { "command" = "workbench.action.files.openFile";           "key" = "ctrl+o";                                                }
        { "command" = "workbench.action.files.openFileFolder";     "key" = "ctrl+space ctrl+o";                                     }
        { "command" = "workbench.action.previousEditor";           "key" = "ctrl+space ctrl+1";                                     }
        { "command" = "workbench.action.nextEditor";               "key" = "ctrl+space ctrl+2";                                     }
        { "command" = "workbench.action.openEditorAtIndex1";       "key" = "ctrl+1";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex2";       "key" = "ctrl+2";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex3";       "key" = "ctrl+3";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex4";       "key" = "ctrl+4";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex5";       "key" = "ctrl+5";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex6";       "key" = "ctrl+6";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex7";       "key" = "ctrl+7";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex8";       "key" = "ctrl+8";                "when" = "";                    }
        { "command" = "workbench.action.openEditorAtIndex9";       "key" = "ctrl+9";                "when" = "";                    }
        { "command" = "workbench.action.quickOpen";                "key" = "ctrl+p";                                                }
        { "command" = "workbench.action.togglePanel";              "key" = "ctrl+space ctrl+q";     "when" = "!editorHasSelection"; }
        { "command" = "workbench.action.toggleSidebarVisibility";  "key" = "ctrl+space ctrl+e";     "when" = "!editorHasSelection"; }
        { "command" = "workbench.files.action.focusFilesExplorer"; "key" = "ctrl+space ctrl+d";     "when" = "!editorHasSelection"; }

        # Menus

        { "command" = "selectNextSuggestion"; "key" = "ctrl+k"; "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"; }
        { "command" = "selectPrevSuggestion"; "key" = "ctrl+i"; "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"; }

        # Agda mode

        { "command" = "agda-mode.auto";                                              "key" = "ctrl+a ctrl+q";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.case";                                              "key" = "ctrl+a ctrl+c";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.compile";                                           "key" = "ctrl+a ctrl+-";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.compute-normal-form[DefaultCompute]";               "key" = "ctrl+a ctrl+e";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.give";                                              "key" = "ctrl+a ctrl+space"; "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.goal-type-context-and-inferred-type[Instantiated]"; "key" = "ctrl+a ctrl+g";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.goal-type-context-and-inferred-type[Normalised]";   "key" = "ctrl+a ctrl+s";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.goal-type-context-and-inferred-type[Simplified]";   "key" = "ctrl+a ctrl+f";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.load";                                              "key" = "ctrl+a ctrl+d";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.lookup-symbol";                                     "key" = "ctrl+a ctrl+l";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.next-goal";                                         "key" = "ctrl+a ctrl+z";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.previous-goal";                                     "key" = "ctrl+a ctrl+w";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.refine";                                            "key" = "ctrl+a ctrl+r";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.restart";                                           "key" = "ctrl+a ctrl+p";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.restart";                                           "key" = "ctrl+a ctrl+t";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.show-constraints";                                  "key" = "ctrl+a ctrl+v";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.switch-agda-version";                               "key" = "ctrl+a ctrl+b";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.toggle-display-of-implicit-arguments";              "key" = "ctrl+a ctrl+m";     "when" = "editorLangId == 'agda'"; }
        { "command" = "agda-mode.toggle-display-of-irrelevant-arguments";            "key" = "ctrl+a ctrl+n";     "when" = "editorLangId == 'agda'"; }
      ];
      extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
        ms-vsliveshare.vsliveshare
        justusadam.language-haskell
        jnoortheen.nix-ide
        james-yu.latex-workshop
        haskell.haskell
        github.copilot
        denoland.vscode-deno
        dart-code.dart-code
        bbenoist.nix
        eamodio.gitlens
        adpyke.codesnap
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { name = "cursor-align"; publisher = "yo1dog";           version = "1.1.0";  sha256 = "LgcMwNundAUcsRLvr+yw0+REgv7ZS+HLh3aLH2mgw00="; }
        { name = "idris-vscode"; publisher = "meraymond";        version = "0.0.14"; sha256 = "QAzjm+8Z+4TDbM5amh3UEkSmp0n8ZlRHYpUGAewIVXk="; }
        { name = "wordcount";    publisher = "ms-vscode";        version = "0.1.0";  sha256 = "Qb4KU3K0NsU7U2GWZscA6WAk406RbnAOpIIvvII4mpg="; }
        { name = "agda-mode";    publisher = "banacorn";         version = "0.3.11"; sha256 = "jnH3oNqvkO/+Oi+8MM1RqooPFrQZMDWLSEnrVLnc5VI="; }
        { name = "remote-wsl";   publisher = "ms-vscode-remote"; version = "0.79.2"; sha256 = "s9hJKgfg4g1Nf740bnmee/QNa0nq9dvwbtHvaQUBjZc="; }
      ];
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
