{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.foot;
in {
  options.yoshizl.foot.enable = mkEnableOption "enable foot config";
  config = mkIf cfg.enable {
    home = {        
      packages = [ pkgs.foot ];

      sessionVariables = {
        TERM = "foot";
        TERMINAL = "foot";
      };

      file.".config/foot/foot.ini".source = (pkgs.formats.iniWithGlobalSection {}).generate "foot.ini" {
        globalSection = {
          term="xterm-256color";
          font="DejaVu Sans Mono:size=12";
          dpi-aware="yes";
        };

        sections = {
          
          colors = {
            foreground="dddddd";
            background="000000";
            regular0="45475a";
            regular1="f38ba8";
            regular2="a6e3a1";
            regular3="f9e2af";
            regular4="89b4fa";
            regular5="f5c2e7";
            regular6="94e2d5";
            regular7="bac2de";
            bright0="585b70";
            bright1="f38ba8";
            bright2="a6e3a1";
            bright3="f9e2af";
            bright4="89b4fa";
            bright5="f5c2e7";
            bright6="94e2d5";
            bright7="a6adc8";
            selection-foreground="cdd6f4";
            selection-background="414356";
            search-box-no-match="11111b f38ba8";
            search-box-match="cdd6f4 313244";
            jump-labels="11111b fab387";
            urls="89b4fa";
          }; # colors

        }; # sections

      }; # file ... foot.ini

    }; # home
  
  }; # config

}

