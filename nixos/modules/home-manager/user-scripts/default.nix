{ hm_hq ? "/etc/nixos/hosts/default/home-manager", hm_hostname ? "default", ... }:
{ lib, config, pkgs, ... }:
with lib;
let 
  cfg = config.yoshizl.user-scripts;
in {
  options.yoshizl.user-scripts.enable = mkEnableOption "enable user-scripts";

  config = mkIf cfg.enable {

    home.packages = [

    # (pkgs.writeShellScriptBin "${config.home.username}-local-update" ''
    #   echo "Hello, ${config.home.username}! (ready to update & run home-manager switch...)"
    #   hyprctl dispatch tagwindow +nix
    #   echo "[enter home mangager]"
    #   pushd ~/.config/home-manager
    #   echo "[flake update]"
    #   nix flake update .
    #   echo "[home-manger switch]"
    #   home-manager switch --impure --show-trace
    #   echo "[exit home-manager]"
    #   popd
    #   hyprctl dispatch tagwindow -- -nix
    # '')

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
        sudo nixos-rebuild switch --flake /etc/nixos#${hm_hostname} --show-trace
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
