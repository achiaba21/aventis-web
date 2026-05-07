import 'package:latlong2/latlong.dart';

const _distance = Distance();

double distanceKm(LatLng a, LatLng b) {
  return _distance.as(LengthUnit.Kilometer, a, b);
}
