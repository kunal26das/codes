import 'dart:math' as math;

import 'package:algoscope/algorithms/geometry_extensions.dart';
import 'package:algoscope/data/geometry_catalog.dart';
import 'package:algoscope/models/geometry_trace.dart';
import 'package:algoscope/visualizers/geometry_trace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const box = GeoBox(0, 0, 4, 4);

void pointsClose(List<GeoPoint> actual, List<GeoPoint> expected) {
  expect(actual.length, expected.length);
  for (var i = 0; i < actual.length; i++) {
    expect(actual[i].x, closeTo(expected[i].x, 1e-7));
    expect(actual[i].y, closeTo(expected[i].y, 1e-7));
  }
}

void validate(List<GeometryTrace> frames) {
  expect(frames.length, greaterThanOrEqualTo(2));
  expect(frames.last.result, isNotEmpty);
  for (final frame in frames) {
    expect(frame.caption, isNotEmpty);
    expect(frame.bounds.maxX, greaterThan(frame.bounds.minX));
    expect(frame.bounds.maxY, greaterThan(frame.bounds.minY));
    for (final point in [
      ...frame.layers.expand((layer) => layer.points),
      ...frame.output,
    ]) {
      expect(point.x.isFinite && point.y.isFinite, isTrue);
      expect(
        frame.bounds.contains(point),
        isTrue,
        reason: '${frame.caption}: $point',
      );
    }
    if (frame.value != null) expect(frame.value!.isFinite, isTrue);
  }
}

// An independent parametric interval oracle (Liang–Barsky/slab intersection),
// rather than the region codes used by the implementation under test.
List<GeoPoint> clipOracle(GeoPoint a, GeoPoint b, GeoBox rect) {
  var low = 0.0, high = 1.0;
  for (final (origin, delta, min, max) in [
    (a.x, b.x - a.x, rect.minX, rect.maxX),
    (a.y, b.y - a.y, rect.minY, rect.maxY),
  ]) {
    if (delta == 0) {
      if (origin < min || origin > max) return [];
    } else {
      final first = (min - origin) / delta, last = (max - origin) / delta;
      low = math.max(low, math.min(first, last));
      high = math.min(high, math.max(first, last));
      if (low > high) return [];
    }
  }
  return [a + (b - a) * low, a + (b - a) * high];
}

double trapezoidArea(List<GeoPoint> polygon) {
  var integral = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i], b = polygon[(i + 1) % polygon.length];
    integral += (b.x - a.x) * (a.y + b.y) / 2;
  }
  return integral.abs();
}

Map<String, List<GeometryTrace>> examples() => {
  'line': bresenhamLine(-2, 1, 7, 5),
  'circle': midpointCircle(0, 0, 5),
  'line clip': cohenSutherlandClip(
    const GeoPoint(-3, -1),
    const GeoPoint(7, 5),
    box,
  ),
  'polygon clip': sutherlandHodgmanClip(const [
    GeoPoint(-1, 1),
    GeoPoint(2, -1),
    GeoPoint(6, 2),
    GeoPoint(4, 6),
    GeoPoint(1, 5),
  ], box),
  'simplify': ramerDouglasPeucker(const [
    GeoPoint(0, 0),
    GeoPoint(1, 0.1),
    GeoPoint(2, 0),
    GeoPoint(3, 3),
    GeoPoint(4, 0.1),
    GeoPoint(5, 0),
  ], 0.3),
  'bezier': deCasteljauBezier(const [
    GeoPoint(0, 0),
    GeoPoint(1, 4),
    GeoPoint(5, 3),
    GeoPoint(7, 0),
  ], steps: 8),
  'area': shoelaceArea(const [
    GeoPoint(0, 0),
    GeoPoint(5, 0),
    GeoPoint(6, 3),
    GeoPoint(2, 4),
    GeoPoint(-1, 3),
  ]),
  'diameter': rotatingCalipersDiameter(const [
    GeoPoint(0, 0),
    GeoPoint(5, 0),
    GeoPoint(6, 3),
    GeoPoint(2, 4),
    GeoPoint(-1, 3),
  ]),
};

