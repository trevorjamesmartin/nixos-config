# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xdg.nix
      ../../cachix.nix
      ../../modules/nixos/theme.nix
      ./vpn.nix
      ../../modules/nixos/thunar
      ../../modules/nixos/ladybird
      ../../modules/nixos/greeter
    ];

    yoshizl.ladybird.enable = false;
    yoshizl.thunar.enable = true;

    yoshizl.greeter.enable = true;


    boot = {
      initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
      initrd.kernelModules = [ ];
      # enable systemd
      initrd.systemd.enable = true;
       
      consoleLogLevel = 0;
      initrd.verbose = false;

      kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "rd.udev.log_level=0" "udev.log_level=0" "boot.shell_on_fail" ];

      kernelPackages = pkgs.linuxPackages_latest;
      kernelModules = [ "kvm-amd" "hid-magicmouse" "v4l2loopback" ];
      loader = {
        timeout=0;
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };

      # use less cache (default 60)
      kernel.sysctl = { "vm.swappiness" = 10;};

      # Bootloader.
      plymouth = {
        enable = true;
        theme = lib.mkForce "bgrt";
        themePackages = [
          pkgs.nixos-bgrt-plymouth
        ];
      };
  };


  
  # enale opengl options that help with gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Catppuccin Theme
  qt.platformTheme = "qt5ct";
  qt.style = "kvantum";
  #catppuccin.enable = true;

  services.fwupd.enable = true;

  services.xserver.videoDrivers = ["amdgpu"];

  networking.hostName = "thinkpadt14s"; # Define your hostname.
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  
  services.xserver.enable=true;

  services.xserver = {
    
    # Enable the GNOME Desktop Environment.
    displayManager = {
      gdm = {
        enable = false;
      };

      lightdm = {
        enable = false;
      };

    };

    desktopManager = {
      gnome = {
        enable = false;
      };
    };

    excludePackages = [ pkgs.xterm ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  console = {
    packages = [pkgs.terminus_font];
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
  };
 
  # Enable hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  programs.hyprlock.enable = true;

  services.hypridle.enable = true;


  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input = {
      General = {
        UserspaceHID = true;
      };
    };
  };

  # Enable Xbox controller driver (xone)
  hardware.xone.enable = true;

  # Enable Xbox controller driver (xpadneo)
  hardware.xpadneo.enable = false;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  
  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID"; # set the runtime directory

  # enable wallet support
  security.pam.services.greetd.enableKwallet = true;
  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tm = {
    isNormalUser = true;
    description = "Trevor";
    shell = pkgs.zsh;
    extraGroups = [ "video" "docker" "libvirtd" "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
      firefox
      pulseaudio
      vim
    ];
  };

  home-manager = {
    backupFileExtension = "backup";
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };

  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.vivaldi = {
      proprietaryCodecs = true;
      enableWideVine = true;
  };

  nixpkgs.config.packageOverrides = pkgs: { 
    kodi-wayland = pkgs.kodi-wayland.override { 
      joystickSupport = true;
    }; 
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    thunar # for the overlay to take effect, thunar has to be listed
    antimicroX
    gkrellm
    
    plymouth-matrix-theme
    gsettings-desktop-schemas
    gsettings-qt
    libsForQt5.polkit-kde-agent
    
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    lua
    #(lua.withPackages(ps: with ps;[ busted luafilesystem ]))

    # neofetch
    fastfetch

    # development
    git
    gnumake
    gcc
    clang
    cmake
    pkg-config
    meson
    cpio
    ninja

    # media keys
    playerctl

    # markdown
    pandoc

    # glib library
    glib.dev
    # Multi-platform library for creating OpenGL contexts and managing input, including keyboard, mouse, joystick and time
    glfw
    
    # theme
    catppuccin
    catppuccin-gtk
    catppuccin-qt5ct
    catppuccin-cursors.frappeBlue

#   # Add global theme
    #paper-icon-theme
    papirus-icon-theme
    catppuccin-papirus-folders
    # Adds a package defining a default icon/cursor theme.

    unzip
    wget

    mesa
    mesa-demos
    
    libdrm
    libGL.dev

    udev-gothic-nf

    google-chrome
    
    swww

    # QT libs
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.lightly
    libsForQt5.qt5.qtwayland
    kdePackages.qtwayland # qt6
    qt6Packages.qt6ct
    qt6.qtwayland
    
    # cursors
    bibata-cursors-translucent  
    bibata-cursors
    catppuccin
    catppuccin-cursors
    
    # internet messenger
    telegram-desktop

    # shell enhancements
    zsh-powerlevel10k

    # vpn tools
    wireguard-tools
    openvpn

    nix-direnv
    home-manager
    
    # games
    steam
    steam-run
    mangohud
    protonup
    lutris
    heroic
    #gogdl

    # extra wine containers 
    #bottles

    # kwalllet & friends
    kdePackages.kwallet
    libsForQt5.kwallet
    kdePackages.kwalletmanager
    libsForQt5.kwalletmanager
    kdePackages.ksshaskpass
    kdePackages.kwallet-pam
    libsForQt5.kwallet-pam
    
    # tool to package desktop applications as AppImages
    appimagekit

    # run unpatched dynamic binaries on NixOS
    nix-ld
    

    # a program to show the type of file
    file

    # tools for creatings file systems
    e2fsprogs
    fuse

    # Debian package manager
    dpkg

    # wayland / hyprland
    wayland-protocols
    wayland-scanner
    hyprwayland-scanner
    
    # cli tool for interacting with window manager
    wmctrl
    
    # json query
    jq
    # xml query
    xq-xml
    # yaml query
    yq

    # network
    networkmanagerapplet

    # bluetooth
    blueman
    bluez
    bluez-tools
    libinput

  
    # audio (pipewire) controls
    pavucontrol

  ];




  environment.sessionVariables = {
    #XDG_RUNTIME_DIR = "/run/user/$(id -u)";
    STEAM_EXTRA_COMPAT_TOOLS_PATH =
      "/home/tm/.steam/root/compatibilitytools.d";


    # tells electron apps to prefer wayland
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";

    # set cursor before login ?
    #XCURSOR_THEME = "${catppuccin_cursor_name}";
    XCURSOR_SIZE  = 64;
    #HYPRCURSOR_THEME = "${catppuccin_cursor_name}";
    HYPRCURSOR_SIZE = 64;
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  programs.gamemode.enable = true;

  programs.fuse.userAllowOther = true;

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    p7zip
  ];
  
  #services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
    };
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "tm" ];
  };

  programs.ssh.enableAskPassword = true;
  #programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
  programs.ssh.askPassword = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
  
  programs.zsh.enable = true;

  programs.zsh.shellAliases = {
    neofetch = "fastfetch -c neofetch";
    TerminalEmulator = "foot";
  };

  programs.bash.shellAliases = {
    neofetch = "fastfetch -c neofetch";
  };

 # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  security.sudo.enable = true;

  programs.sway.enable = true;

  programs.dconf = {
    enable = true;
    profiles = {
      user.databases = [{
        settings = with lib.gvariant; {
          # to remove titlebar buttons from Gnome apps:
          "org/gnome/desktop/wm/preferences.button-layout".value = "";
          "org/gnome/desktop/interface.cursor-size".value = mkInt32 64;
        };
      }];
    };
  };

  fonts = {

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      gyre-fonts
      powerline-fonts
      powerline-symbols
      xkcd-font
      udev-gothic-nf
      nerdfonts
      font-awesome
      helvetica-neue-lt-std
    ];
    fontconfig = {
      localConf = ''
        <!-- use a less horrible font substition for pdfs such as https://www.bkent.net/Doc/mdarchiv.pdf -->
        <match target="pattern">
          <test qual="any" name="family"><string>NewCenturySchlbk</string></test>
          <edit name="family" mode="assign" binding="same"><string>TeX Gyre Schola</string></edit>
        </match>
      '';
      defaultFonts = {
        serif = [  "Liberation Serif" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu Mono" ];
      };
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

    # Enable NAT
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    #externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [ 53 3333 50001 ];
    allowedUDPPorts = [ 53 51820 4444 5567 ];
    # plex
    #allowedTCPPorts = [ 3005 8324 32469 80 443 ];
    #allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 ];
  };

  users.groups.netdev.members = [ "nm-openconnect" ];


  services.fprintd = {
    enable = false; # not building atm
  };

  services.upower = {
    enable = true;
  };


  services.power-profiles-daemon = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true; # allow applications to resolve .local
    openFirewall = true;
    publish = {
        enable = true;
        userServices = true;
        addresses = true;
    };
  };

  # networking.enableIPv6 = false;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
