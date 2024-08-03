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
    wlogout.enable = true;  # 
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

    # scripts
    (pkgs.writeShellScriptBin "${config.home.username}-local-update" ''
      echo "Hello, ${config.home.username}! (ready to update & run home-manager switch...)"
      hyprctl dispatch tagwindow +nix
      nix flake update ~/.config/home-manager
      home-manager switch --impure
      hyprctl dispatch tagwindow -- -nix
    '')

    (pkgs.writeShellScriptBin "${config.home.username}-system-update" ''
      echo "Hello, ${config.home.username}! (ready to update & run nixos-rebuild switch...)"
      hyprctl dispatch tagwindow +nix
      sudo nix flake update /etc/nixos --impure
      sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace -j 4
      hyprctl dispatch tagwindow -- -nix
    '')

    (pkgs.writeShellScriptBin "${config.home.username}-collect-garbage" ''
      hyprctl dispatch tagwindow +nix
      echo "Hello, ${config.home.username}! (ready to collect the garbage)"
      sudo nix-collect-garbage -d
      nix-collect-garbage -d
      hyprctl dispatch tagwindow -- -nix
    '')

    (pkgs.writeShellScriptBin "${config.home.username}-optimize" ''
      hyprctl dispatch tagwindow +nix
      echo "Hello, ${config.home.username}! (ready to optimize the Nix store)"
      sudo nix-store --optimize -vvv
      nix-store --optimize -vvv
      hyprctl dispatch tagwindow -- -nix
    '')

  ];

  fonts.fontconfig.enable = true; # required to autoload fonts from packages

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

