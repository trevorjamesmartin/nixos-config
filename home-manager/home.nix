{ config, lib, inputs, pkgs, ... }:
{
  imports = [
    /etc/nixos/modules/home-manager/theme.nix
    /etc/nixos/modules/home-manager/neovim
    /etc/nixos/modules/home-manager/hyprland 
    /etc/nixos/modules/home-manager/hyprlock
    /etc/nixos/modules/home-manager/hypridle
    /etc/nixos/modules/home-manager/hyprpaper
    /etc/nixos/modules/home-manager/waybar
    /etc/nixos/modules/home-manager/foot
    /etc/nixos/modules/home-manager/kitty
    /etc/nixos/modules/home-manager/libinput-gestures
    /etc/nixos/modules/home-manager/conky
    /etc/nixos/modules/home-manager/wlogout
    /etc/nixos/modules/home-manager/user-scripts
  ];

  yoshizl = {
    waybar.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    hypridle.enable = true;
    hyprpaper.enable = true;
    foot.enable = true;
    kitty.enable = false;
    libinput-gestures.enable = true;
    conky.enable = true;
    neovim.enable = true;
    wlogout.enable = true;
    user-scripts.enable = true;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "tm";
  home.homeDirectory = "/home/tm";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
     (self: super: {
       discord = super.discord.overrideAttrs (
         _: { src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz; }
       );
     })
  ];

  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--enable-features=VaapiVideoDecodeLinuxGL"
      "--use-gl=angle"
      "--use-angle=gl"
      "--ozone-platform=wayland"
      # to fix journal flood during video playback,
      # disable (chrome://flags) 
      #   "multi-plane formats for hardware video decoder"
      #   "multi-plane formats for software video decoder"
    ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [

    # terminal apps
    htop
    ripgrep
    ripgrep-all
    tree
    cmatrix
    imagemagick
    gh
    cava

    # web browsers
    google-chrome
    vivaldi
    chromium

    # image editors
    gimp
    inkscape

    # chat
    discord
    betterdiscord-installer
    betterdiscordctl

    # music
    spotify
  ];

  fonts.fontconfig.enable = true; # required to autoload fonts from packages

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

