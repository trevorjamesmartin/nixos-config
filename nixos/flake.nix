{
  description = "Nixos + Home-Manager, configuration with flakes";

  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    hyprland.url = "github:hyprwm/hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager.url = "github:nix-community/home-manager";
    
    hypsi.url = "github:trevorjamesmartin/hypsi";
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
    localHost = {
      name="thinkpadt14s";  # hostname
      arch="x86_64-linux";  # architecture
      user="tm";            # username
    };
  in
  {
      homeConfigurations.${localHost.user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ 
          inputs.hyprland.homeManagerModules.default
          inputs.catppuccin.homeManagerModules.catppuccin
        ];
      };
      nixosConfigurations = {
        ${localHost.name} = nixpkgs.lib.nixosSystem {
          system = localHost.arch;
          specialArgs = { inherit inputs; inherit localHost; };
          modules = [
            catppuccin.nixosModules.catppuccin
            ./hosts/${localHost.name}/configuration.nix
            inputs.home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = false; # setting this to true disables home-manager.$USER options
              home-manager.useUserPackages = true;
              home-manager.users.${localHost.user} = import ./hosts/${localHost.name}/home.nix ;
              home-manager.extraSpecialArgs = { inherit inputs; inherit localHost; };
            }
          ];
        };
      };
  };
}
