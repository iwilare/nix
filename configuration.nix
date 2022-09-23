{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-22.05.tar.gz}/nixos")
  ];

  nixpkgs.config.allowUnfree = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  networking.hostName = "iwilare";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  programs.nm-applet.enable = true;
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  hardware.pulseaudio.enable = true;
  sound.mediaKeys.enable = true;
  sound.mediaKeys.volumeStep = "5%";
  programs.dconf.enable = true; # https://www.reddit.com/r/NixOS/comments/b255k5/home_manager_cannot_set_gnome_themes/
  time.hardwareClockInLocalTime = true;
  services.printing.enable = true;
  services.illum.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.drivers = [ pkgs.gutenprint ];

  services.gnome.gnome-keyring.enable = true;
  # security.pam.services.andrea.enableGnomeKeyring = true;
  #networking.interfaces.wlp2s0.useDHCP = false;

  #set $composite     picom -f -D 5 -cz -o 1.0 -r 10 -e 0 --backend glx --vsync
  services.picom = {
    enable = true;
    fade = true;
    fadeDelta = 5;
    shadow = true;
    backend = "glx";
    vSync = true;
    shadowOpacity = 1.0;
    settings = {
      shadow-radius = 10;
      frame-opacity = 0;
    };
  };
  
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  services.xserver.autoRepeatDelay = 325;
  services.xserver.autoRepeatInterval = 30;
  services.xserver.enable = true;
  services.xserver.layout = "it";
  services.xserver.xkbOptions = "caps:ctrl_modifier;eurosign:e";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "andrea";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.desktopManager.wallpaper.mode = "fill";
  services.xserver.libinput.enable = true;
  services.xserver.libinput.mouse.accelSpeed = "30";
  users.users.root.shell = pkgs.fish;
  users.users.andrea = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
  environment.variables.TERMINAL = "xfce4-terminal";
  fonts.fonts = [
    pkgs.dejavu_fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.fira-code
    #(pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
  services.xserver.dpi = 96;
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "Noto Sans"
      "DejaVu Sans"
      "Noto Sans CJK"
      "IPAPGothic"
    ];
    serif = [
      "Noto Serif"
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };
  system.stateVersion = "20.03";
  environment.systemPackages = with pkgs; [
    (agda.withPackages
       [ 
         agdaPackages.standard-library
         #agdaPackages.agda-categories
         (agdaPackages.mkDerivation {
           version="1.7.1";
           meta.broken = false;
           pname = "agda-categories";
           src = /home/andrea/agda-categories;
           buildInputs = [
             agdaPackages.standard-library
           ];
           buildPhase = '''';
         })
       ])
    texlive.combined.scheme-full
    /*ghc
    rustup
    stack
    emacs
    vim*/
    dropbox-cli
    tdesktop
    vscode
    discord
    google-chrome
    fish
    rofi
    pcmanfm
    xfce.xfce4-terminal
    xfce.thunar
    flameshot
    zip
    pavucontrol
    unzip
    tree
    neofetch
    ncdu
    git
  ];

  environment.pathsToLink = [ "/share/agda" ];

  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };
  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
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
/*
  services.xserver.extraConfig = ''
    Section "ServerLayout"
        Identifier     "Layout0"
        Screen      0  "Screen0" 0 0
        InputDevice    "Keyboard0" "CoreKeyboard"
        InputDevice    "Mouse0" "CorePointer"
        Option         "Xinerama" "0"
    EndSection

    Section "Files"
    EndSection

    Section "InputDevice"
        # generated from default
        Identifier     "Mouse0"
        Driver         "mouse"
        Option         "Protocol" "auto"
        Option         "Device" "/dev/input/mice"
        Option         "Emulate3Buttons" "no"
        Option         "ZAxisMapping" "4 5"
    EndSection

    Section "InputDevice"
        # generated from default
        Identifier     "Keyboard0"
        Driver         "kbd"
    EndSection

    Section "Monitor"
        # HorizSync source: edid, VertRefresh source: edid
        Identifier     "Monitor0"
        VendorName     "Unknown"
        ModelName      "AUS VG279"
        HorizSync       162.0 - 162.0
        VertRefresh     40.0 - 144.0
        Option         "DPMS"
    EndSection

    Section "Device"
        Identifier     "Device0"
        Driver         "nvidia"
        VendorName     "NVIDIA Corporation"
        BoardName      "NVIDIA GeForce RTX 3060"
    EndSection

    Section "Screen"
        Identifier     "Screen0"
        Device         "Device0"
        Monitor        "Monitor0"
        DefaultDepth    24
        Option         "Stereo" "0"
        Option         "nvidiaXineramaInfoOrder" "DFP-0"
        Option         "metamodes" "DP-2: 1920x1080_144 +0+0 {rotation=left}, HDMI-0: 2560x1440_144 +1080+240, DP-0: 1920x1080_144 +3640+420"
        Option         "SLI" "Off"
        Option         "MultiGPU" "Off"
        Option         "BaseMosaic" "off"
        SubSection     "Display"
            Depth       24
        EndSubSection
    EndSection
  '';


        Option "RightOf" "HDMI-1"
        Option "RightOf" "DP-2"
*/
/*
  services.xserver.monitorSection = ''
    Section "Monitor"
        # HorizSync source: edid, VertRefresh source: edid
        Identifier     "Monitor0"
        VendorName     "Unknown"
        ModelName      "AUS VG279"
        HorizSync       162.0 - 162.0
        VertRefresh     40.0 - 144.0
        Option         "DPMS"
    EndSection
  '';
  services.xserver.deviceSection = ''
      Identifier     "Device0"
      Driver         "nvidia"
      VendorName     "NVIDIA Corporation"
      BoardName      "NVIDIA GeForce RTX 3060"
  '';
  */
  services.xserver.screenSection = ''
      Option         "metamodes" "DP-2: 1920x1080_144 +0+0 {rotation=left}, HDMI-0: 2560x1440_144 +1080+240, DP-0: 1920x1080_144 +3640+420"
  '';

  # -------------------------------------
  # home-manager
  # -------------------------------------

  home-manager.users.andrea = {
    nixpkgs.config.allowUnfree = true;
    #home.file.".background-image".source = "background.png";
    gtk = {
      enable = true;
      font.name = "Sans 10";
      cursorTheme = {
        name = "Breeze_Snow";
        package = pkgs.breeze-gtk;
        size = 24;
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
    programs.vscode = {
      enable = true;
      extensions = [
        pkgs.vscode-extensions.haskell.haskell
        pkgs.vscode-extensions.bbenoist.nix
        pkgs.vscode-extensions.james-yu.latex-workshop
        #pkgs.vscode-extensions.banacorn.agda-mode
      ];
    };
    programs.git = {
      enable = true;
      userName  = "iwilare";
      userEmail = "iwilare@gmail.com";
    };
    programs.fish = {
      enable = true;
      functions = {
        l.body = "ls -CSGLho --color --group-directories-first --si $argv | sed 's/andrea//'";
        fish_prompt.body = ''printf "λ %s%s%s> " (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)'';
      };
      shellInit = ''set fish_greeting'';
    };
    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.8;
        font.normal.family = "Monospace";
        size = 10.0;
        color = {
          normal = {
            black  = "#000000"; 
            red    = "#4e9a06"; 
            green  = "#3465a4"; 
            yellow = "#06989a"; 
            blue = "#555753"; 
            magenta = "#8ae234"; 
            cyan = "#739fcf"; 
            white = "#34e2e2"; 
          };
          bright = {
            black = "#cc0000";
            red = "#c4a000";
            green = "#75507b";
            yellow = "#d3d7cf";
            blue = "#ef2929";
            magenta = "#fce94f";
            cyan = "#ad7fa8";
            white = "#eeeeec";
          };
        };
        cursor.style = "beam";
        cursor.blinking = "on";
        #cursor.blink_interval = "750";
      };
    };
    xdg.configFile."xfce4/terminal/terminalrc".text = ''
[Configuration]
BackgroundDarkness=0.800000
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
FontName=Monospace 10
MiscConfirmClose=FALSE
MiscCopyOnSelect=TRUE
MiscCursorBlinks=TRUE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_IBEAM
MiscHighlightUrls=TRUE
MiscMenubarDefault=FALSE
MiscRewrapOnResize=TRUE
MiscShowUnsafePasteDialog=FALSE
MiscToolbarDefault=FALSE
ScrollingBar=TERMINAL_SCROLLBAR_NONE
ScrollingOnOutput=FALSE
ScrollingUnlimited=TRUE
MiscRightClickAction=TERMINAL_RIGHT_CLICK_ACTION_PASTE_CLIPBOARD
ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#739fcf;#ad7fa8;#34e2e2;#eeeeec
    '';
    xdg.configFile."i3/config".text = ''
set $terminal      xfce4-terminal
set $browser       google-chrome-stable
set $run           rofi -show drun -columns 2 -hide-scrollbar -show-icons -icon-theme elementary-xfce-dark -theme paper-float
set $filemanager   thunar
set $editor        code
set $audio         pavucontrol
set $screenshooter flameshot gui

exec $browser
exec code

bar {
  colors {
    background #0B0B0B22
    statusline #000000
    separator  #0B0B0B
  }
	font pango:DejaVu Sans Mono 9
  status_command i3status-rs ~/.config/i3status-rust/config-bar.toml
}
font pango:DejaVu Sans Mono 9

set $WS1 "1"
set $WS2 "2"
set $WS3 "3"
set $WS4 "4"
set $WS5 "5"
set $WS6 "6"
set $WS7 "7"
set $WS8 "8"
set $WS9 "9"
set $WS10 "10"

#set $Win Mod4
#set $Alt Mod1
set $Mod Mod1
floating_Modifier Mod1
hide_edge_borders both
new_window pixel 2
new_float pixel 2

workspace 1 output DP-2
workspace 2 output HDMI-0
workspace 3 output DP-0

default_orientation horizontal
popup_during_fullscreen smart

bindsym $Mod+r       exec $browser
bindsym $Mod+z       exec $terminal
bindsym $Mod+Return  exec $terminal
bindsym $Mod+Shift+f exec $filemanager
bindsym $Mod+less    exec $run
bindsym $Mod+b       exec $audio
bindsym Print        exec $screenshooter

bindsym $Mod+q kill
bindsym $Mod+Shift+p border toggle
bindsym $Mod+Shift+c reload; restart;

bindsym $Mod+v split h
bindsym $Mod+c split v
bindsym $Mod+x focus parent
bindsym $Mod+f fullscreen
bindsym $Mod+e layout toggle split
bindsym $Mod+t layout tabbed

bindsym $Mod+p focus parent
bindsym $Mod+l focus child
bindsym $Mod+space floating toggle
bindsym $Mod+Control+space focus Mode_toggle

bindsym $Mod+a     focus left
bindsym $Mod+s     focus down
bindsym $Mod+w     focus up
bindsym $Mod+d     focus right

bindsym $Mod+Shift+a     move left
bindsym $Mod+Shift+s     move down
bindsym $Mod+Shift+w     move up
bindsym $Mod+Shift+d     move right

bindsym $Mod+1 workspace $WS1
bindsym $Mod+2 workspace $WS2
bindsym $Mod+3 workspace $WS3
bindsym $Mod+4 workspace $WS4
bindsym $Mod+5 workspace $WS5
bindsym $Mod+6 workspace $WS6
bindsym $Mod+7 workspace $WS7
bindsym $Mod+8 workspace $WS8
bindsym $Mod+9 workspace $WS9
bindsym $Mod+0 workspace $WS10

bindsym $Mod+Shift+1 move container to workspace $WS1
bindsym $Mod+Shift+2 move container to workspace $WS2
bindsym $Mod+Shift+3 move container to workspace $WS3
bindsym $Mod+Shift+4 move container to workspace $WS4
bindsym $Mod+Shift+5 move container to workspace $WS5
bindsym $Mod+Shift+6 move container to workspace $WS6
bindsym $Mod+Shift+7 move container to workspace $WS7
bindsym $Mod+Shift+8 move container to workspace $WS8
bindsym $Mod+Shift+9 move container to workspace $WS9
bindsym $Mod+Shift+0 move container to workspace $WS10

bindsym $Mod+Control+a resize shrink width 10 px or 5 ppt
bindsym $Mod+Control+s resize grow height 10 px or 5 ppt
bindsym $Mod+Control+w resize shrink height 10 px or 5 ppt
bindsym $Mod+Control+d resize grow width 10 px or 5 ppt
bindsym $Mod+Control+Left resize shrink width 10 px or 5 ppt
bindsym $Mod+Control+Down resize grow height 10 px or 5 ppt
bindsym $Mod+Control+Up resize shrink height 10 px or 5 ppt
bindsym $Mod+Control+Right resize grow width 10 px or 5 ppt
    '';
    programs.i3status-rust = {
      enable = true;
      bars.bar = {
        blocks = [
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
            block = "memory";
            display_type = "memory";
            format_mem = "{mem_used}% / {mem_total}%";
          }
          {
            block = "cpu";
            interval = 1;
          }
          {
            block = "load";
            interval = 1;
            format = "{1m}";
          }
          { block = "sound"; }
          {
            block = "time";
            interval = 60;
            format = "%a %d/%m %R";
          }
        ];
        settings = {
          theme =  {
            name = "solarized-dark";
            overrides = {
              idle_bg = "#123456";
              idle_fg = "#abcdef";
            };
          };
        };
        icons = "awesome5";
        theme = "gruvbox-dark";
      };
    };
    xdg.configFile."i3status/config".text = ''
general {
  output_format = "i3bar"
  colors = false
  markup = pango
  interval = 5
  color_good = '#2f343f'
  color_degraded = '#ebcb8b'
  color_bad = '#ba5e57'
}
order += "disk /"
order += "disk /home"
order += "load"
order += "ethernet _first_"
order += "wireless _first_"
order += "battery all"
order += "cpu_temperature 0"
order += "volume master"
order += "tztime local"
load {
        format = "<span background='#50fa7b'>  </span><span background='#e5e9f0'> %5min Load </span>"
}
cpu_temperature 0 {
        format = "<span background='#bf616a'>  </span><span background='#e5e9f0'> %degrees °C </span>"
        path = "/sys/class/thermal/thermal_zone0/temp"
}
disk "/" {
        format = "<span background='#fec7cd'>   </span><span background='#e5e9f0'> %free Left </span>"
}
disk "/home" {
        format = "<span background='#a1d569'>  %free Free </span>"
}
ethernet _first_ {
        format_up = "<span background='#88c0d0'>  </span><span background='#e5e9f0'> %ip </span>"
        format_down = "<span background='#88c0d0'>  </span><span background='#e5e9f0'> Disconnected </span>"
}
wireless _first_ {
        format_up = "<span background='#bd93f9'>  </span><span background='#e5e9f0'> %essid </span>"
        format_down = "<span background='#bd93f9'>  </span><span background='#e5e9f0'> Disconnected </span>"
}
volume master {
        format = "<span background='#ebcb8b'>  </span><span background='#e5e9f0'> %volume </span>"
        format_muted = "<span background='#bf616a'>  </span><span background='#e5e9f0'> Muted </span>"
        device = "default"
        mixer = "Master"
        mixer_idx = 0
}
battery all {
        last_full_capacity = true
        format = "<span background='#a3be8c'>  </span><span background='#e5e9f0'>%percentage [%status] </span>"
        format_down = "No Battery"
        status_chr = " Charging "
        status_bat = ""
        status_unk = " Unknown "
        status_full = " Charged "
        path = "/sys/class/power_supply/BAT%d/uevent"
        low_threshold = 10
}
tztime local {
  format = "<span background='#81a1c1'> %time </span>"
  format_time = " %a %-d %b %I:%M %p"
}
    '';
    programs.vim = {
      enable = true;
      extraConfig = ''
set autoread
set clipboard=unnamedplus
set enc=utf-8
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set fileencodings=ucs-bom,utf8,prc
set fileformats=unix
set gdefault
set go=rL
set guifont=Consolas:h10
set hlsearch
set incsearch
set modelines=0
set nocompatible
set noswapfile
set number
set pheader=
set ruler
set scrolloff=999
set shiftwidth=4
set shortmess+=I
set showcmd
set showmatch
set showmode
set smartcase
set smartindent
set smarttab
set softtabstop=4
set tabstop=4
set wildmenu

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

nnoremap j gj
nnoremap k gk

nnoremap <tab> <esc>
vnoremap <tab> <esc>
inoremap <tab> <esc>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap ; :

au FocusLost * :wa

let mapleader=""

syntax on

if has("gui_running")
  colorscheme desert
else
  colorscheme darkblue
endif

nmap <c-s> :w<CR>
imap <c-s> <Esc>:w<CR>a
      '';
    };
  };
}
