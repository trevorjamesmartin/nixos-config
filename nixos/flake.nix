{
  description = "Nixos configuration with flakes";
  
  inputs = {
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs-stable.url = "github:nixos/nixpkgs/24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    catppuccin.url = "github:catppuccin/nix";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    
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
      nixpkgs-stable,
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

      default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = with self.nixosModules; [ 

          nixos-hardware.nixosModules.lenovo-thinkpad-t14s
          
          catppuccin.nixosModules.catppuccin
          ./hosts/default/configuration.nix

          inputs.home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
