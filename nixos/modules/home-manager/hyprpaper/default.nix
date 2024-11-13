{ inputs, lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hyprpaper;
in {

  options.yoshizl.hyprpaper.enable = mkEnableOption "enable hyprpaper";
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
      inputs.hypsi.packages.x86_64-linux.default
    ];
    
  };


