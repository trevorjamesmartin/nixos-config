{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "16fa3251fba9e8ebd6a9f5b532c59d23688f4236";
    hash = "sha256-JpH6ySPPH92R0RqONNQnzc3g1H5M3MJaUwMrK3HNyGs=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.bsd3;
  };
  
}
