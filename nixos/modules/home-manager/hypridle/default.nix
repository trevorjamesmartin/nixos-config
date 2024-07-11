{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hypridle;
in {
  options.yoshizl.hypridle.enable = mkEnableOption "enable hypridle config";
  config = mkIf cfg.enable {
    home.file.".config/hypr/hypridle.conf".source = ./hypridle.conf;
  };

}
