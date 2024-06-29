# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:
let
  # TODO : system theme
  catppuccin_name = "catppuccin-frappe-blue-standard+default";
  catppuccin-gtk = pkgs.catppuccin-gtk;
  catppuccin_cursor_name = "catppuccin-frappe-blue-cursors";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../cachix.nix
      ../../modules/nixos/gdm-theme.nix
    ];
  
  # enale opengl options that help with gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Catppuccin Theme
  qt.platformTheme = "qt5ct";
  catppuccin.enable = true;

  services.fwupd.enable = true;

  services.xserver.videoDrivers = ["amdgpu"];
  
  # try not to use cache (default 60)
  boot.kernel.sysctl = { "vm.swappiness" = 10;};

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  boot.loader.grub.fontSize = "128";

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
  services.xserver={
      enable=true;
      xrandrHeads=[
        {
          output = "eDP-1";
          monitorConfig = ''Option "Enable" "false"'';
          #primary = true;
        }
        {
          output = "HDMI-A-1";
          monitorConfig = ''Option "Enable" "true"'';
   
        }
        {
          output = "DP-2";
          monitorConfig = ''Option "Enable" "true"'';
          #primary = true;
        }
      ];
      exportConfiguration=true;
  };


  services.xserver = {
    
    # Enable the GNOME Desktop Environment.
    displayManager = {
      gdm = {
        enable = true;
      };
    };

    desktopManager = {
      gnome = {
        enable = true;
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
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  programs.hyprlock.enable = true;

  services.hypridle.enable = true;


# # Enable KDE Plasma
# services.displayManager.sddm = {
#     enable = true;
#     wayland.enable = true;
#     theme = "${pkgs.catppuccin-sddm-corners}/share/sddm/themes/catppuccin-sddm-corners"; # Not including `Main.qml`, since SDDM does this automagically
#     extraPackages = [
#       pkgs.libsForQt5.qt5.qtgraphicaleffects
#       pkgs.libsForQt5.qt5.qtsvg
#     ];
# };

  services.xserver.displayManager.setupCommands = ''
      displays=$(wlr-randr --json |jq length);
      if [[ $displays -gt 1 ]] then
        primary=$(wlr-randr --json |jq -r '.[0]| .name');
        wlr-randr --output $primary --off;
      fi
      echo "SETUP COMMANDS" >> /tmp/hyprexitwithgrace.log
  '';

  #services.displayManager.sddm.wayland.enable = true;
  #services.desktopManager.plasma6.enable = true; 
  #services.desktopManager.plasma6.enable = true; 
  
  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable Xbox controller driver (xone)
  hardware.xone.enable = true;

  # Enable Xbox controller driver (xpadneo)
  hardware.xpadneo.enable = false;
  
  # steam controller
  # hardware.steam-hardware.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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
  services.plex = {
    enable = false;
    openFirewall = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tm = {
    isNormalUser = true;
    description = "Trevor";
    shell = pkgs.zsh;
    extraGroups = [ "docker" "libvirtd" "networkmanager" "wheel" "input" ];
    packages = with pkgs; [
      firefox
      neovim
      chromium
      brave

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

  # enable WayDroid android emulation
  # virtualisation.waydroid.enable = true;

  # enable Docker containers
  #virtualisation.docker.enable = true;
  #virtualisation.docker.rootless = {
  #  enable = true;
  #  setSocketVariable = true;
  #};

  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris self.mpvScripts.uosc ];
      };
    })


#    (self: super: {
#      hyprland = super.hyprland.override {
#        plugins = [ self.hyprlandPlugins.hyprexpo self.hyprlandPlugins.hyprbars ];
#      };
#    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # media
    mpv

  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    (lua.withPackages(ps: with ps;[ busted luafilesystem ]))
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
    python3
    nodejs_18
    pandoc

    glib.dev
    
    catppuccin
    catppuccin-gtk
    catppuccin-qt5ct
    #catppuccin-cursors
#   # Add global theme
    #paper-icon-theme
    papirus-icon-theme
    catppuccin-papirus-folders
    # Adds a package defining a default icon/cursor theme.

    unzip
    wget
    #
    mesa
    mesa-demos
    libdrm
    libGL.dev

    # alacritty
    kitty
    kitty-img
    kitty-themes
    udev-gothic-nf

    google-chrome
    
    swww
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5ct
    libsForQt5.qt5.qtwayland
    kdePackages.qtwayland # qt6

    #bibata-cursors              
    #bibata-cursors-translucent  
    # bibata-extra-cursors

    # Gnome Extensions
#    gnomeExtensions.dash2dock-lite
    arc-theme
    pantheon.elementary-gtk-theme
    gruvbox-gtk-theme

    telegram-desktop
    #virt-manager
    #qemu_kvm

    zsh-powerlevel10k
    wireguard-tools
    openvpn

    screen
    irssi

    nix-direnv
    home-manager
    
    steam
    steam-run
    mangohud

    protonup

    lutris
    heroic
    #gogdl

    bottles

    # kdePackages.drkonqi
    appimagekit
    # lbry

    # ... add this line to the rest of your configuration modules
    nix-ld

    # The module in this repository defines a new module under (programs.nix-ld.dev) instead of (programs.nix-ld) 
    # to not collide with the nixpkgs version.
    
    file

    fuse2fs
    fuse

    dpkg

    # wayland / hyprland
    wayland-protocols
    wayland-scanner
    hyprwayland-scanner


     
    dunst

    hyprcursor
    hyprpaper
    hyprlock
    
    libinput
    libinput-gestures
    wmctrl
    xdotool


    # screenshot with grim -l 0 -g "$(slurp)" - | wl-copy
    grim
    # select util
    slurp
    # xclip alternative
    wl-clipboard

    networkmanagerapplet

    wlr-randr
    swww
    rofi-wayland
    
    waybar
    pavucontrol
    power-profiles-daemon
    rofi-power-menu
    rofi-bluetooth
    blueman

    wdisplays
    brightnessctl

    xfce.thunar
    xfce.tumbler
    oculante

    vlc
  ];

  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];

  services.gvfs.enable = true; # mount, trash and other functionality
  services.tumbler.enable = true; # thumbnail support
 
  environment.etc = {
    "xdg/Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "Catppuccin-Frappe-Blue";
    };
    
    "xdg/gtk-4.0".source = "${catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-4.0";

    #"xdg/gtk-3.0".source = "${catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-3.0";
    
    "xdg/gtk-3.0/settings.ini" = {
      text = ''
      [Settings]
      gtk-icon-theme-name=Papirus
      gtk-theme-name=${catppuccin_name}
      '';
      mode = "444";
    };

    # qt 4/5 global theme
    "xdg/Trolltech.conf" = {
      text = ''
      [Qt]
I     style=Kvantum
      '';
      mode = "444";
    };

    # TODO: system theme 

    #"xdg/gtk-4.0/gtk-dark.css".source = "${catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-4.0/gtk-dark.css";

    #"xdg/gtk-4.0/assets".source = "${catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-4.0/assets";
    #"xdg/gtk-2.0".source =  ./gtk-2.0;
    #"xdg/gtk-3.0".source =  ./gtk-3.0;
  };

  environment.sessionVariables = {
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";
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
   
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
#       xdg-desktop-portal-gtk
      ];
    };
  }; 

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


  programs.zsh.enable = true;

  programs.zsh.shellAliases = {
    neofetch = "fastfetch -c neofetch";
    TerminalEmulator = "kitty";
  };

  programs.bash.shellAliases = {
    neofetch = "fastfetch -c neofetch";
  };



 # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

#  security.doas.enable = true;
  security.sudo.enable = true;
# security.doas.extraRules = [{
#   users = ["tm"];
#   # Optional, retains environment variables while running commands 
#   # e.g. retains your NIX_PATH when applying your config
#   keepEnv = true; 
#   persist = true;  # Optional, only require password verification a single time
# }];
  

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    xterm
  ];
  
  #environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # plasma-browser-integration
    # konsole
    # oxygen
  #]; 

  programs.sway.enable = true;

  programs.dconf.enable = true;

  fonts = {

    packages = with pkgs; [ 
      fira-code 
      gyre-fonts 
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
  #;Q networking.firewall.allowedTCPPorts = [ ... ];
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
