{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hyprpaperplanes";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hyprpaperplanes";
    rev = "9ed970e18bb70f19dd75b77c3795ea93118031a7";
    hash = "sha256-uJRiDnMbYSwlYSCsGRMeewoa3TeQ9tw8QS8eJWtu0eY=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hyprPaperPlanes";
    license = licenses.bsd3;
  };
}
