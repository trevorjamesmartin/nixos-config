{ config, lib, inputs, pkgs, ... }:
{
  imports = [
    /etc/nixos/modules/home-manager/theme.nix
    /etc/nixos/modules/home-manager/my-neovim.nix

    /etc/nixos/modules/home-manager/hyprland 
    /etc/nixos/modules/home-manager/hyprlock
    /etc/nixos/modules/home-manager/hypridle
    /etc/nixos/modules/home-manager/waybar
    /etc/nixos/modules/home-manager/foot
    /etc/nixos/modules/home-manager/libinput-gestures

  ];

  yoshizl = {
    waybar.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    hypridle.enable = true;
    foot.enable = true;
    libinput-gestures.enable = true;
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

  programs.tmux = {
    enable = true;
    catppuccin.enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    sensibleOnTop = true;
    # This should either be screen-256color or tmux-256color where it exists
    terminal = "tmux-256color";

    extraConfig = ''
      set -g status on
      set -g mouse on

      # Where this shows 'foot' - the value should be whatever $TERM is outside tmux
      set-option -ga terminal-overrides ",foot:Tc"

      # Catppuccin options
      set -g @catppuccin_host 'on'
      set -g @catppuccin_window_tabs_enabled 'on'
    '';
  };


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
     (pkgs.writeShellScriptBin "graceful-logout" ''
     #!/bin/sh
     HYPRCMDS=$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
     hyprctl --batch "$HYPRCMDS" >> /tmp/hypr/hyprexitwithgrace.log 2>&1
     hyprctl dispatch exit
     '')   

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
    firefox

    # photo editor
    gimp

    inkscape

    # emoji picker
    smile
    # chat

    discord
    betterdiscord-installer
    betterdiscordctl

    # A Wayland native snapshot editing tool, inspired by Snappy on macOS
    swappy

    # irc
    spotify

    (pkgs.writeShellScriptBin "${config.home.username}-local-update" ''
      echo "Hello, ${config.home.username}! (ready to update & run home-manager switch...)"
      nix flake update ~/.config/home-manager
      home-manager switch --impure
    '')

    (pkgs.writeShellScriptBin "${config.home.username}-system-update" ''
      echo "Hello, ${config.home.username}! (ready to update & run nixos-rebuild switch...)"
      sudo nix flake update /etc/nixos --impure
      sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace -j 4
    '')


    (pkgs.writeShellScriptBin "${config.home.username}-collect-garbage" ''
      echo "Hello, ${config.home.username}! (ready to collect the garbage)"
      sudo nix-collect-garbage -d
      nix-collect-garbage -d
    '')

    (pkgs.writeShellScriptBin "${config.home.username}-optimize" ''
      echo "Hello, ${config.home.username}! (ready to optimize the Nix store)"
      sudo nix-store --optimize -vvv
      nix-store --optimize -vvv
    '')


  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
# home.file = {
#   ".config/kitty/kitty.conf".source = /etc/nixos/dotfiles/kitty/kitty.conf;
# };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/tm/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "foot";
    TERMINAL = "foot";
  };

  fonts.fontconfig.enable = true; # required to autoload fonts from packages
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

