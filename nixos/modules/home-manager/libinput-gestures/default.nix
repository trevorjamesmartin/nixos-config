{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.libinput-gestures;
in {
  options.yoshizl.libinput-gestures.enable = mkEnableOption "enable libinput-gestures";

  config = mkIf cfg.enable {
    
    home.packages = with pkgs; [
      # trackpad
      libinput
      # extended trackpad support
      libinput-gestures
    ];

    home.file.".config/libinput-gestures.conf".source = ./libinput-gestures.conf;
  
  };

}
