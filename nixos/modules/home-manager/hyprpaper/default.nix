{ lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hyprpaper;
in {
  options.yoshizl.hyprpaper.enable = mkEnableOption "enable hyprpaper";

  config = mkIf cfg.enable {

    nixpkgs.overlays = [
       (self: super: {
        hyprPaperPlanes = pkgs.callPackage ./hyprpaperplanes.nix {};
       })
    ];

    home.packages = with pkgs; [
      hyprpaper
      hyprPaperPlanes
    ];
    
  };

}
