{
  description = "Home Manager configuration of tm";

  inputs = {
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
      nixpkgs, 
      catppuccin,
      hyprland-plugins,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."tm" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Optionally use extraSpecialArgs to pass through arguments to home.nix       
        extraSpecialArgs = { inherit inputs; };
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
          catppuccin.homeManagerModules.catppuccin
          ./home.nix
        ];
      };
    };
}
