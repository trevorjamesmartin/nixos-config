{lib, config, pkgs, ...}:
with lib;
let 
  cfg = config.yoshizl.hyprland;
in 
{
  imports = [
    ../hyprlock
    ../hypridle
    ../hyprpaper
    ../rofi
  ];

  options.yoshizl = {
    hyprland.enable = mkEnableOption "yoshizl Hyprland rice";

    hyprland.hyprbars = mkEnableOption "- include hyprbars"; # configured here
    hyprland.hyprexpo = mkEnableOption "- include hyprexpo"; # configured here

    # configured elsewhere ...
    hyprland.hyprlock = mkEnableOption "- include hyprlock";
    hyprland.hypridle = mkEnableOption "- include hypridle";
    hyprland.hyprpaper = mkEnableOption "- include hyprpaper";
    hyprland.swww = mkEnableOption "- swww for wallpaper";

    hyprland.rofi = mkEnableOption "- w/ rofi";

  };

  config = mkIf cfg.enable {

    yoshizl = {
      # try to keep the hypr fam together
      hyprlock.enable = cfg.hyprlock;
      hypridle.enable = cfg.hypridle;
      hyprpaper.enable = cfg.hyprpaper;

      rofi.enable = cfg.rofi;
    };

    nixpkgs.overlays = [
      # allow mpv to be controlled by playerctl
      (self: super: {
        mpv = super.mpv.override {
          scripts = [ self.mpvScripts.mpris self.mpvScripts.uosc ];
        };
      })
      # change the 'PAUSE' icon to something in my font set
      (self: super: {
        waybar-mpris = super.waybar-mpris.overrideAttrs (oldAttrs: {
          patches = [ ../../../patches/waybar-mpris.patch ];
        });
      })

    ];

    home.packages = with pkgs;[
      (mkIf cfg.swww
        swww
      )
      # wayland colorpicker
      hyprpicker
      # Hyprland plugins
      hyprcursor
      
      (mkIf cfg.hyprpaper
        hyprpaper)

      (mkIf cfg.hyprlock
        hyprlock)

      libnotify # notify-send
      dunst     # notifications

      # power menu
      wlogout
      
      # wayland xrandr
      wlr-randr

      # screenshot tool 
      grim
      # select util
      slurp
      # wayland clipboard
      wl-clipboard
      # x11 clipboard
      xclip
      
      # display layout
      wdisplays

      # brightness %
      brightnessctl

      # image viewer
      oculante

      # media players
      mpv
      vlc

      # emoji picker
      smile

      # A Wayland native snapshot editing tool, inspired by Snappy on macOS
      swappy
      
      # monitor
      bottom

      #########
      (pkgs.writeShellScriptBin "external-monitor-check" ''
      
      if [[ $1 != "" ]] ; then
        mon=$1;
      else
        mon="eDP-1";
      fi

      if [[ $(hyprctl monitors all -j|jq 'length') > 1 ]] ; then
        hyprctl keyword monitor "$mon, disable";
      else
        hyprctl keyword monitor "$mon, enable";
      fi

      '')

      (pkgs.writeShellScriptBin "toggle-gamemode" ''
        #!/usr/bin/env sh
        HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
        if [ "$HYPRGAMEMODE" = 1 ] ; then
            # remove the bar
            ps -ea |grep waybar|awk '{print $1}' | xargs kill -9 --
            # remove the dock
            ps -ea |grep nwg-dock |awk '{print $1}'|xargs kill -9
            # reclaim space
            hyprctl --batch "\
                keyword animations:enabled 0;\
                keyword decoration:blur:enabled 0;\
                keyword general:gaps_in 0;\
                keyword general:gaps_out 0;\
                keyword general:border_size 1;\
                keyword decoration:rounding 0"
            exit
        fi
        hyprctl reload
      '')

      (pkgs.writeShellScriptBin "toggle-display" ''

        if [[ $1 != "" ]]; then
          mon=$1; 
        else 
          mon=$(hyprctl monitors all -j|jq '.[0]|.name'|xargs);
        fi
        echo "toggle display: $primary";
        toggled=$(hyprctl monitors all -j |jq '.[]| {name: .name, off: .disabled}|if .off then .name else empty end'|grep $mon|xargs);
        if [[ $toggled == $mon ]] then
          hyprctl keyword monitor "$mon, enable";
        else
          hyprctl keyword monitor "$mon, disable";
        fi
      '')

      (pkgs.writeShellScriptBin "graceful-logout" ''
        HYPRCMDS=$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
        hyprctl --batch "$HYPRCMDS" >> /tmp/hypr/hyprexitwithgrace.log 2>&1
        hyprctl dispatch exit
      '')
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;

      plugins = [
        (mkIf config.yoshizl.hyprland.hyprexpo
          pkgs.hyprlandPlugins.hyprexpo)

        (mkIf config.yoshizl.hyprland.hyprbars
          pkgs.hyprlandPlugins.hyprbars)
      ];

      settings = {
        
        monitor = [
          # position desktop monitors (when plugged in)
          "eDP-1,preferred,auto,auto" # laptop screen
          "DP-2,2560x1440,1920x0,1"  # left monitor
          "HDMI-A-1,2560x1440,4480x0,1" # right monitor
          #",preferred,auto,1"        # everything else (includes laptop)
        ];

        xwayland = {
           force_zero_scaling = true;
        };

        workspace = [
          "special:neovim, on-created-empty:$terminal nvim"
          "special:monitor, on-created-empty:$terminal btm"
          "special:tunes, on-created-empty:spotify"

          # left = odd, right = even
          "1, monitor:DP-2"
          "2, monitor:HDMI-A-1" 
          "3, monitor:DP-2"
          "4, monitor:HDMI-A-1"
          "5, monitor:DP-2"
          "6, monitor:HDMI-A-1"
          "7, monitor:DP-2"
          "8, monitor:HDMI-A-1"
          "9, monitor:DP-2"
          "10, monitor:HDMI-A-1"
        ];

        exec-once = [
          # load the essentials
          (mkIf cfg.swww
            "swww-daemon &")

          (mkIf cfg.hyprpaper
            "hyprpaper &")

          "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1" # auth kit

        # (mkIf cfg.hyprlock
        #   "hyprlock") # lock screen when hyprland starts
          "hypridle" # power management
          "nm-applet --indicator &" # requires pkgs.networkmanagerapplet
          "libinput-gestures &" # gesture support (swipe)
          "dunst" # notifications

        ];

        exec = [
          # waybar
          "pidof waybar && pidof waybar|xargs kill -9 -- ;waybar -c ~/.config/waybar/config.json -s ~/.config/waybar/style.css"
          # conky
          "kill -9 $(pidof conky); sleep 1; conky"
          
          # set the cursor theme
          "hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE"
          
          # check the external monitor situation
          "sleep 3 && external-monitor-check"
        ];

        # Set programs that you use
        "$terminal" = "foot";
        "$fileManager" = "thunar";
        "$browser" = "brave";
        "$menu" = "rofi -show drun -show-icons";
        "$menu2" = "rofi -modes combi,window -show combi -combi-modes run,drun";
        input = {
          follow_mouse = 1;

          touchpad = {
            natural_scroll = "yes";
            clickfinger_behavior = 1; # two finger rightclick, three finger middleclick
          };
          
          accel_profile = "adaptive";
          
          force_no_accel = 0;
          
          kb_layout = "us";

        };

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          gaps_in = 1;
          gaps_out = 0;
          border_size = 1;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
        };

        decoration = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            rounding = 4;

            blur = {
                enabled = true;
                size = 3;
                passes = 1;
            };
        };

        animations = {
            enabled = "yes";
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            #bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, default"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
        };

        dwindle = {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = "yes"; # you probably want this
        };

        master = {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        };

        gestures = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            workspace_swipe = "off";
        };

        misc = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            # force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = true;
            disable_splash_rendering = true; # disable the anime mascot wallpapers
        };


        plugin = {
            
          hyprexpo = mkIf config.yoshizl.hyprland.hyprexpo {
            columns = 3;
            gap_size = 5;
            bg_col = "rgb(111111)";
            workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1

            enable_gesture = "true"; # laptop touchpad
            gesture_fingers = 3;  # 3 or 4
            gesture_distance = 300; # how far is the "max"
            gesture_positive = true; # positive = swipe down. Negative = swipe up.
          };
        
          hyprbars = mkIf config.yoshizl.hyprland.hyprbars {
            bar_height = 20;
            bar_color = "rgb(48, 52, 70)";
            "col.text" = "rgb(c6d0f5)";
            bar_text_size = 10;
            bar_text_font = "monospace";
            bar_button_padding = 6;
            bar_padding = 6;
            bar_part_of_window = true;
            
            #bar_precedence_over_border = true; # flicker problem 
            
            "hyprbars-button" = [
              # color, size, icon, command
              "rgb(e78284), 14, , hyprctl dispatch killactive"
              "rgb(e5c890), 14, , hyprctl dispatch fullscreen 1"
              "rgb(a6d189), 14, , hyprctl dispatch togglefloating"
              #"0, 18, , hyprctl dispatch killactive"
              #"0, 18, , hyprctl dispatch fullscreen 2"
              #"0, 18, , hyprctl dispatch togglefloating"
            ];
        };

        };

        windowrule = [
          "center 1,^(*)$" # all floaters start centered
          "animation popin,^(smile)$" 
          "move 50% 50%,^(nm-applet)$"
          "animation popin,^(nm-applet)$"
          "move 100 100,^(pavucontrol)$"
          "animation popin,^(pavucontrol)$"
          "float,^(thunar)$"

          "center,floating:1"
        ];


        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        windowrulev2 = [
          #"maxsize 1400 900,floating:1"

          "idleinhibit always,initialTitle:^(.*Spotify.*)$"
          
          "idleinhibit always,tag:nix"

          "idleinhibit always,fullscreen:true"

          "opacity 1.0:override,fullscreen:(1)"
          "opacity 0.9 override 0.9 override,class:^(.*)$"

          "opacity 1.0:override,initialClass:^(brave-browser)$"
          "opacity 1.0 override 1.0 override,title:^(.*YouTube.*)$"
          "opacity 1.0:override,class:^(gimp)$"
          "opacity 1.0:override,class:^(occulant)$"
          "opacity 1.0:override,class:^(mpv)$"
          "opacity 1.0:override,class:^(Kodi)$"
          "opacity 1.0:override,initialClass:^(retroarch)$"

          "minsize 320 240,class:^(mpv)$"

          "tag +music, initialTitle:(Spotify)"    # add dynamic tag `music*` to spotify window
          "tag +music, initialTitle:(Spotify Premium)"    # add dynamic tag `music*` to spotify window

          "suppressevent maximize, class:.*" # You'll probably like this.

          "stayfocused,class:(Rofi)"  # menu

          "float,class:(pavucontrol)" # pulse audio control
          "float,class:(nm-applet)"   # network manager applet
          
          "float,class:(hypsi)" # wallpaper history
          "size 1305 435,class:(hypsi)" # (two monitors)

          "float,class:it.mijorus.smile"       # emoji picker
          "stayfocused,class:it.mijorus.smile" # 
          "decorate off,class:it.mijorus.smile"#

        ];

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        
        "$mainMod" = "SUPER";

        bind = [
          "CONTROL ALT, DELETE, exec, hyprctl reload"

          "$mainMod, F, workspaceopt, allfloat"

          "$mainMod SHIFT, code:49, movetoworkspace, special:neovim"
          "$mainMod, code:49, togglespecialworkspace, neovim"
          # launcher
          #"$mainMod, ESC, exec, nwg-drawer"       
          "$mainMod SHIFT, W, exec, Hypsi-GUI"

          # emoji picker 🤣
          "$mainMod SHIFT, Equal, exec, smile"

          # color picker
          "$mainMod SHIFT, Minus, exec, hyprpicker -a"
          
          # overview
          (mkIf cfg.hyprexpo
          "$mainMod, Tab, hyprexpo:expo, toggle")

          # lock screen
          "$mainMod SHIFT, Delete, exec, wlogout"
          # brightness control
          ",XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # media keys
          ",XF86AudioPrev, exec, playerctl previous"
          ",XF86AudioStop, exec, playerctl stop"
          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioNext, exec, playerctl next"

          ",XF86LaunchA, exec, $menu"  # Apple Magic Keyboard f3 
          ",XF86MenuKB, exec, wlogout" # Apple Magic Keyboard power/fprint
          
          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

          "$mainMod, Return, exec, $terminal"
          "$mainMod, Q, killactive"
          #"$mainMod, Q, exec, close-active-window"
          "$mainMod, M, exit,"
          "$mainMod, W, exec, $browser"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, T, togglefloating,"
          "$mainMod, D, exec, $menu"
          "$mainMod SHIFT, D, exec, $menu2"
          "$mainMod, P, pseudo," # dwindle
          "$mainMod, J, togglesplit," # dwindle

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          
          "$mainMod SHIFT, SPACE, swapsplit"
          #"$mainMod SHIFT, right, movefocus, r"
          #"$mainMod SHIFT, up, movefocus, u"
          #"$mainMod SHIFT, down, movefocus, d"

          "$mainMod SHIFT, PRINT, exec, grim -g \"$(slurp)\" - | swappy -f -"
          "$mainMod CONTROL , KP_INSERT, exec, grim -g \"$(slurp)\" - | swappy -f -"

          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          "$mainMod, KP_End, workspace, 1"
          "$mainMod, KP_Down, workspace, 2"
          "$mainMod, KP_Next, workspace, 3"
          "$mainMod, KP_Left, workspace, 4"
          "$mainMod, KP_Begin, workspace, 5"
          "$mainMod, KP_Right, workspace, 6"
          "$mainMod, KP_Home, workspace, 7"
          "$mainMod, KP_Up, workspace, 8"
          "$mainMod, KP_Prior, workspace, 9"
          "$mainMod, KP_Insert, workspace, 10"


          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          "$mainMod SHIFT, KP_End, movetoworkspace, 1"
          "$mainMod SHIFT, KP_Down, movetoworkspace, 2"
          "$mainMod SHIFT, KP_Next, movetoworkspace, 3"
          "$mainMod SHIFT, KP_Left, movetoworkspace, 4"
          "$mainMod SHIFT, KP_Begin, movetoworkspace, 5"
          "$mainMod SHIFT, KP_Right, movetoworkspace, 6"
          "$mainMod SHIFT, KP_Home, movetoworkspace, 7"
          "$mainMod SHIFT, KP_Up, movetoworkspace, 8"
          "$mainMod SHIFT, KP_Prior, movetoworkspace, 9"
          "$mainMod SHIFT, KP_Insert, movetoworkspace, 10"

          #"$mainMod , SPACE, togglefloating,"

          # Example special workspace (scratchpad)
          #bind = $mainMod, S, togglespecialworkspace, magic
          #bind = $mainMod SHIFT, S, movetoworkspace, special:magic

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          
          # game mode is super fun
          "$mainMod, F1, exec, toggle-gamemode"
          # toggle the internal display 
          ",XF86Messenger, exec, toggle-display" # laptop keyboard, fn+F9 (external display key)

          "$mainMod, XF86LaunchA, exec, $(cd ~/Pictures/;wallpaper-select)"  # Apple Magic Keyboard f3 
          # power menu
          "$mainMod SHIFT, Q, exec, wlogout"
        ];

        bindl = [
          ",switch:on:[1a50230],exec,hyprctl keyword monitor \"eDP-1, disable\""
          ",switch:off:[1a50230],exec,hyprctl keyword monitor \"eDP-1, 1920x1080, 0x0, 1\""
        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        bindel= [
          ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ];

      };
    };

  };
}
