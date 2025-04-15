{
  description = "Nix flake for building Source Engine and Half-Life 2 on macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          source-engine = prev.stdenv.mkDerivation {
            pname = "source-engine";
            version = "latest";
            src = prev.fetchFromGitHub {
              owner = "nillerusr";
              repo = "source-engine";
              rev = "master";
              fetchSubmodules = true;
              sha256 = "";
            };
            nativeBuildInputs = [prev.python3 prev.pkg-config];
            shellHook = ''
              git submodule update --init --recursive
            '';
            buildInputs = with pkgs; [
              SDL2
              freetype
              fontconfig
              opusTools
              libjpeg
              libpng
              libedit
              curl
            ];
            buildPhase = ''
              python3 waf configure -T release --prefix="" --build-games=hl2
              python3 waf build
            '';
            installPhase = ''
              python3 waf install --destdir=$out
            '';
            meta = {
              description = "Source Engine with Half-Life 2 for macOS";
              license = pkgs.lib.licenses.gpl2;
              platforms = [system];
            };
          };
        })
      ];
    };
  in {
    packages.${system}.default = pkgs.source-engine;
  };
}

