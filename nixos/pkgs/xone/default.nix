{ config, lib, pkgs, ... }:

let
  xone-kernel-module = pkgs.callPackage ./xone.nix { inherit (config.boot.kernelPackages) kernel; };
  patched = xone-kernel-module.overrideAttrs (prev: {
    patches = [ ./xonepatch.patch ];
  });
in
{
  boot.extraModulePackages = [
    (lib.hiPrio patched)
  ];
}
