{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "9831b43589f873e6f956e84a87799ceee8392721";
    hash = "sha256-B2vuqdT5AXHmkVwQ6XozZOdRcYQuwfUOSfIS194phGA=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.bsd3;
  };
}
