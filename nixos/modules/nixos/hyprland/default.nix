{ pkgs, config, lib, inputs, ... }:
with lib;
let
  cfg = config.yoshizl.hyprland;    
in
{
  options.yoshizl.hyprland.enable = mkEnableOption "Hyprland session w/ kwallet support";
  
  config = mkIf cfg.enable {
      # Enable hyprland
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      programs.hyprlock.enable = true;

      services.hypridle.enable = true;
      
      environment.systemPackages = with pkgs; [
        # QT libs
        libsForQt5.qt5.qtgraphicaleffects
        libsForQt5.qt5.qtsvg
        libsForQt5.qt5ct
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.lightly
        libsForQt5.qt5.qtwayland
        libsForQt5.polkit-kde-agent
        
        kdePackages.qtwayland # qt6
        qt6Packages.qt6ct
        qt6.qtwayland

        # kwalllet & friends
        kdePackages.kwallet
        libsForQt5.kwallet
        kdePackages.kwalletmanager
        libsForQt5.kwalletmanager
        kdePackages.ksshaskpass
        kdePackages.kwallet-pam
        libsForQt5.kwallet-pam

      ];

      services.xserver.displayManager.session = [
        {
          manage = "desktop";
          name = "Hyprland-Session";
          # redirect console output to /tmp/hyprlandSession.log
          start = ''
            ${lib.getExe pkgs.hyprland} > /tmp/hyprlandSession.log 2>&1 &&
            waitPID=$!
          '';
        }
      ];

      environment.sessionVariables = {
        # tells electron apps to prefer wayland
        NIXOS_OZONE_WL = "1";
        GDK_BACKEND = "wayland,x11";
        QT_QPA_PLATFORM = "wayland;xcb";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        DESKTOP_SESSION = "hyprland";

        #QT_QPA_PLATFORMTHEME = "qt5ct";
      };

      # enable wallet support
      security.pam.services.greetd.enableKwallet = true;
      security.pam.services.kwallet = {
        name = "kwallet";
        enableKwallet = true;
      };

  };

}
