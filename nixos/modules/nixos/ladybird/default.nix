{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.ladybird;
in {
  options.yoshizl.ladybird.enable = mkEnableOption "ladybird web browser";

  config = mkIf cfg.enable {

    programs.ladybird.enable = true;

    fonts.enableDefaultPackages = true;

    environment.systemPackages = with pkgs; [
        ladybird
    ];
    environment.sessionVariables = {
      QT_QPA_PLATFORM = lib.mkForce "wayland";
    };
  };

}

