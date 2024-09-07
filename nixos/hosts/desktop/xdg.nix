{ config, lib, pkgs, ... }:
let
  # TODO : system theme
  catppuccin_name = "catppuccin-frappe-blue-standard+default";
  catppuccin-gtk = pkgs.catppuccin-gtk;
  catppuccin_cursor_name = "catppuccin-frappe-blue-cursors";
in
{
 
  xdg = {
    portal = {
      enable = true;
      config.common.default = "*"; # uses the first portal implementation found in lexicographical order 
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-kde
      ];
    };
  };

  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID"; # set the runtime directory
  
  # /etc/xdg/
  environment.etc = {
    "xdg/Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
      General.theme = "Catppuccin-Frappe-Blue";
    };
    
    "xdg/gtk-4.0".source = "${pkgs.catppuccin-gtk}/share/themes/${catppuccin_name}/gtk-4.0";

    "xdg/gtk-3.0/settings.ini" = {
      text = ''
      [Settings]
      gtk-icon-theme-name=Papirus
      gtk-theme-name=${catppuccin_name}
      gtk-cursor-theme-name=Catppuccin-Frappe-Blue
      gtk-cursor-theme-size=64
      '';
      mode = "444";
    };

    # qt 4/5 global theme
    "xdg/Trolltech.conf" = {
      text = ''
      [Qt]
      style=Kvantum
      '';
      mode = "444";
    };

    # TODO: system theme 

    "xdg/user-dirs.defaults" = {
      text = ''
        DESKTOP=Desktop
        DOCUMENTS=Documents
        DOWNLOAD=Downloads
        MUSIC=Music
        PICTURES=Pictures
        PUBLICSHARE=Public
        TEMPLATES=Templates
        VIDEOS=Videos
      '';
    };
  
  };

}
