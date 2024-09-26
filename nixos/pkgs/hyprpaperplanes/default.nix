{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "8938fa8f4344b6149d8d65aa4ceca4b06d67d489";
    hash = "sha256-F9wTaHTYW/L+zYWBOgWRelk6I+y6zX4Y6MXlnaA7kj8=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.mit;
  };
}
