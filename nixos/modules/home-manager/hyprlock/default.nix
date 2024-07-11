{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hyprlock;
in {
  options.yoshizl.hyprlock.enable = mkEnableOption "enable hyprlock";
  config = mkIf cfg.enable {
    home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
    home.file.".config/hypr/lockscreen.jpg".source = ./lockscreen.jpg;
  };
}
