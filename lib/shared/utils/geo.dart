import 'dart:math' as math;

/// Jarak dua titik koordinat (meter), rumus haversine.
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * earthRadius * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _rad(double degree) => degree * math.pi / 180;
