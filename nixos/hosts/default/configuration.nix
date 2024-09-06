# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:
{
  imports = [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xdg.nix
      ../../cachix.nix
      ./vpn.nix
      ../../modules/nixos/thunar
      ../../modules/nixos/greeter
      ../../modules/nixos/plymouth
      ../../modules/nixos/hyprland

      ../../modules/nixos/theme
      ../../modules/nixos/gaming
  ];

  yoshizl = {
    plymouth.enable = true;   # graphical boot screen
    theme.enable = true;      # system theme
    greeter = { 
      enable = true;          # login screen
      dark_mode = true;       # prefer_dark_theme ?
    };
    thunar = {
      enable = true;     # installs Thunar file manager
      removeWallpaper = true;
    };
    hyprland.enable = true;   # install Hyprland with kwallet

    gaming.enable = true; # play some games
  };

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

    kernel.sysctl = { "vm.swappiness" = 10;};
  };

 
  # enable opengl options that help with gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };


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
  
  services.xserver = {
    enable=true;
    excludePackages = [ pkgs.xterm ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  console = {
    packages = [pkgs.terminus_font];
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
  };

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.vivaldi = {
      proprietaryCodecs = true;
      enableWideVine = true;
  };

  programs.git.config = {
    defaultBranch = "main";
    url = {
      "https://github.com/" = {
        insteadOf = [
          "gh:"
          "github:"
        ];
      };
    };
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    lua

    # media keys
    playerctl

    # markdown
    pandoc

    # glib library
    glib.dev
    
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
    home-manager
    
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

  programs.fuse.userAllowOther = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    p7zip
  ];
  
  #services.flatpak.enable = true;
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
    Hyprland = "Hyprland > /tmp/hyprexitwithgrace.log 2>&1";
  };

  programs.bash.shellAliases = {
    neofetch = "fastfetch -c neofetch";
    Hyprland = "Hyprland > /tmp/hyprexitwithgrace.log 2>&1";
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  users.groups.netdev.members = [ "nm-openconnect" ];

  services.fprintd = {
    enable = false; # not building atm
  };

  # show battery percentages
  services.upower = {
    enable = true;
  };

  # for more information: `man powerprofilesctl`
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
