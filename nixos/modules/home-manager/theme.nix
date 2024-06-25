# theme.nix
{ pkgs, ...}:
let
  catppuccin_name = "catppuccin-frappe-blue-standard+default";
  catppuccin-gtk = pkgs.catppuccin-gtk;

  # catppuccin_cursor_name = "catppuccin-frappe-blue-cursors";
  catppuccin_cursor_name = "catppuccin-mocha-mauve-cursors";


in
{
  home.packages = with pkgs; [
    catppuccin
    catppuccin-gtk
    catppuccin-qt5ct
    catppuccin-cursors
    tmuxPlugins.catppuccin
  ];

  # general settings
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

  };

  programs.tmux = {
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

      # Where this shows 'alacritty' - the value should be whatever $TERM is outside tmux
      set-option -ga terminal-overrides ",alacritty:Tc"

      # Catppuccin options
      set -g @catppuccin_host 'on'
      set -g @catppuccin_window_tabs_enabled 'on'
    '';
  };

  # gtk settings
  gtk = {
    enable = true;
    theme = {
      name = catppuccin_name;
      package = catppuccin-gtk;
    };
 
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
    
    # setting this more than once
    # may causes a conflict during rebuild
#   cursorTheme = {
#     size = 64;
#     name = "catppuccin-frappe-blue-cursors";
#     package = pkgs.catppuccin-cursors.frappeBlue;
#   };

    iconTheme = {
      name = "Papirus-Dark";
    };
  };

  # qt settings
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style = {
      package = pkgs.catppuccin-kvantum;
      name = "kvantum";
    };
  };

  # Generate kvantum 
  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
    General.theme = "Catppuccin-Mocha-Mauve";
  };

  # link (missing?) gtk4 files
  home.file.".config/gtk-4.0/gtk-dark.css".source = "${catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-4.0/gtk-dark.css";
  home.file.".config/gtk-4.0/assets" = {
    recursive = true;
    source = "${catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-4.0/assets";
  };

  home.sessionVariables = {
    # I'm setting these environment variables for hyprcursor to use
    XCURSOR_THEME = "${catppuccin_cursor_name}";
    XCURSOR_SIZE  = 64;
    HYPRCURSOR_THEME = "${catppuccin_cursor_name}";
    HYPRCURSOR_SIZE = 64;
    
    # pretty 
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
  };

}
