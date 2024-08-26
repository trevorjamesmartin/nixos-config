{ config, lib, inputs, pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager/neovim
    ../../../modules/home-manager/hyprland
    ../../../modules/home-manager/waybar
    ../../../modules/home-manager/foot
    ../../../modules/home-manager/kitty
    ../../../modules/home-manager/conky
    ../../../modules/home-manager/wlogout
    ../../../modules/home-manager/user-scripts
  ];

  yoshizl = {
    waybar.enable = true;                 # (status bar)

    hyprland = {
      enable = true;                      # Hyprland
      hyprbars = true;                    # + (titlebars)
      hyprlock = true;                    # + (screen-lock)
      hypridle = true;                    # + (lock/suspend when idle)
      hyprpaper = true;                   # + (desktop wallpaper)
      hyprexpo = true;                    # + (overview of workspaces)

      rofi = true;                        # installs rofi-wayland & rofi-bluetooth
    };

    foot.enable = true;                   # (terminal emulator)
    kitty.enable = false;                 # (terminal emulator)

    conky.enable = true;                  # lightweight system monitor
    neovim.enable = true;                 # code editor
    wlogout.enable = true;                # logout menu

    user-scripts.enable = true;           # scripts are prefixed by "$USER-"
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
    imagemagick
    gh

    # other web browsers
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

