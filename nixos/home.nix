{ config, pkgs, iwi-consolas, iwi-dejavu, system, ... }: {

  programs.vscode.enable = true;
  programs.vscode.package = pkgs.vscode.overrideAttrs (oldAttrs: rec { version = "stable"; });

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
            fonts = { names = [ iwi-dejavu.name ]; size = 9.0; };
            command = "i3bar --transparency";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bar.toml";
          }
        ];
        workspaceOutputAssign = [
          { workspace = "1"; output = "HDMI-0"; }
          { workspace = "2"; output = "DP-2"; }
          { workspace = "3"; output = "DP-0"; }
        ];
        fonts = { names = [ iwi-dejavu.name ]; size = 9.0; };
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
          "XF86AudioMute"        = "exec ${pkgs.alsa-utils}/bin/amixer -qM set Master toggle";
          "XF86AudioLowerVolume" = "exec ${pkgs.alsa-utils}/bin/amixer -qM set Master 5%- unmute";
          "XF86AudioRaiseVolume" = "exec ${pkgs.alsa-utils}/bin/amixer -qM set Master 5%+ unmute";
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
        { block = "battery"; format = " $icon  $percentage $time $power "; missing_format = ""; }
        { block = "net"; format = " $icon  {$ssid|$ip}"; }
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
          natural_mapping = true;
          step_width = 5;
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
      font.normal.family = iwi-dejavu.name;
      font.size = 10;
      cursor.blink_interval = 650;
      cursor.style.shape = "beam";
      cursor.style.blinking = "always";
      #color.draw_bold_text_with_bright_colors = true;
      selection.save_to_clipboard = true;
      window.opacity = 0.8;
      mouse.bindings = [
        {
          mouse = "Right";
          action = "PasteSelection";
        }
      ];
      keyboard.bindings = [
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

  # Environment

  gtk = {
    enable = true;
    font.name = "Sans 10";
    cursorTheme = { name = "Breeze_Snow";     package = pkgs.breeze-gtk;                 }; #size = 24; };
    iconTheme   = { name = "elementary-xfce"; package = pkgs.elementary-xfce-icon-theme; };
    theme       = { name = "Adwaita-dark";    package = pkgs.adwaita-icon-theme;         };
  };
  home.file.".background-image".source = (pkgs.fetchurl {
    url = "https://github.com/iwilare/backgrounds/raw/main/iss.png";
    sha256 = "/r/R1tTzvbivSepmYa2nA4Otq3CSuvqjr3J4sY0Sqxg=";
  });
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
}
