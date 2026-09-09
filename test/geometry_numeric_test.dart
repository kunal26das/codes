import 'dart:math' as math;

import 'package:algoscope/algorithms/geometry_extensions.dart';
import 'package:algoscope/models/geometry_trace.dart';
import 'package:flutter_test/flutter_test.dart';

double _diameterOracle(List<GeoPoint> polygon) {
  var best = 0.0;
  for (final a in polygon) {
    for (final b in polygon) {
      best = math.max(best, math.sqrt(a.distanceSquared(b)));
    }
  }
  return best;
}

void _validFrames(List<GeometryTrace> frames) {
  for (final frame in frames) {
    for (final point in frame.layers.expand((layer) => layer.points)) {
      expect(point.x.isFinite && point.y.isFinite, isTrue);
      expect(frame.bounds.contains(point), isTrue);
    }
    if (frame.value != null) expect(frame.value!.isFinite, isTrue);
  }
}

void main() {
  test('shoelace and winding retain small areas far from the origin', () {
    const square = [
      GeoPoint(999999990, 999999990),
      GeoPoint(999999991, 999999990),
      GeoPoint(999999991, 999999991),
      GeoPoint(999999990, 999999991),
    ];
    for (final polygon in [square, square.reversed.toList()]) {
      final area = shoelaceArea(polygon);
      expect(area.last.value, 1);
      expect(area.first.variables['local origin'], '${polygon.first}');
      // The nearby origin also prevents a unit polygon being drawn over a
      // billion-unit span merely to show its signed triangles.
      expect(area.first.bounds.maxX - area.first.bounds.minX, lessThan(5));
      final diameter = rotatingCalipersDiameter(polygon);
      expect(diameter.last.value, closeTo(math.sqrt(2), 1e-14));
      _validFrames(area);
      _validFrames(diameter);
    }
  });

  test(
    'calipers preserves scaled convex vertices and antipodal progression',
    () {
      for (final scale in [1e-10, 1e-4, 1.0, 1e7]) {
        for (final count in [5, 16, 100]) {
          final polygon = List.generate(count, (i) {
            final angle = 0.17 + i * 2 * math.pi / count;
            return GeoPoint(
              scale * math.cos(angle),
              0.7 * scale * math.sin(angle),
            );
          });
          final want = _diameterOracle(polygon);
          for (final points in [polygon, polygon.reversed.toList()]) {
            final frames = rotatingCalipersDiameter(points);
            expect(frames.last.value, closeTo(want, want * 1e-12));
            expect(frames.first.layers.first.points.length, count);
            final pair = frames.last.output;
            expect(
              math.sqrt(pair[0].distanceSquared(pair[1])),
              closeTo(want, want * 1e-12),
            );
            _validFrames(frames);
          }
        }
      }
    },
  );

  test('tiny collinear boundary vertices normalize without losing corners', () {
    const unit = 1e-10;
    const polygon = [
      GeoPoint(0, 0),
      GeoPoint(unit, 0),
      GeoPoint(2 * unit, 0),
      GeoPoint(2 * unit, unit),
      GeoPoint(0, unit),
    ];
    for (final points in [polygon, polygon.reversed.toList()]) {
      final diameter = rotatingCalipersDiameter(points);
      expect(diameter.first.layers.first.points.length, 4);
      expect(diameter.last.value, closeTo(math.sqrt(5) * unit, 1e-22));
      expect(shoelaceArea(points).last.value, closeTo(2e-20, 1e-32));
    }
    expect(
      () => rotatingCalipersDiameter(const [
        GeoPoint(0, 0),
        GeoPoint(unit, 0),
        GeoPoint(2 * unit, 0),
      ]),
      throwsArgumentError,
    );
    expect(
      () => shoelaceArea(const [
        GeoPoint(0, 0),
        GeoPoint(unit, unit),
        GeoPoint(0, unit),
        GeoPoint(unit, 0),
      ]),
      throwsArgumentError,
    );
  });

  test(
    'interpolated oblique boundary points tolerate floating-point roundoff',
    () {
      const a = GeoPoint(-15.032383741773758, 16.678896794458808);
      const b = GeoPoint(-14.873035497660808, 16.94318806525503);
      const c = GeoPoint(19.370864299501605, -10.574822263518634);
      final polygon = [a, (a + b) * 0.5, b, c];
      for (final points in [polygon, polygon.reversed.toList()]) {
        final frames = rotatingCalipersDiameter(points);
        expect(frames.first.layers.first.points.length, 3);
        expect(frames.last.value, closeTo(_diameterOracle(points), 1e-12));
        _validFrames(frames);
      }
    },
  );

  test('polygon clipping does not merge distinct subnanounit vertices', () {
    const unit = 1e-10;
    const window = GeoBox(0, 0, unit, unit);
    const polygon = [
      GeoPoint(-unit, -unit),
      GeoPoint(2 * unit, -unit),
      GeoPoint(2 * unit, 2 * unit),
      GeoPoint(-unit, 2 * unit),
    ];
    for (final points in [polygon, polygon.reversed.toList()]) {
      final frames = sutherlandHodgmanClip(points, window);
      expect(frames.last.output.toSet(), {
        const GeoPoint(0, 0),
        const GeoPoint(unit, 0),
        const GeoPoint(unit, unit),
        const GeoPoint(0, unit),
      });
      expect(
        shoelaceArea(frames.last.output).last.value,
        closeTo(1e-20, 1e-32),
      );
      _validFrames(frames);
    }
  });
}
