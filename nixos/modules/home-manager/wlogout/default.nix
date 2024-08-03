{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.wlogout;
in {
  options.yoshizl.wlogout.enable = mkEnableOption "enable wlogout";

  config = mkIf cfg.enable {

    home.packages = [
        pkgs.wlogout
    ];

    home.file.".config/wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "loginctl lock-session",
        "text" : "Lock",
        "keybind" : "l"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "Hibernate",
        "keybind" : "h"
    }
    {
        "label" : "logout",
        "action" : "loginctl terminate-user $USER",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "s"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "u"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
    '';


    home.file.".config/wlogout/style.css".text = ''
    * {
            background-image: none;
            box-shadow: none;
    }

    window {
            background-color: rgba(12, 12, 12, 0.9);
    }

    button {
        border-radius: 0;
        border-color: black;
            text-decoration-color: #FFFFFF;
        color: #FFFFFF;
            background-color: #1E1E1E;
            border-style: solid;
            border-width: 1px;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 25%;
    }

    button:focus, button:active, button:hover {
            background-color: #3700B3;
            outline-style: none;
    }

    #lock {
        background-image: image(url("${pkgs.wlogout.outPath}/share/wlogout/icons/lock.png"), url("/usr/local/share/wlogout/icons/lock.png"));
    }

    #logout {
        background-image: image(url("${pkgs.wlogout.outPath}/share/wlogout/icons/logout.png"), url("/usr/local/share/wlogout/icons/logout.png"));
    }

    #suspend {
        background-image: image(url("${pkgs.wlogout.outPath}/share/wlogout/icons/suspend.png"), url("/usr/local/share/wlogout/icons/suspend.png"));
    }

    #hibernate {
        background-image: image(url("${pkgs.wlogout.outPath}/share/wlogout/icons/hibernate.png"), url("/usr/local/share/wlogout/icons/hibernate.png"));
    }

    #shutdown {
        background-image: image(url("${pkgs.wlogout.outPath}/share/wlogout/icons/shutdown.png"), url("/usr/local/share/wlogout/icons/shutdown.png"));
    }

    #reboot {
        background-image: image(url("${pkgs.wlogout.outPath}/share/wlogout/icons/reboot.png"), url("/usr/local/share/wlogout/icons/reboot.png"));
    }

    '';
  
  };

}