void main() {
  test('Bresenham covers all octants with connected near-line pixels', () {
    for (var x = -8; x <= 8; x++) {
      for (var y = -8; y <= 8; y++) {
        final frames = bresenhamLine(1, -1, x, y), pixels = frames.last.output;
        expect(pixels.first, const GeoPoint(1, -1));
        expect(pixels.last, GeoPoint(x.toDouble(), y.toDouble()));
        expect(pixels.length, math.max((x - 1).abs(), (y + 1).abs()) + 1);
        expect(pixels.toSet().length, pixels.length);
        final length = math.sqrt((x - 1) * (x - 1) + (y + 1) * (y + 1));
        for (var i = 0; i < pixels.length; i++) {
          final p = pixels[i];
          expect(p.x, p.x.roundToDouble());
          expect(p.y, p.y.roundToDouble());
          if (length > 0) {
            final distance =
                ((x - 1) * (p.y + 1) - (y + 1) * (p.x - 1)).abs() / length;
            expect(distance, lessThanOrEqualTo(0.71));
          }
          if (i > 0) {
            expect(
              math.max(
                (p.x - pixels[i - 1].x).abs(),
                (p.y - pixels[i - 1].y).abs(),
              ),
              1,
            );
          }
        }
        validate(frames);
      }
    }
  });

  test(
    'midpoint circles have symmetry, cardinal pixels and bounded radial error',
    () {
      for (var radius = 0; radius <= 20; radius++) {
        final frames = midpointCircle(2, -3, radius),
            points = frames.last.output.toSet();
        expect(points.length, frames.last.output.length);
        for (final p in points) {
          final x = p.x - 2, y = p.y + 3;
          expect(
            (math.sqrt(x * x + y * y) - radius).abs(),
            lessThanOrEqualTo(0.71),
          );
          for (final (dx, dy) in [
            (x, y),
            (y, x),
            (-x, y),
            (-y, x),
            (x, -y),
            (y, -x),
            (-x, -y),
            (-y, -x),
          ]) {
            expect(points, contains(GeoPoint(2 + dx, -3 + dy)));
          }
        }
        expect(points, contains(GeoPoint(2 + radius.toDouble(), -3)));
        expect(points, contains(GeoPoint(2, -3 + radius.toDouble())));
        validate(frames);
      }
    },
  );

  test('Cohen–Sutherland matches parametric segment-window intersection', () {
    final random = math.Random(180);
    final segments = <List<GeoPoint>>[
      [const GeoPoint(-1, 0), const GeoPoint(5, 0)],
      [const GeoPoint(0, -2), const GeoPoint(0, 6)],
      [const GeoPoint(2, 2), const GeoPoint(2, 2)],
      [const GeoPoint(5, 5), const GeoPoint(5, 5)],
      [const GeoPoint(-1, 1), const GeoPoint(1, -1)],
      for (var i = 0; i < 100; i++)
        [
          for (var j = 0; j < 2; j++)
            GeoPoint(random.nextInt(17) - 8.0, random.nextInt(17) - 8.0),
        ],
    ];
    for (final segment in segments) {
      final frames = cohenSutherlandClip(segment[0], segment[1], box);
      final expected = clipOracle(segment[0], segment[1], box);
      pointsClose(frames.last.output, expected);
      expect(frames.last.value, expected.isEmpty ? 0 : 1);
      validate(frames);
    }
  });

  test(
    'polygon clipping handles containment, concavity, disjoint and boundary cases',
    () {
      final cases = <(List<GeoPoint>, GeoBox, double)>[
        (
          const [
            GeoPoint(-2, -2),
            GeoPoint(6, -2),
            GeoPoint(6, 6),
            GeoPoint(-2, 6),
          ],
          box,
          16,
        ),
        (
          const [
            GeoPoint(1, 1),
            GeoPoint(3, 1),
            GeoPoint(3, 3),
            GeoPoint(1, 3),
          ],
          box,
          4,
        ),
        (
          const [
            GeoPoint(6, 6),
            GeoPoint(8, 6),
            GeoPoint(8, 8),
            GeoPoint(6, 8),
          ],
          box,
          0,
        ),
        (
          const [GeoPoint(0, 0), GeoPoint(4, 0), GeoPoint(0, 4)],
          const GeoBox(1, 1, 3, 3),
          2,
        ),
        (
          const [
            GeoPoint(0, 0),
            GeoPoint(4, 0),
            GeoPoint(4, 4),
            GeoPoint(2, 2),
            GeoPoint(0, 4),
          ],
          const GeoBox(1, 1, 3, 3),
          3,
        ),
        (
          const [
            GeoPoint(0, 0),
            GeoPoint(4, 0),
            GeoPoint(4, 4),
            GeoPoint(0, 4),
          ],
          box,
          16,
        ),
      ];
      for (final (polygon, window, area) in cases) {
        for (final points in [polygon, polygon.reversed.toList()]) {
          final frames = sutherlandHodgmanClip(points, window);
          expect(trapezoidArea(frames.last.output), closeTo(area, 1e-8));
          expect(frames.last.output.every(window.contains), isTrue);
          validate(frames);
        }
      }
    },
  );

  test(
    'RDP preserves ordered endpoints and every accepted segment tolerance',
    () {
      final random = math.Random(23);
      for (final input in <List<GeoPoint>>[
        [],
        [const GeoPoint(1, 1)],
        const [GeoPoint(0, 0), GeoPoint(1, 0), GeoPoint(2, 0)],
        const [GeoPoint(0, 0), GeoPoint(1, 1), GeoPoint(0, 0)],
        for (var repeat = 0; repeat < 20; repeat++)
          List.generate(
            10,
            (i) => GeoPoint(i.toDouble(), random.nextDouble() * 4),
          ),
      ]) {
        for (final tolerance in [0.0, 0.3, 1.0, 10.0]) {
          final frames = ramerDouglasPeucker(input, tolerance),
              output = frames.last.output;
          if (input.isNotEmpty) {
            expect(output.first, input.first);
            expect(output.last, input.last);
          }
          var from = 0;
          for (var segment = 1; segment < output.length; segment++) {
            final a = output[segment - 1], b = output[segment];
            final to = input.indexOf(b, from + 1);
            expect(to, greaterThan(from));
            final dx = b.x - a.x,
                dy = b.y - a.y,
                denominator = dx * dx + dy * dy;
            for (var i = from; i <= to; i++) {
              final t = denominator == 0
                  ? 0.0
                  : (((input[i].x - a.x) * dx + (input[i].y - a.y) * dy) /
                            denominator)
                        .clamp(0.0, 1.0);
              final closest = GeoPoint(a.x + t * dx, a.y + t * dy);
              expect(
                math.sqrt(input[i].distanceSquared(closest)),
                lessThanOrEqualTo(tolerance + 1e-8),
              );
            }
            from = to;
          }
          validate(frames);
        }
      }
    },
  );

  test('de Casteljau samples match the independent Bernstein polynomial', () {
    int choose(int n, int k) {
      var value = 1;
      for (var j = 1; j <= k; j++) {
        value = value * (n - j + 1) ~/ j;
      }
      return value;
    }

    for (final controls in <List<GeoPoint>>[
      const [GeoPoint(2, 3)],
      const [GeoPoint(-2, 1), GeoPoint(6, 5)],
      const [GeoPoint(0, 0), GeoPoint(2, 5), GeoPoint(5, 0)],
      const [GeoPoint(0, 0), GeoPoint(1, 4), GeoPoint(5, 3), GeoPoint(7, 0)],
    ]) {
      final frames = deCasteljauBezier(controls, steps: 10),
          output = frames.last.output;
      expect(output.length, 11);
      for (var sample = 0; sample <= 10; sample++) {
        final t = sample / 10, degree = controls.length - 1;
        var x = 0.0, y = 0.0;
        for (var i = 0; i <= degree; i++) {
          final weight =
              choose(degree, i) * math.pow(t, i) * math.pow(1 - t, degree - i);
          x += controls[i].x * weight;
          y += controls[i].y * weight;
        }
        pointsClose([output[sample]], [GeoPoint(x, y)]);
      }
      expect(output.first, controls.first);
      expect(output.last, controls.last);
      validate(frames);
    }
  });

  test(
    'shoelace area and calipers match analytic area and exhaustive distances',
    () {
      final random = math.Random(88);
      for (var n = 3; n <= 12; n++) {
        final phase = random.nextDouble(),
            rx = 2 + random.nextDouble() * 5,
            ry = 2 + random.nextDouble() * 4;
        final polygon = List.generate(
          n,
          (i) => GeoPoint(
            rx * math.cos(phase + 2 * math.pi * i / n),
            ry * math.sin(phase + 2 * math.pi * i / n),
          ),
        );
        final area = n * rx * ry * math.sin(2 * math.pi / n) / 2;
        final diameter = [
          for (final a in polygon)
            for (final b in polygon) math.sqrt(a.distanceSquared(b)),
        ].reduce(math.max);
        for (final points in [
          polygon,
          polygon.reversed.toList(),
          polygon.map((p) => p + const GeoPoint(7, -4)).toList(),
        ]) {
          final areaFrames = shoelaceArea(points),
              diameterFrames = rotatingCalipersDiameter(points);
          expect(areaFrames.last.value, closeTo(area, 1e-7));
          expect(diameterFrames.last.value, closeTo(diameter, 1e-7));
          expect(
            math.sqrt(
              diameterFrames.last.output[0].distanceSquared(
                diameterFrames.last.output[1],
              ),
            ),
            closeTo(diameter, 1e-7),
          );
          validate(areaFrames);
          validate(diameterFrames);
        }
      }
      final rectangle = rotatingCalipersDiameter(const [
        GeoPoint(0, 0),
        GeoPoint(2, 0),
        GeoPoint(4, 0),
        GeoPoint(4, 3),
        GeoPoint(0, 3),
      ]);
      expect(rectangle.last.value, 5);
      validate(rectangle);
      expect(
        shoelaceArea(const [
          GeoPoint(0, 0),
          GeoPoint(4, 0),
          GeoPoint(0, 3),
        ]).last.value,
        6,
      );
    },
  );

  test('invalid domains fail explicitly and geometry frames are immutable', () {
    expect(() => midpointCircle(0, 0, -1), throwsArgumentError);
    expect(
      () => cohenSutherlandClip(
        const GeoPoint(0, 0),
        const GeoPoint(1, 1),
        const GeoBox(1, 0, 1, 4),
      ),
      throwsArgumentError,
    );
    expect(() => ramerDouglasPeucker([], -1), throwsArgumentError);
    expect(
      () => ramerDouglasPeucker([const GeoPoint(double.nan, 0)], 1),
      throwsArgumentError,
    );
    expect(() => deCasteljauBezier([]), throwsArgumentError);
    expect(
      () => deCasteljauBezier([const GeoPoint(0, 0)], steps: 0),
      throwsArgumentError,
    );
    expect(
      () => shoelaceArea(const [
        GeoPoint(0, 0),
        GeoPoint(2, 2),
        GeoPoint(0, 2),
        GeoPoint(2, 0),
      ]),
      throwsArgumentError,
    );
    expect(
      () => rotatingCalipersDiameter(const [
        GeoPoint(0, 0),
        GeoPoint(4, 0),
        GeoPoint(2, 1),
        GeoPoint(4, 4),
        GeoPoint(0, 4),
      ]),
      throwsArgumentError,
    );
    expect(
      () => rotatingCalipersDiameter(const [
        GeoPoint(0, 0),
        GeoPoint(1, 0),
        GeoPoint(2, 0),
      ]),
      throwsArgumentError,
    );
    final points = [const GeoPoint(0, 0), const GeoPoint(1, 1)];
    final layer = GeometryLayer('original', points),
        variables = <String, Object>{'step': 0};
    final frame = GeometryTrace(
      caption: 'snapshot',
      bounds: const GeoBox(-1, -1, 2, 2),
      layers: [layer],
      output: points,
      variables: variables,
    );
    points.clear();
    variables['step'] = 1;
    expect(layer.points.length, 2);
    expect(frame.output.length, 2);
    expect(frame.variables['step'], '0');
    expect(() => frame.layers.clear(), throwsUnsupportedError);
    expect(() => layer.points.clear(), throwsUnsupportedError);
    expect(() => frame.variables.clear(), throwsUnsupportedError);
  });

  test('eight geometry catalog entries create complete runs', () {
    expect(geometryExtensions.length, 8);
    expect(geometryExtensions.map((entry) => entry.id).toSet().length, 8);
    for (final entry in geometryExtensions) {
      final run = entry.create();
      expect(run.frameCount, greaterThanOrEqualTo(2));
      for (var i = 0; i < run.frameCount; i++) {
        expect(run.captionAt(i), isNotEmpty);
      }
    }
  });

  testWidgets('every geometry frame renders at phone and desktop dimensions', (
    tester,
  ) async {
    for (final size in [const Size(300, 180), const Size(1100, 500)]) {
      for (final entry in examples().entries) {
        validate(entry.value);
        for (final frame in entry.value) {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox.fromSize(
                  size: size,
                  child: GeometryTraceView(frame: frame),
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${entry.key}: ${frame.caption} at $size',
          );
        }
      }
    }
  });
}
