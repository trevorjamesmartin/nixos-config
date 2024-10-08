{ buildGoModule, lib, fetchFromGitHub, ... }:

buildGoModule rec {
  pname = "hypsi";
  version = "0.9.4";
  src = fetchFromGitHub {
    owner = "trevorjamesmartin";
    repo = "hypsi";
    rev = "1cae8395ce1d594740ffca298b8f82bf6ffc6b01";
    hash = "sha256-t+SApXfBID8tyttavj0IOG91Z6J2ev31wvj0bH3GOfs=";
  };
  vendorHash = null;

  meta = with lib; {
    description = "Simple tool to set your hyprpaper, written in Go";
    mainProgram = "hypsi";
    license = licenses.bsd3;
  };
  
}
