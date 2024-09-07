{lib, config, pkgs, ...}:
with lib; 
let 
  cfg = config.yoshizl.gaming;
in {
  options.yoshizl.gaming.enable = mkEnableOption "play some video games";

  config = mkIf cfg.enable {
    # enable opengl options that help with gaming
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };


    environment.systemPackages = with pkgs; [
      # games
      steam
      steam-run
      mangohud
      protonup
      lutris
      heroic
      mesa
      mesa-demos
      libdrm
      libGL.dev

      retroarchFull
      retroarch-assets
      retroarch-joypad-autoconfig
    ];

    programs.gamemode.enable = true;
    
    programs.steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
      };
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATH =
        "/home/tm/.steam/root/compatibilitytools.d";
    };

  };
}
