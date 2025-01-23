# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, localHost, ... }:
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
      ../../modules/nixos/xdg.nix
      ../../modules/nixos/hyprland

      (import ../../modules/nixos/theme {
          gtk_theme="catppuccin-${theme_flavor}-${theme_accent}-standard";
          kvantum_theme = "${kvantum_theme}";
          gtk-icon_theme="Papirus";
      })
    ];

  home-manager.backupFileExtension = "backup";
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm"; # Define your hostname.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.enableHidpi = true;
  services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tm = {
    isNormalUser = true;
    description = "Trevor";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with inputs.nixpkgs.legacyPackages.aarch64-linux; [
      git
      gh
      ripgrep

    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with inputs.nixpkgs.legacyPackages.aarch64-linux; [
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
    lua5_1
    luarocks
    python3
    imagemagick

    # media keys
    playerctl

    # markdown
    pandoc

    neovim
    open-vm-tools
    foot
    hyprland
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    nerdfonts
    # json query
    jq
    # xml query
    xq-xml
    # yaml query
    yq

    # shell enhancements
    zsh-powerlevel10k
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
