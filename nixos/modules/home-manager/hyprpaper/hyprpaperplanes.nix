{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "75b0394947b86a4ccc9fa43c71ccc6d555fa4eb2";
    hash = "sha256-SpAC2yMpzYi+xfzDl7He19xgcSgzEJ1jcwKgaYX0zK8=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.bsd3;
  };
}
