{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "5afc5fd834f2cadb0455496645e662f781caea94";
    hash = "sha256-2Uy053F7fxS8Kz+09F4cA5NM+TOcXDZ6lHV3wm8ZvLw=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.bsd3;
  };
}
