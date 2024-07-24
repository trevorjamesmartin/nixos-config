{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hyprpaper;
in {
  options.yoshizl.hyprpaper.enable = mkEnableOption "enable hyprpaper";

  config = mkIf cfg.enable {

    home.packages = [
      
      pkgs.hyprpaper
      
      (pkgs.writeShellScriptBin "set-active-wallpaper" ''
        if [[ -f $1 ]]
        then
          nextImage=$1;
          monitor=$(hyprctl activeworkspace -j|jq '.monitor'|xargs);
          prevImage=$(hyprctl hyprpaper listactive |cut -d'=' -f 2);
          hyprctl hyprpaper preload $nextImage;
          hyprctl hyprpaper wallpaper $monitor,$nextImage;
          [[ $prevImage != $nextImage ]] && (
            hyprctl hyprpaper unload $prevImage;
            [[ -f /tmp/hyprpapertemp ]] && rm /tmp/hyprpapertemp;
            ~/.config/hypr/hyprpaperPlanes.sh
            );
        fi
      '')
    ];

    home.file.".config/hypr/hyprpaperPlanes.sh".source = ./foo.sh;
    
  };

}
