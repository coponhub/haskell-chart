{ mkDerivation, array, base, cairo, Chart, Chart-gi-cairo, colour
, data-default-class, gi-cairo, gi-gdk, gi-gtk-hs, haskell-gi-base
, mtl, old-locale, stdenv, time
}:
mkDerivation {
  pname = "Chart-gi-gtk";
  version = "1.9";
  src = ./.;
  libraryHaskellDepends = [
    array base cairo Chart Chart-gi-cairo colour data-default-class
    gi-cairo gi-gdk gi-gtk-hs haskell-gi-base mtl old-locale time
  ];
  homepage = "https://github.com/timbod7/haskell-chart/wiki";
  description = "Utility functions for using the chart library with GTK";
  license = stdenv.lib.licenses.bsd3;
}
