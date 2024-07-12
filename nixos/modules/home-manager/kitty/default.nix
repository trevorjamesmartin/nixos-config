{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.kitty;
in {
  options.yoshizl.kitty.enable = mkEnableOption "enable kitty";
  config = mkIf cfg.enable {
    home.packages = [
        pkgs.kitty
    ];
    home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
    home.sessionVariables = {
      TERM = "kitty";
      TERMINAL = "kitty";
    };
  };
}
