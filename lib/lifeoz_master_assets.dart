import 'package:flutter/widgets.dart';

/// Master visual map for the locked LIFEOZ artwork.
/// The source artwork is kept in the master-home renderer so the app can use
/// exact artwork regions without falling back to generated Flutter symbols.
class LifeOZMasterAssets {
  static const String source = 'master-home-artwork';

  // Normalized crop rectangles (left, top, right, bottom) for the ten
  // approved visual assets in the master artwork.
  static const Map<String, Rect> crops = {
    'appIcon': Rect.fromLTWH(0.238, 0.020, 0.092, 0.141),
    'fullLogo': Rect.fromLTWH(0.010, 0.000, 0.215, 0.420),
    'yansi': Rect.fromLTWH(0.550, 0.000, 0.230, 0.470),
    'holographicControl': Rect.fromLTWH(0.655, 0.000, 0.335, 0.430),
    'oreonPrime': Rect.fromLTWH(0.006, 0.610, 0.165, 0.350),
    'terraFlux': Rect.fromLTWH(0.173, 0.610, 0.165, 0.350),
    'vortexNexus': Rect.fromLTWH(0.340, 0.610, 0.165, 0.350),
    'crystaLumen': Rect.fromLTWH(0.505, 0.610, 0.165, 0.350),
    'nebulaSoul': Rect.fromLTWH(0.675, 0.610, 0.165, 0.350),
    'shadowCore': Rect.fromLTWH(0.842, 0.610, 0.158, 0.350),
  };
}
