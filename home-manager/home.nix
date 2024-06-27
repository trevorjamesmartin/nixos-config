{ config, pkgs, ... }:

{

  imports = [
    /etc/nixos/modules/home-manager/theme.nix
    /etc/nixos/modules/home-manager/my-neovim.nix
  ];
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
  nixpkgs.config.vivaldi = {
    proprietaryCodecs = true;
    enableWideVine = true;
  };
  
  nixpkgs.overlays = [
     (self: super: {
       discord = super.discord.overrideAttrs (
         _: { src = builtins.fetchTarball https://discord.com/api/download?platform=linux&format=tar.gz; }
       );
     })
  ];


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.lightly
    qt6Packages.qt6ct
    qt6.qtwayland
    qt5.qtwayland

    # QT (KDE/Plasma) File manager 
    dolphin

    # IRC client
    halloy

    conky

    # gpu (AMD) info
    radeontop

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    nerdfonts
    font-awesome
    # bibata-cursors
    xclip
    xdotool
    htop
    ripgrep
    ripgrep-all
    tree
    cmatrix
    asciiquarium
    imagemagick
    gh
    jq
    cava
    antimicroX
    imagemagick

    # web browsers
    google-chrome
    vivaldi
    firefox

    # photo editor
    gimp

    # chat

    discord
    betterdiscord-installer
    betterdiscordctl

    # A Wayland native snapshot editing tool, inspired by Snappy on macOS
    swappy

    # Nwg-look is a GTK3 settings editor, designed to work properly in wlroots-based Wayland environment.
    nwg-look 

    # irc
    quassel

    plex-mpv-shim
    spotify

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

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

    (pkgs.writeShellScriptBin "graceful-logout" ''
      #!/bin/sh

      HYPRCMDS=$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
      hyprctl --batch "$HYPRCMDS" >> /tmp/hypr/hyprexitwithgrace.log 2>&1
      hyprctl dispatch exit
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/kitty/kitty.conf".source = /etc/nixos/dotfiles/kitty/kitty.conf;

    ".config/hypr" = {
      source = /etc/nixos/dotfiles/hypr;
      recursive = true;
    };

    ".config/waybar" = {
      source = /etc/nixos/dotfiles/waybar;
      recursive = true;
    };

    ".config/libinput-gestures.conf".source = /etc/nixos/dotfiles/libinput-gestures.conf;
  
  };

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
    # EDITOR = "emacs";
    EDITOR = "nvim";
    TERM = "kitty";
    TERMINAL = "kitty";
    DOTFILES = "/etc/nixos/dotfiles";
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

      # Where this shows 'kitty' - the value should be whatever $TERM is outside tmux
      set-option -ga terminal-overrides ",kitty:Tc"

      # Catppuccin options
      set -g @catppuccin_host 'on'
      set -g @catppuccin_window_tabs_enabled 'on'
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
