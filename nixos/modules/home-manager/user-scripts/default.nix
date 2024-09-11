{ hostName ? "default", ... }:{ lib, osConfig, config, pkgs, ... }:
with lib;
let 
  hm_hq = "/etc/nixos/hosts/${hostName}/home-manager";
  cfg = config.yoshizl.user-scripts;
in {
  options.yoshizl.user-scripts.enable = mkEnableOption "enable user-scripts";

  config = mkIf cfg.enable {

    home.packages = [

      (pkgs.writeShellScriptBin "${config.home.username}-update-flakes" ''
        hyprctl dispatch tagwindow +nix
        echo "[system flake update]"
        sudo nix flake update /etc/nixos
        echo "[home-manager flake update]"
        nix flake update ${hm_hq}
      '')
    
      (pkgs.writeShellScriptBin "${config.home.username}-local-switch" ''
        hyprctl dispatch tagwindow +nix
        echo "[home-manager switch]"
        home-manager -f ${hm_hq}/home.nix switch
        hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "${config.home.username}-system-switch" ''
        hyprctl dispatch tagwindow +nix
        echo "[nixos-rebuild switch]"
        sudo nixos-rebuild switch --flake /etc/nixos#${hostName} --show-trace
        echo "[home-manager switch]"
        home-manager -f ${hm_hq}/home.nix switch
        hyprctl dispatch tagwindow -- -nix
      '')

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

      (pkgs.writeShellScriptBin "infowars" ''
        mpv "https://rumble.com/v523y8c-infowars-network-feed-live-247.html";
      '')
    ];

  };

}
