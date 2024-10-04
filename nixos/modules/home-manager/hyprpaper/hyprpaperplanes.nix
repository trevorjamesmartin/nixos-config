{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "09e593e31888ba79418ea892ba4122252ab95cf7";
    hash = "sha256-gLG/4Te+pySy9tDHj4m9hcZrRbRHKwwVG6ZMHAlOePI=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.bsd3;
  };
}
