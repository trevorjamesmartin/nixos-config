{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.waybar;
in {
  options.yoshizl.waybar.enable = mkEnableOption "enable waybar";

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
        waybar
        # display media information in waybar
        waybar-mpris

        # weather for waybar
        wttrbar

      #cava # for waybar module

    ];

    home.file.".config/waybar/config.json".source = ./config.json;
    home.file.".config/waybar/style.css".source = ./style.css;
  
  };

}
