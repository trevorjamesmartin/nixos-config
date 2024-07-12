{lib, config, pkgs, ...}:
with lib;
let 
  cfg = config.yoshizl.hyprland;
in 
{
  options.yoshizl.hyprland.enable = mkEnableOption "yoshizl Hyprland rice";

  config = mkIf cfg.enable {
    home.packages = with pkgs;[
      # wayland colorpicker
      hyprpicker
      # Hyprland plugins
      hyprcursor
      hyprpaper
      hyprlock

      # notifications
      dunst
      # power menu
      wlogout
      # wallpaper
      swww

      # menus
      rofi-wayland
      rofi-bluetooth
      
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

      # file explorer
      xfce.thunar
      # thumb nailer
      xfce.tumbler

      # image viewer
      oculante

      # media players
      mpv
      vlc
      
      # monitor
      bottom


      #########
      (pkgs.writeShellScriptBin "external-monitor-check" ''
        if [[ $(wlr-randr --json |jq length) -gt 1 ]] then wlr-randr --output "eDP-1" --off; else wlr-randr --output "eDP-1" --on; fi
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
                keyword decoration:drop_shadow 0;\
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
        if [[ $1 != "" ]]
        then
          primary=$1
        else
          primary=$(wlr-randr --json |jq -r ".[0]| .name");
        fi

        toggled=$(wlr-randr --json |jq ".[]| {name: .name, enabled: .enabled } | if .enabled == false then .name else empty end");

        if [[ $toggled != "" ]] then
          echo $toggled | xargs -I{} wlr-randr --output {} --on;
        else
          wlr-randr --output $primary --off;
        fi
      '')

      (pkgs.writeShellScriptBin "graceful-logout" ''
        HYPRCMDS=$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
        hyprctl --batch "$HYPRCMDS" >> /tmp/hypr/hyprexitwithgrace.log 2>&1
        hyprctl dispatch exit
      '')

      (pkgs.writeShellScriptBin "cursor-select" ''
        SELECTED=$(find /run/current-system/sw/share/icons -maxdepth 1 -type d| cut -d '/' -f 7|sort |tail -n +2|rofi -dmenu -i -p "Cursor theme")
        if [ -n "$SELECTED" ]; then
            THEME="$SELECTED"
            SIZE=$(rofi -dmenu -p "Cursor Size" -theme-str 'listview {lines: 0;}')
            if [ -n "$SIZE" ]; then
                export XCURSOR_THEME="$THEME"
                export XCURSOR_SIZE="$SIZE"
                hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE
                mkdir -p ~/.icons/default
                echo "[Icon Theme]" > ~/.icons/default/index.theme
                echo "Inherits=$XCURSOR_THEME" >> ~/.icons/default/index.theme
            fi
        fi
      '')



    ];

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;

      plugins = [
        #pkgs.hyprlandPlugins.borders-plus-plus
        #pkgs.hyprlandPlugins.hy3
        
        #inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
        pkgs.hyprlandPlugins.hyprbars
        
        #inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
        pkgs.hyprlandPlugins.hyprexpo
        
        #pkgs.hyprlandPlugins.hyprtrails
        #pkgs.hyprlandPlugins.hyprwinwrap
      ];
    
      settings = {
        
        monitor = [
          # position desktop monitors (when plugged in)
          "DP-2,2560x1440,0x0,1"  # left monitor
          "HDMI-A-1,2560x1440,2560x0,1" # right monitor
          ",preferred,auto,1"        # everything else (includes laptop)
          #"eDP-1,1920x1080@60,auto,1" # laptop screen
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
          "swww-daemon &" # wallpaper agent
          "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1" # auth kit
          "hyprlock" # lock screen
          "hypridle" # power management
          "nm-applet --indicator &" # requires pkgs.networkmanagerapplet
          "libinput-gestures &" # gesture support (swipe)
          "dunst" # notifications
        ];

        exec = [
          # check the external monitor situation
          "external-monitor-check"
          # "~/.config/hypr/scripts/external.sh"
          # reload home-manager session variables
          # ". ~/.nix-profile/etc/profile.d/hm-session-vars.sh"
          # waybar
          "pidof waybar && pidof waybar|xargs kill -9 -- ;waybar -c ~/.config/waybar/config.json -s ~/.config/waybar/style.css"
          # conky
          "kill -9 $(pidof conky); sleep 1; conky"

          # set the cursor theme
          "hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE"
        ];

        # Set programs that you use
        "$terminal" = "foot";
        "$fileManager" = "thunar";
        "$browser" = "brave";
        "$menu" = "rofi -show drun -show-icons";

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
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false;
        };

        decoration = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            rounding = 10;

            blur = {
                enabled = true;
                size = 3;
                passes = 1;
            };

            drop_shadow = "yes";
            shadow_range = 4;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1a1a1aee)";
        };

        animations = {
            enabled = "yes";
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
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
            no_gaps_when_only = 1;
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
            
          hyprexpo = {
            columns = 3;
            gap_size = 5;
            bg_col = "rgb(111111)";
            workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1

            enable_gesture = "true"; # laptop touchpad
            gesture_fingers = 3;  # 3 or 4
            gesture_distance = 300; # how far is the "max"
            gesture_positive = true; # positive = swipe down. Negative = swipe up.
          };

          hyprbars = {
            bar_height = 24;
            bar_color = "rgb(48, 52, 70)";
            "col.text" = "rgb(c6d0f5)";
            bar_text_size = 11;
            bar_text_font = "Jetbrains Mono Nerd Font Mono Bold";
            bar_button_padding = 8;
            bar_padding = 10;
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

          "opacity 1.0:override,fullscreen:(1)"

          "opacity 0.9 override 0.9 override,class:^(.*)$"
          
          "opacity 1.0 override 1.0 override,title:^(.*YouTube.*)$"
          "opacity 1.0:override,class:^(gimp)$"
          "opacity 1.0:override,class:^(occulant)$"
          "opacity 0.8:override,class:^(thunar)$"
          "opacity 1.0:override,class:^(mpv)$"
          "opacity 1.0:override,class:^(Kodi)$"
          "minsize 320 240,class:^(mpv)$"

          "tag +music, initialTitle:(Spotify)"    # add dynamic tag `music*` to spotify window
          "tag +music, initialTitle:(Spotify Premium)"    # add dynamic tag `music*` to spotify window

          "suppressevent maximize, class:.*" # You'll probably like this.

          "stayfocused,class:(Rofi)"  # menu
          "forceinput,class:(Rofi)"   #

          "float,class:(pavucontrol)"
          "float,class:(nm-applet)"


          "float,class:(smile)"       # 
          "stayfocused,class:(smile)" # emoji picker
          "forceinput,class:(smile)"  #

          # "rounding 10,class:(smile)" # emoji picker

        ];

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        
        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, F, workspaceopt, allfloat"

          "$mainMod SHIFT, code:49, movetoworkspace, special:neovim"
          "$mainMod, code:49, togglespecialworkspace, neovim"
          # launcher
          #"$mainMod, ESC, exec, nwg-drawer"       

          # emoji picker 🤣
          "$mainMod SHIFT, Equal, exec, smile"

          # color picker
          "$mainMod SHIFT, Minus, exec, hyprpicker -a"
          
          # overview
          "$mainMod, Tab, hyprexpo:expo, toggle"
          # lock screen
          "$mainMod SHIFT, Delete, exec, pidof hyprlock || hyprlock"
          # brightness control
          ",XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # media keys
          ",XF86AudioPrev, exec, playerctl previous"
          ",XF86AudioStop, exec, playerctl stop"
          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioNext, exec, playerctl next"
          
          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

          "$mainMod, Return, exec, $terminal"
          "$mainMod, Q, killactive"
          #"$mainMod, Q, exec, close-active-window"
          "$mainMod, M, exit,"
          "$mainMod, W, exec, $browser"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, T, togglefloating,"
          "$mainMod, D, exec, $menu"
          "$mainMod, P, pseudo," # dwindle
          "$mainMod, J, togglesplit," # dwindle

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          "$mainMod SHIFT, PRINT, exec, grim -g \"$(slurp)\" - | swappy -f -"

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

          #"$mainMod , SPACE, togglefloating,"

          # Example special workspace (scratchpad)
          #bind = $mainMod, S, togglespecialworkspace, magic
          #bind = $mainMod SHIFT, S, movetoworkspace, special:magic

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          
          # game mode is super fun
          "$mainMod, F1, exec, toggle-gamemode"
          
          # power menu
          #"$mainMod SHIFT, Q, exec, rofi -show p -modi p:rofi-power-menu"
          "$mainMod SHIFT, Q, exec, wlogout"

          # display key
          "$mainMod, 235, exec, toggle-display"
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
