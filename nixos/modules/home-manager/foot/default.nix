{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.foot;
in {
  options.yoshizl.foot.enable = mkEnableOption "enable foot config";
  config = mkIf cfg.enable {
    home.packages = [
        pkgs.foot
    ];
    home.file.".config/foot/foot.ini".source = ./foot.ini;
    home.sessionVariables = {
      TERM = "foot";
      TERMINAL = "foot";
    };   
  };
}
