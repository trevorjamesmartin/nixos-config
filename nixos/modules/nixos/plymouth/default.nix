{lib, config, pkgs, ...}:
with lib; 
let 
  cfg = config.yoshizl.plymouth;
  themeName = cfg.theme;
in {
  options.yoshizl.plymouth.enable = mkEnableOption "enable plymouth theme";

  config = mkIf cfg.enable {
    
    nixpkgs.overlays = [
      (final: prev: {
        adi1090x-plymouth-themes = prev.adi1090x-plymouth-themes.overrideAttrs(oldAttrs: rec {
          selected_themes = [ "hexa_retro" "owl" ];
        });
      })
    ];

    boot.plymouth = {
      enable = true;
      theme = lib.mkDefault "owl";
      themePackages = [
        pkgs.adi1090x-plymouth-themes 
      ];
    };
  };
}
