import 'package:flutter/foundation.dart';

@immutable
class GeoPoint {
  const GeoPoint(this.x, this.y);
  final double x;
  final double y;

  GeoPoint operator +(GeoPoint other) => GeoPoint(x + other.x, y + other.y);
  GeoPoint operator -(GeoPoint other) => GeoPoint(x - other.x, y - other.y);
  GeoPoint operator *(double scale) => GeoPoint(x * scale, y * scale);
  double distanceSquared(GeoPoint other) =>
      (x - other.x) * (x - other.x) + (y - other.y) * (y - other.y);
  @override
  bool operator ==(Object other) =>
      other is GeoPoint && x == other.x && y == other.y;
  @override
  int get hashCode => Object.hash(x, y);
  @override
  String toString() => '($x, $y)';
}

@immutable
class GeoBox {
  const GeoBox(this.minX, this.minY, this.maxX, this.maxY);
  final double minX, minY, maxX, maxY;
  bool contains(GeoPoint point, {double epsilon = 1e-9}) =>
      point.x >= minX - epsilon &&
      point.x <= maxX + epsilon &&
      point.y >= minY - epsilon &&
      point.y <= maxY + epsilon;
}

enum GeoShape { points, polyline, polygon, pixels }

enum GeoRole { original, working, result, guide }

@immutable
class GeometryLayer {
  GeometryLayer(
    this.label,
    Iterable<GeoPoint> points, {
    this.shape = GeoShape.polyline,
    this.role = GeoRole.working,
  }) : points = List.unmodifiable(points);
  final String label;
  final List<GeoPoint> points;
  final GeoShape shape;
  final GeoRole role;
}

@immutable
class GeometryTrace {
  GeometryTrace({
    required this.caption,
    required this.bounds,
    required Iterable<GeometryLayer> layers,
    this.clipWindow,
    Map<String, Object> variables = const {},
    Iterable<GeoPoint> output = const [],
    this.value,
    this.result = '',
  }) : layers = List.unmodifiable(layers),
       variables = Map.unmodifiable(
         variables.map((key, value) => MapEntry(key, '$value')),
       ),
       output = List.unmodifiable(output);
  final String caption;
  final GeoBox bounds;
  final List<GeometryLayer> layers;
  final GeoBox? clipWindow;
  final Map<String, String> variables;
  final List<GeoPoint> output;
  final double? value;
  final String result;
}
