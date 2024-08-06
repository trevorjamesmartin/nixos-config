{ buildGoModule, lib, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.1";

  src = ./.;
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.mit;
  };
}
