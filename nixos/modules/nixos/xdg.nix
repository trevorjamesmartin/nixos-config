{ config, lib, pkgs, ... }:
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
