{ mkDerivation, array, base, cairo, Chart, Chart-cairo, colour
, data-default-class, gtk3, mtl, old-locale, stdenv, time
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
}
