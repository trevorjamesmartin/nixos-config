{ lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hyprpaper;
in {
  options.yoshizl.hyprpaper.enable = mkEnableOption "enable hyprpaper";

  config = mkIf cfg.enable {

    nixpkgs.overlays = [
       (self: super: {
        hypsi = pkgs.callPackage ./hypsi.nix {};
       })
    ];

    home.packages = with pkgs; [
      hyprpaper
      hypsi
    ];
    
  };

}
