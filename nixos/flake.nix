{
  description = "Nixos configuration with flakes";
  
  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs-release.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/574d1eac1c200690e27b8eb4e24887f8df7ac27c"; # (2024-09-06)

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
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      home-manager.extraSpecialArgs = { inherit inputs; };

      thinkpadt14s = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = with self.nixosModules; [ 

          catppuccin.nixosModules.catppuccin
          ./hosts/thinkpadt14s/configuration.nix

          inputs.home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = false; # setting this to true disables home-manager.$USER options
            home-manager.useUserPackages = true;
            home-manager.users.tm = import ./hosts/thinkpadt14s/home-manager/home.nix ;
          }
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = with self.nixosModules; [ 

          catppuccin.nixosModules.catppuccin
          ./hosts/desktop/configuration.nix

          inputs.home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = false; # setting this to true disables home-manager.$USER options
            home-manager.useUserPackages = true;
            home-manager.users.tm = import ./hosts/desktop/home-manager/home.nix ;
          }
        ];
      };

    };
  };
}
