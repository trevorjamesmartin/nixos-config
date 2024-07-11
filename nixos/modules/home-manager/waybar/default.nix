{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.waybar;
in {
  options.yoshizl.waybar.enable = mkEnableOption "enable waybar";

  config = mkIf cfg.enable {

    home.packages = [
        pkgs.waybar
        # display media information in waybar
        pkgs.waybar-mpris
    ];

    home.file.".config/waybar/config.json".source = ./config.json;
    home.file.".config/waybar/style.css".source = ./style.css;
  
  };

}
