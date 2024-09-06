{lib, config, pkgs, ...}:
with lib;
let 
  cfg = config.yoshizl.conky;
in {
  options.yoshizl.conky.enable = mkEnableOption "enable conky";

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.conky
    ];

    home.file.".config/conky/conky.conf".source = ./conky.lua;
    home.file.".config/conky/conky-draw_bg.lua".source = ./conky-draw_bg.lua;

  };

}
