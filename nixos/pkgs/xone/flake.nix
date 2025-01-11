{
  description = "xbox one controller (kernel driver)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {}; 
      overlays = [
        (self: super: {
            xone = super.callPackage ./default.nix;
        })
      ];
    };
  in
  {

    packages.x86_64-linux.xone = pkgs.xone;


    packages.x86_64-linux.default = self.packages.x86_64-linux.xone;

  };

}
