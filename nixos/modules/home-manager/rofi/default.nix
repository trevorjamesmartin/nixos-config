{ lib, config, pkgs, ... }:
with lib;
let 
  cfg = config.yoshizl.rofi;
in
{
  options.yoshizl.rofi.enable = mkEnableOption "enable rofi";

  config = mkIf cfg.enable {

    home.packages = with pkgs;[
      rofi-wayland
      rofi-bluetooth

      # use rofi to display available cursor themes
      (pkgs.writeShellScriptBin "cursor-select" ''
        SELECTED=$(find /run/current-system/sw/share/icons -maxdepth 1 -type d| cut -d '/' -f 7|sort |tail -n +2|rofi -dmenu -i -p "Cursor theme")
        if [ -n "$SELECTED" ]; then
            SIZE=$(rofi -dmenu -p "Cursor Size" -theme-str 'listview {lines: 0;}')
            if [ -n "$SIZE" ]; then
                export XCURSOR_THEME="$SELECTED"
                export XCURSOR_SIZE="$SIZE"
                hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE
                # mkdir -p ~/.icons/default
                echo "[Icon Theme]" # > ~/.icons/default/index.theme
                echo "Inherits=$XCURSOR_THEME" #>> ~/.icons/default/index.theme
            fi
        fi
      '')
      # browse for a wallpaper, 
      (pkgs.writeShellScriptBin "wallpaper-select" ''
      PREVIEW=true rofi -mode filebrowser -show filebrowser|xargs hypsi'')
    ];

    home.file.".config/rofi/theme.rasi".source = ./fspmod.rasi;

    home.file.".config/rofi/config.rasi".text = ''
    configuration {
      filebrowser {
        /** Directory the file browser starts in. */
        directory: ".";
        /**
          * Sorting method. Can be set to:
          *   - "name"
          *   - "mtime" (modification time)
          *   - "atime" (access time)
          *   - "ctime" (change time)
          */
        sorting-method: "name";
        directories-first: true;
        show-hidden: false;
        cancel-returns-1: true;

        /* return absolute path to selected file for xargs */
        command: "echo";
      }
    }
    @theme "./theme.rasi"
    '';
  
  };

}
