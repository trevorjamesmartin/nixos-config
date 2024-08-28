{lib, config, pkgs, ...}:
with lib;
let 
  cfg = config.yoshizl.theme;
  # edit catppuccin here
  catppuccin_flavor = "frappe";
  catppuccin_accent = "blue";
  #catppuccin_kvantum_theme = "Catppuccin-Frappe-Blue";
  # todo: check how we build these names
  catppuccin_name = "catppuccin-${catppuccin_flavor}-${catppuccin_accent}-standard+default";
  cursor_theme = "macOS-BigSur";
  cursor_size = 32;
in {
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
      flavor = "${catppuccin_flavor}";
      accent = "${catppuccin_accent}";
    };

    environment.sessionVariables = {
      # I'm setting these environment variables for hyprcursor to use
      XCURSOR_THEME = cursor_theme;
      
      XCURSOR_SIZE  = cursor_size;
      HYPRCURSOR_SIZE = cursor_size; 
      
      HYPRCURSOR_THEME = cursor_theme;

      # pretty 
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    };

    programs.dconf = {
      enable = true;
      profiles = {
        user.databases = [{
          settings = with lib.gvariant; {
            # to remove titlebar buttons from Gnome apps:
            "org/gnome/desktop/wm/preferences.button-layout".value = "";
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
