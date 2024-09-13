{
  description = "Nixos + Home-Manager, configuration with flakes";

  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixpkgs-release.url = "github:nixos/nixpkgs/24.05";
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    catppuccin.url = "github:catppuccin/nix";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hyprpaper.url = "github:hyprwm/hyprpaper";
    
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs @ {
      self,
      nixos-hardware, 
      nixpkgs,
      hyprland,
      home-manager,
      catppuccin,
      ...
  }:
  let
    hostname="desktop";
  in
  {
      homeConfigurations."tm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ 
          inputs.hyprland.homeManagerModules.default
          inputs.catppuccin.homeManagerModules.catppuccin
        ];
      };
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            catppuccin.nixosModules.catppuccin
            ./hosts/${hostname}/configuration.nix
            inputs.home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = false; # setting this to true disables home-manager.$USER options
              home-manager.useUserPackages = true;
              home-manager.users.tm = import ./hosts/${hostname}/home.nix ;
              home-manager.extraSpecialArgs = {inherit inputs;};
            }
          ];
        };
      };
  };
}
