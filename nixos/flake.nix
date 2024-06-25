{
  description = "Nixos configuration with flakes";
  
  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs-stable.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/24.05";
    
    catppuccin.url = "github:catppuccin/nix";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs = {
      self,
      nixos-hardware, 
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-stable,
      hyprland, hyprland-plugins,
      home-manager,
      catppuccin,
      ...
    }@inputs: let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules = {
      # ...
        gnome = { pkgs, ... }: {
          config = {
            #services.xserver.enable = false;
            #services.xserver.displayManager.gdm.enable = false;
            services.xserver.desktopManager.gnome.enable = true;
            environment.gnome.excludePackages = (with pkgs; [
              gnome-photos
              gnome-tour
            ]) ++ (with pkgs.gnome; [
              seahorse # gnome key ring management
              cheese # webcam tool
              gnome-music
              # gedit # text editor
              epiphany # web browser
              geary # email reader
              gnome-characters
              tali # poker game
              iagno # go game
              hitori # sudoku game
              atomix # puzzle game
              yelp # Help view
              gnome-contacts
              gnome-initial-setup
            ]);
            
            programs.dconf.enable = true;
            
            environment.systemPackages = with pkgs; [ gnome.gnome-tweaks ];
          }; # config
        }; #gnome
      };
    
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };

          modules = with self.nixosModules; [ 

            nixos-hardware.nixosModules.lenovo-thinkpad-t14s
            
            catppuccin.nixosModules.catppuccin
            ./hosts/default/configuration.nix

            inputs.home-manager.nixosModules.default
            #inputs.home-manager.nixosModules.home-manager
	  
	  ];
        };

      };

    };
}
