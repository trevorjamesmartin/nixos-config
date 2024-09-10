{lib, config, pkgs, ...}:
with lib;
let 
  cfg = config.yoshizl.theme;
  # edit catppuccin here
  catppuccin_flavor = "frappe";
  catppuccin_accent = "blue";
  catppuccin_dpi    = "standard"; # "xhdpi" "hdpi" "standard"; 
  catppuccin_kvantum_theme = "Catppuccin-Frappe-Blue";
  cursor_theme = "macOS";
  cursor_size = "32";
  gtk_theme="catppuccin-${catppuccin_flavor}-${catppuccin_accent}-${catppuccin_dpi}";
  gtk-icon_theme="Papirus";
in 
  {
  options.yoshizl.theme.enable = mkEnableOption "enable system theme";

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      catppuccin
      catppuccin-gtk
      catppuccin-qt5ct
      apple-cursor
      whitesur-gtk-theme
      tmuxPlugins.catppuccin
      #catppuccin-cursors.frappeBlue   
    ];

    qt.platformTheme = "qt5ct";
    qt.style = "kvantum";
    # general settings
    catppuccin = {
      enable = true;
      flavor = "${catppuccin_flavor}";
      accent = "${catppuccin_accent}";
    };

    environment.sessionVariables = {
      # I'm setting these environment variables for hyprcursor to use
      XCURSOR_THEME = cursor_theme;
      
      XCURSOR_SIZE  = toInt cursor_size;
      HYPRCURSOR_SIZE = toInt cursor_size; 
      
      HYPRCURSOR_THEME = cursor_theme;

      GTK_THEME="${gtk_theme}";

      # pretty 
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    };


    # /etc/xdg/
    environment.etc = {
      "xdg/Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
        General.theme = "${catppuccin_kvantum_theme}";
      };
      
      "xdg/gtk-4.0".source = "${pkgs.catppuccin-gtk}/share/themes/${gtk_theme}/gtk-4.0";

      #"xdg/gtk-3.0".source = "${pkgs.catppuccin-gtk}/share/themes/${gtk-theme}/gtk-3.0";
      "xdg/gtk-3.0/settings.ini" = {
        text = ''
        [Settings]
        gtk-icon-theme-name=${gtk-icon_theme}
        gtk-theme-name=${gtk_theme}
        gtk-cursor-theme-name=${cursor_theme}
        gtk-cursor-theme-size=${cursor_size}
        '';
        mode = "444";
      };

      # qt 4/5 global theme
      "xdg/Trolltech.conf" = {
        text = ''
        [Qt]
        style=Kvantum
        '';
        mode = "444";
      };
    };

    programs.dconf = {
      enable = true;
      profiles = {
        user.databases = [{
          settings = with lib.gvariant; {
            # to remove titlebar buttons from Gnome apps:
            "org/gnome/desktop/wm/preferences.button-layout".value = "";
            "org/gnome/desktop/interface.scaling-factor".value = "0";
          };
        }];
      };
    };
    
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "joypixels"
      ];
    nixpkgs.config.joypixels.acceptLicense = true;

    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        #noto-fonts-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
        gyre-fonts
        powerline-fonts
        powerline-symbols
        xkcd-font
        udev-gothic-nf
        nerdfonts
        font-awesome
        helvetica-neue-lt-std
        joypixels
      ];

      fontconfig = {
        enable = true;
        localConf = ''
          <!-- use a less horrible font substition for pdfs such as https://www.bkent.net/Doc/mdarchiv.pdf -->
          <match target="pattern">
            <test qual="any" name="family"><string>NewCenturySchlbk</string></test>
            <edit name="family" mode="assign" binding="same"><string>TeX Gyre Schola</string></edit>
          </match>
        '';
        defaultFonts = {
          serif = [  "Liberation Serif" ];
          sansSerif = [ "Ubuntu" ];
          monospace = [ "Ubuntu Mono" ];
        };
      };

    };

  };
}
