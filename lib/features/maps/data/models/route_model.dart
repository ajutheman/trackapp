import 'package:latlong2/latlong.dart';
// Force refresh

class RouteModel {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds
  final String? description;

  RouteModel({
    required this.points,
    required this.distance,
    required this.duration,
    this.description,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    // OSRM returns geometry as GeoJSON if requested, or encoded polyline
    // We will assume GeoJSON for simplicity or decode polyline if needed.
    // Here handling GeoJSON:
    final geometry = map['geometry'];
    final List<LatLng> points = [];

    if (geometry != null && geometry['coordinates'] != null) {
      final coordinates = geometry['coordinates'] as List;
      for (var coord in coordinates) {
        // GeoJSON is [lon, lat]
        points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));
      }
    }

    return RouteModel(
      points: points,
      distance: (map['distance'] as num).toDouble(),
      duration: (map['duration'] as num).toDouble(),
      description: map['weight_name'] as String?,
    );
  }
  // Get points with approximately `gapMeters` gap between them
  List<LatLng>   getPointsWithGap(double gapMeters) {
    if (points.isEmpty) return [];

    final List<LatLng> result = [points.first];
    final Distance distanceCalc = const Distance();

    double accumulatedDistance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final double dist = distanceCalc.as(
        LengthUnit.Meter,
        points[i],
        points[i + 1],
      );
      accumulatedDistance += dist;

      if (accumulatedDistance >= gapMeters) {
        result.add(points[i + 1]);
        accumulatedDistance = 0;
      }
    }

    // Always include the last point
    if (result.last != points.last) {
      result.add(points.last);
    }

    return result;
  }
}
