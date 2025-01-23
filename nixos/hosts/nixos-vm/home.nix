{ config, lib, pkgs, inputs, localHost, ...}: 
{
  imports = [
    ../../modules/home-manager/neovim
    ../../modules/home-manager/hyprland
    ../../modules/home-manager/waybar
    ../../modules/home-manager/foot
    ../../modules/home-manager/kitty
    ../../modules/home-manager/conky
    ../../modules/home-manager/wlogout
    ../../modules/home-manager/user-scripts

  ];

  yoshizl = {
    waybar.enable = true;                 # (status bar)

    hyprland = {
      enable = true;                      # Hyprland configuration
      hyprexpo = false;                    # + (overview of workspaces)
      hyprbars = false;                    # + (titlebars)
      hyprlock = false;                    # + (screen-lock)
      hypridle = false;                    # + (lock/suspend when idle)
      hyprpaper = true;                   # + (desktop wallpaper)
      
      swww = false;                       #   alternative wallpaper setter 

      rofi = true;                        # installs rofi-wayland & rofi-bluetooth
    };

    foot.enable = true;                   # (terminal emulator)
    kitty.enable = false;                 # (terminal emulator)

    conky.enable = true;                  # lightweight system monitor
    neovim.enable = true;                 # code editor
    wlogout.enable = true;                # logout menu

    user-scripts.enable = true;           # scripts are prefixed by "$USER-"
  };

  # override monitor and workspace for this host
  wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
          ",2560x1600@59.99Hz,0x0,1"        # everything else
  ];

  wayland.windowManager.hyprland.settings.workspace = lib.mkForce [
          "special:neovim, on-created-empty:$terminal nvim"
          "special:monitor, on-created-empty:$terminal btm"
          #"special:tunes, on-created-empty:spotify"
  ];
  
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = localHost.user;
  home.homeDirectory = "/home/${localHost.user}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.
  
  home.enableNixpkgsReleaseCheck = false;

  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "1password" "gh" "systemd" "zbell" "sudo" ];
      theme = "robbyrussell";
    };
  };
  
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };

  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform=wayland"
    ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "Hypsi-GUI" ''
      SVGA_VGPU10=0 hypsi -webview
    '')
    #oh-my-zsh
    xarchiver

    # terminal apps
    htop
    ripgrep
    #ripgrep-all
    #imagemagick
    gh
    #tmux
    #irssi

    # other web browsers
    firefox
    #google-chrome
    #chromium

    # image editors
    #gimp
    #inkscape

    # chat
    #discord
    #betterdiscord-installe
    #betterdiscordctl
    #pidgin
    #pidginPackages.purple-plugin-pack

    # music
    #spotify

    # code 
    #gitkraken

    # dba
    #dbeaver-bin

    # fun
    #lsd

    # dowloaders
    #torrential
  ];
  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
  };
  fonts.fontconfig.enable = true; # required to autoload fonts from packages
  

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

