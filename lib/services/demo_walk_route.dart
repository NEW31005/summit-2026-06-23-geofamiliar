import 'package:latlong2/latlong.dart';

class DemoWalkRoute {
  const DemoWalkRoute._();

  static List<LatLng> tokyoStationLoop() {
    const waterside = LatLng(35.68564, 139.760371);
    const station = LatLng(35.681236, 139.767125);
    const park = LatLng(35.684949, 139.761962);
    const office = LatLng(35.680521, 139.764731);

    return [
      ..._between(waterside, station, 7),
      ..._between(station, park, 7).skip(1),
      ..._between(park, office, 7).skip(1),
      ..._between(office, station, 7).skip(1),
    ];
  }

  static List<LatLng> _between(LatLng start, LatLng end, int steps) {
    return [
      for (var i = 0; i < steps; i++)
        LatLng(
          _lerp(start.latitude, end.latitude, i / (steps - 1)),
          _lerp(start.longitude, end.longitude, i / (steps - 1)),
        ),
    ];
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
