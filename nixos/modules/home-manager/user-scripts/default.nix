{ lib, osConfig, config, pkgs, ... }:
with lib;
let 
  cfg = config.yoshizl.user-scripts;
in {
  options.yoshizl.user-scripts.enable = mkEnableOption "enable user-scripts";

  config = mkIf cfg.enable {

    home.packages = [

      (pkgs.writeShellScriptBin "${config.home.username}-collect-garbage" ''
        hyprctl dispatch tagwindow +nix
        echo "[garbage collection]"
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "${config.home.username}-optimize" ''
        hyprctl dispatch tagwindow +nix
        echo "[optimize nix store]"
        sudo nix-store --optimize -vvv
        nix-store --optimize -vvv
        hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "alexjones" ''
        mpv "https://rumble.com/v5pawl2-the-alex-jones-network-247-feed.html";
      '')

      (pkgs.writeShellScriptBin "Hypsi-GUI" ''
      export DEBUG=OK
      hypsi -webview
      '')
    ];

  };

}
