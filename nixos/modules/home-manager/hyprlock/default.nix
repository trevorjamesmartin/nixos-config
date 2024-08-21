{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.hyprlock;
in {
  options.yoshizl.hyprlock.enable = mkEnableOption "enable hyprlock";
  config = mkIf cfg.enable {
    home.file.".config/hypr/hyprlock.conf".text = ''
    background {
        path = ~/.config/hypr/lockscreen.jpg
        blur_passes = 1 
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
    }

    general {
        no_fade_in = false
    }

    input-field {
        size = 300, 42
        outline_thickness = 3
        rounding = 12
        outer_color = rgb(665c54)
        inner_color = rgb(3c3836)
        font_color = rgb(ebdbb2)
        check_color = rgb(d79921)
        fail_color = rgb(cc241d)
        fade_on_empty = false
        placeholder_text =
        fail_text = ☠☠☠☠☠☠☠☠☠☠☠☠☠☠
    }

    label {
        text = cmd[update:1000]date +"%I:%M %p"
        color = rgb(ebdbb2)
        font_size = 64 
        font_family = JetBrains Mono Nerd Font Mono Semibold
        position = 0, 60
        halign = center
        valign = center
    }
    '';

    home.file.".config/hypr/lockscreen.jpg".source = ./lockscreen.jpg;
  };
}
