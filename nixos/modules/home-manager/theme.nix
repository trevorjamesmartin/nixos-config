# theme.nix
{ lib, pkgs, ...}:
let
  # edit catppuccin here
  catppuccin_flavor = "frappe";
  catppuccin_accent = "blue";
  catppuccin_kvantum_theme = "Catppuccin-Frappe-Blue";
  # todo: check how we build these names
  catppuccin_name = "catppuccin-${catppuccin_flavor}-${catppuccin_accent}-standard";
  cursor_variant = "macOS-BigSur";
  cursor_size = 32;
in
{
  home.packages = with pkgs; [
    catppuccin
    catppuccin-gtk
    catppuccin-qt5ct
    #catppuccin-cursors
    apple-cursor
    whitesur-gtk-theme
    tmuxPlugins.catppuccin
  ];
  
  home.pointerCursor = {
    gtk.enable = true;
    #package = pkgs.catppuccin-cursors.frappeBlue;
    package = pkgs.apple-cursor;
    name = cursor_variant;
    #"catppuccin-${catppuccin_flavor}-${catppuccin_accent}-cursors";
    size = cursor_size;
  };

  # general settings
  catppuccin = {
    enable = true;
    flavor = "${catppuccin_flavor}";
    accent = "${catppuccin_accent}";
  };


  # gtk settings
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-${catppuccin_flavor}-${catppuccin_accent}-standard";
      package = pkgs.catppuccin-gtk;
    };
 
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
    
    #iconTheme = {
      #name = "Papirus-Dark";
    #}; 
  };

  # qt settings
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style = {
      package = pkgs.catppuccin-kvantum;
      name = "kvantum";
    };
  };

  dconf.settings = with lib.gvariant; {
    # to remove titlebar buttons from Gnome apps:
    # gsettings set org.gnome.desktop.wm.preferences on-layout ''
    "org/gnome/desktop/wm/preferences.button-layout".value = "";
  };  

  # Generate kvantum 
  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
    General.theme = catppuccin_kvantum_theme;
  };

  # link (missing?) gtk4 files
  home.file.".config/gtk-4.0/gtk-dark.css".source = 
      "${pkgs.catppuccin-gtk}/share/themes/catppuccin-${catppuccin_flavor}-${catppuccin_accent}-standard/gtk-4.0/gtk-dark.css";
  home.file.".config/gtk-4.0/assets" = {
    recursive = true;
    source = "${pkgs.catppuccin-gtk}/share/themes/catppuccin-${catppuccin_flavor}-${catppuccin_accent}-standard/gtk-4.0/assets";
  };
  home.sessionVariables = {
    XCURSOR_THEME = cursor_variant;
    XCURSOR_SIZE  = cursor_size;
    HYPRCURSOR_SIZE = cursor_size; 
    HYPRCURSOR_THEME = cursor_variant;
    # pretty 
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
  };

}
