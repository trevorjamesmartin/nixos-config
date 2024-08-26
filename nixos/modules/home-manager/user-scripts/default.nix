{lib, config, pkgs, ...}:
with lib;
let 
  cfg = config.yoshizl.user-scripts;
  hm_hq = "/etc/nixos/hosts/default/home-manager";
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
        sudo nix flake update /etc/nixos
        nix flake update ${hm_hq}
      '')
    
      (pkgs.writeShellScriptBin "${config.home.username}-local-switch" ''
        hyprctl dispatch tagwindow +nix
        home-manager -f ${hm_hq}/home.nix switch
        hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "${config.home.username}-system-switch" ''
        echo "Hello, ${config.home.username}! (ready to run nixos-rebuild switch...)"
        hyprctl dispatch tagwindow +nix
        sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace
        #hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "${config.home.username}-collect-garbage" ''
        hyprctl dispatch tagwindow +nix
        echo "Hello, ${config.home.username}! (ready to collect the garbage)"
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "${config.home.username}-optimize" ''
        hyprctl dispatch tagwindow +nix
        echo "Hello, ${config.home.username}! (ready to optimize the Nix store)"
        sudo nix-store --optimize -vvv
        nix-store --optimize -vvv
        hyprctl dispatch tagwindow -- -nix
      '')

    ];

  };

}
