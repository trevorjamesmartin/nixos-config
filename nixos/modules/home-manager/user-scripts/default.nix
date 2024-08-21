{lib, config, pkgs, ...}:
with lib;
let cfg = config.yoshizl.user-scripts;
in {
  options.yoshizl.user-scripts.enable = mkEnableOption "enable user-scripts";

  config = mkIf cfg.enable {

    home.packages = [

      (pkgs.writeShellScriptBin "${config.home.username}-local-update" ''
        echo "Hello, ${config.home.username}! (ready to update & run home-manager switch...)"
        hyprctl dispatch tagwindow +nix
        nix flake update ~/.config/home-manager
        home-manager switch --impure
        hyprctl dispatch tagwindow -- -nix
      '')

      (pkgs.writeShellScriptBin "${config.home.username}-system-update" ''
        echo "Hello, ${config.home.username}! (ready to update & run nixos-rebuild switch...)"
        hyprctl dispatch tagwindow +nix
        sudo nix flake update /etc/nixos --impure
        sudo nixos-rebuild switch --flake /etc/nixos#default --show-trace -j 4
        hyprctl dispatch tagwindow -- -nix
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
