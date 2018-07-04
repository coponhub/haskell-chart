{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, array, base, cairo, Chart, Chart-cairo
      , colour, data-default-class, gtk3, mtl, old-locale, stdenv, time
      }:
      mkDerivation {
        pname = "Chart-gtk3";
        version = "1.9";
        src = ./.;
        libraryHaskellDepends = [
          array base cairo Chart Chart-cairo colour data-default-class gtk3
          mtl old-locale time
        ];
        homepage = "https://github.com/timbod7/haskell-chart/wiki";
        description = "Utility functions for using the chart library with GTK";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
