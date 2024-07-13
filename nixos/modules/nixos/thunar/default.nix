{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.thunar;
in {
  options.yoshizl.thunar.enable = mkEnableOption "enable Thunar";

  config = mkIf cfg.enable {

    nixpkgs.overlays = [
      #   'eliminate the errant menu entry', 
      # see https://forum.xfce.org/viewtopic.php?pid=48958#p48958
      (final: prev: {
        thunar = prev.xfce.thunar.overrideAttrs(oldAttrs: rec {
          postFixup = ''
             rm $out/lib/thunarx-3/thunar-wallpaper-plugin.so 
             rm $out/lib/thunarx-3/thunar-wallpaper-plugin.la 
          '';
        });
      })
    ];
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
    environment.systemPackages = with pkgs; [
      thunar # for the overlay to take effect, thunar has to be listed
      # thumb nailer
      pkgs.xfce.tumbler
    ];

    services.gvfs.enable = true; # mount, trash and other functionality
    services.tumbler.enable = true; # thumbnail support
 
  };
}
