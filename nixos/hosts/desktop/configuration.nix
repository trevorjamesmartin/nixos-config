# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:
let
  theme_flavor = "mocha"; # {mocha,frappe,macchiato,latte}
  theme_accent = "teal"; #{rosewater,flamingo,pink,mauve,red,maroon,peach,yellow,green,teal,sky,sapphire,blue,lavender} 
  # [--tweaks {black,rimless,normal,float} [{black,rimless,normal,float} ...]]
  kvantum_theme = "Catppuccin-Mocha-Teal";
in

{

  catppuccin = {
    enable = true;
    flavor = theme_flavor;
    accent = theme_accent;
  };


  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xdg.nix
      #./vpn.nix
      ../../cachix.nix
      ../../modules/nixos/thunar
      ../../modules/nixos/greeter
      ../../modules/nixos/hyprland

      (import ../../modules/nixos/theme {
          gtk_theme="catppuccin-${theme_flavor}-${theme_accent}-standard";
          kvantum_theme = "${kvantum_theme}";
          gtk-icon_theme="Papirus";
      })
      
      ../../modules/nixos/gaming
  ];
  
  nixpkgs.overlays = [
    (final: prev: {
      adi1090x-plymouth-themes = prev.adi1090x-plymouth-themes.overrideAttrs(oldAttrs: rec {
        selected_themes = [ "hexa_retro" ];
      });
    })
    
    # build catppuccin-gtk with specified flavor-accent 
    (final: prev: {
      catppuccin-gtk = prev.catppuccin-gtk.overrideAttrs(oldAttrs: rec {
        installPhase = ''
        runHook preInstall
        mkdir -p $out/share/themes
        python3 build.py ${theme_flavor} --accent ${theme_accent} --size standard --dest $out/share/themes
        runHook postInstall
        '';
      });
    })

  ];
  

  yoshizl = {
    theme.enable = true;      # system theme
    greeter = { 
      enable = true;          # login screen
      dark_mode = true;       # prefer_dark_theme ?
    };
    thunar = {
      enable = true;          # installs Thunar file manager
      removeWallpaper = true;
    };
    hyprland.enable = true;   # install Hyprland with kwallet

    gaming.enable = true;     # video games
  };

  # plymouth
  boot.plymouth.themePackages = [ pkgs.adi1090x-plymouth-themes ];
  boot.plymouth.theme = lib.mkForce "hexa_retro";
  boot.plymouth.enable = true;
  
  # quiet boot
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "rd.udev.log_level=0" "udev.log_level=0" "boot.shell_on_fail" "ipv6.disable=1" ];

  # boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.configurationLimit = 2;

  # kernel 
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" "v4l2loopback" ];

  # enable firmware updates
  services.fwupd.enable = true;

  # enable firmware
  hardware.enableAllFirmware = true;

  # support for ntfs
  boot.supportedFilesystems = [ "ntfs" ];

  # video driver
  services.xserver.videoDrivers = ["amdgpu"];

  networking.hostName = "desktop"; # Define your hostname.
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

  # Enable the X11 windowing system.
  services.xserver = {
    enable=true;
    excludePackages = [ pkgs.xterm ];
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.xone.enable = true;
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  programs.ssh.enableAskPassword = true; # don't ask on commandline git
  programs.ssh.askPassword = ""; # don't ask on commandline git

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tm = {
    isNormalUser = true;
    description = "Trevor";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
    packages = with pkgs; [
    #  thunderbird
      firefox
      pulseaudio
      vim
      git
      wget
      jq
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    fastfetch

    # media keys
    playerctl

    # markdown
    pandoc

    # glib library
    # glib.dev
    
    # Multi-platform library for creating OpenGL contexts and managing input, including keyboard, mouse, joystick and time
    glfw
    
    foot

    unzip
    wget
    udev-gothic-nf

    # internet messenger
    telegram-desktop

    # shell enhancements
    zsh-powerlevel10k

    nix-direnv
    #home-manager # builds with 'nixos-rebuild switch' (no need to call directly) 
    
    # tool to package desktop applications as AppImages
    #appimagekit

    # run unpatched dynamic binaries on NixOS
    nix-ld

    # a program to show the type of file
    file

    # tools for creatings file systems
    e2fsprogs
    fuse
    ntfs3g

    # Debian package manager
    #dpkg

    # cli tool for interacting with window manager
    #wmctrl
    
    # json query
    jq
    # xml query
    xq-xml
    # yaml query
    yq

    # network
    networkmanagerapplet

    # bluetooth
##  blueman
##  bluez
##  bluez-tools
##  libinput
  
    # audio (pipewire) controls
    pavucontrol

  ];
  programs.fuse.userAllowOther = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    p7zip
  ];

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
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "tm" ];
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
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Enable NAT
  networking.nat = {
    enable = true;
    enableIPv6 = false;
    #externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };
  
  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [ 53 3333 50001 ];
    allowedUDPPorts = [ 53 51820 4444 5567 ];
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
