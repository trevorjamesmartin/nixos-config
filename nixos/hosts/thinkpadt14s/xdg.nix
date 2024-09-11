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
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-kde
      ];
    };
  };

  environment.variables.XDG_RUNTIME_DIR = "/run/user/$UID"; # set the runtime directory
  
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=Desktop
    DOCUMENTS=Documents
    DOWNLOAD=Downloads
    MUSIC=Music
    PICTURES=Pictures
    PUBLICSHARE=Public
    TEMPLATES=Templates
    VIDEOS=Videos
  '';

}
