{ config, pkgs, system, iwi-dejavu, iwi-consolas, ... }: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.nvidiaSettings = true;
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  #hardware.nvidia.modesetting.enable = true;
  #hardware.nvidia.prime = {
  #  offload = {
  #    enable = true;
  #    enableOffloadCmd = true;
  #  };
  #  intelBusId = "PCI:0:2:0";
  #  nvidiaBusId = "PCI:1:0:0";
  #};

  environment.systemPackages = with pkgs; [
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

    #obsidian

    #mate.engrampa

    #cinnamon.nemo-compare
    #cinnamon.nemo-preview
    #cinnamon.nemo-seahorse
    #cinnamon.nemo-share
    folder-color-switcher
    nemo-fileroller
    nemo-python
    nemo
  ];

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    #ibus.engines = with pkgs.ibus-engines; [ mozc ];
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;
  fonts.fontconfig.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  hardware.pulseaudio.enable = false;
  #sound.mediaKeys = {
  #  enable = true;
  #  volumeStep = "5%";
  #};
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
  services.avahi.nssmdns4 = true;
  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.illum.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ];
  services.printing.enable = true;
  services.teamviewer.enable = true;
  services.tumbler.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "andrea";
    defaultSession = "none+i3";
  };
  services.libinput = {
    enable = true;
    mouse.scrollMethod = "button";
    mouse.accelSpeed = "18";
  };
  services.xserver = {
    autoRepeatDelay = 300;
    autoRepeatInterval = 25;
    desktopManager.wallpaper.mode = "fill";
    desktopManager.xterm.enable = false;
    dpi = 96;
    enable = true;
    xkb.layout = "it";
    xkb.options = "caps:ctrl_modifier,eurosign:e"; #caps:super
    windowManager.i3.enable = true;
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

  fonts.packages = [
    pkgs.ipafont
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    iwi-dejavu.packages.${system}.default
    iwi-consolas.packages.${system}.default
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [
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
}
