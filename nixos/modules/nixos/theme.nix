# theme.nix
{ lib, pkgs, ...}:
let
  # edit catppuccin here
  catppuccin_flavor = "frappe";
  catppuccin_accent = "blue";
  catppuccin_kvantum_theme = "Catppuccin-Frappe-Blue";
  # todo: check how we build these names
  catppuccin_name = "catppuccin-${catppuccin_flavor}-${catppuccin_accent}-standard+default";
in
{
  environment.systemPackages = with pkgs; [
    catppuccin
    catppuccin-gtk
    catppuccin-qt5ct
    catppuccin-cursors
    tmuxPlugins.catppuccin
    foot
  ];

  # general settings
  catppuccin = {
    flavor = "${catppuccin_flavor}";
    accent = "${catppuccin_accent}";
  };

  environment.sessionVariables = {
    # I'm setting these environment variables for hyprcursor to use
    XCURSOR_THEME = "catppuccin-${catppuccin_flavor}-${catppuccin_accent}-cursors";
    XCURSOR_SIZE  = 64;
    HYPRCURSOR_SIZE = 64; 
    HYPRCURSOR_THEME = "catppuccin-${catppuccin_flavor}-${catppuccin_accent}-cursors";
    # pretty 
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
  };

}
