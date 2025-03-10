{ lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.greeter;
in {

  options.yoshizl.greeter.enable = mkEnableOption "enable greeter settings";
  options.yoshizl.greeter.dark_mode = mkEnableOption "dark mode";

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      #greetd.regreet
      #cage
      xdg-utils
    ];

#    programs.regreet = {
#      enable = true;
#      settings = {
#
#        background = {
#          path = ../../home-manager/hyprlock/lockscreen.jpg;
#          fit = "Cover";
#        };
#        
#        GTK = {
#          application_prefer_dark_theme = cfg.dark_mode;
#          cursor_theme_name = lib.mkForce "macOS-BigSur";
#          font_name = "Cantarell 16";
#          #icon_theme_name = lib.mkForce "Papirus-Dark";
#          theme_name = lib.mkForce "catppuccin-frappe-blue-standard";
#        };
#
#        commands = {
#          reboot = [ "systemctl" "reboot" ];
#          poweroff = [ "systemctl" "poweroff" ];
#        };
#        
#        appearance = {
#          greeting_msg = "Welcome";
#        };
#
#      };
#    };

    services.greetd = {
      enable = true;

      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = "tm";
        };

        #   regreet_session = {
        #  command = "${pkgs.cage}/bin/cage -s -m last -- regreet > /tmp/greetings.log 2>&1";
        #  user = "greeter";
        #};

        default_session = initial_session;
      };
    
    };

  };

}
