import 'dart:math';

import '../algorithms/geometry_extensions.dart';
import '../models/algorithm.dart';
import '../models/geometry_trace.dart';
import '../models/viz_run.dart';
import '../visualizers/geometry_trace_view.dart';

final _random = Random();
T _pick<T>(List<T> choices) => choices[_random.nextInt(choices.length)];

AlgorithmInfo _entry(
  String id,
  String name,
  String blurb,
  String description,
  String time,
  String space,
  List<GeometryTrace> Function() generate,
) => AlgorithmInfo(
  id: id,
  name: name,
  category: AlgoCategory.geometry,
  blurb: blurb,
  description: description,
  timeComplexity: time,
  spaceComplexity: space,
  originalSources: const ['Dart'],
  create: () {
    final frames = generate();
    return VizRun(
      legend: const [],
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => GeometryTraceView(frame: frames[i]),
    );
  },
);

final List<AlgorithmInfo> geometryExtensions = [
  _entry(
    'bresenham-line',
    'Bresenham Line Rasterization',
    'Choose connected grid pixels using integer error updates.',
    'An error accumulator measures how far the raster path drifts from an ideal '
        'segment. Its doubled value chooses an x step, a y step, or both. The same '
        'rule handles every octant and includes both endpoints. Amber marks the '
        'current pixel; green preserves the rasterized path.',
    'O(max(|Δx|, |Δy|))',
    'O(1) excluding output',
    () {
      final (x, y) = _pick([(8, 3), (3, 8), (-7, 4), (7, -5), (-4, -8)]);
      return bresenhamLine(0, 0, x, y);
    },
  ),
  _entry(
    'midpoint-circle',
    'Midpoint Circle Rasterization',
    'Rasterize one octant and reflect it eight ways.',
    'Start at the circle’s top and use the midpoint decision value to choose '
        'east or southeast pixels. Each choice is reflected across both axes and '
        'diagonals. A set prevents duplicate pixels at symmetry boundaries and '
        'handles a zero-radius circle as one pixel.',
    'O(r)',
    'O(1) excluding output',
    () => midpointCircle(0, 0, 3 + _random.nextInt(4)),
  ),
  _entry(
    'cohen-sutherland',
    'Cohen–Sutherland Line Clipping',
    'Use region bits to accept, reject or shorten a segment.',
    'Four bits identify the half-planes outside an axis-aligned window. Two '
        'zero codes accept the segment; a shared outside bit rejects it. Otherwise '
        'replace an outside endpoint with a boundary intersection and repeat. '
        'The original segment remains visible behind the clipped result.',
    'O(1)',
    'O(1)',
    () {
      final endpoints = _pick([
        [const GeoPoint(-4, -2), const GeoPoint(7, 5)],
        [const GeoPoint(-4, 5), const GeoPoint(6, -2)],
        [const GeoPoint(2, -3), const GeoPoint(2, 7)],
        [const GeoPoint(-3, 6), const GeoPoint(7, 6)],
      ]);
      return cohenSutherlandClip(
        endpoints[0],
        endpoints[1],
        const GeoBox(0, 0, 4, 4),
      );
    },
  ),
  _entry(
    'sutherland-hodgman',
    'Sutherland–Hodgman Polygon Clipping',
    'Clip a polygon against four inside half-planes.',
    'For each rectangle boundary, classify successive polygon endpoints as '
        'inside or outside. Emit retained endpoints and entry or exit intersections. '
        'The emitted polygon becomes the next boundary’s input. Input vertices must '
        'describe a simple polygon in boundary order; concave subjects are supported.',
    'O(n) clipping; O(n²) validation',
    'O(n)',
    () {
      final shift = _random.nextInt(3) - 1;
      return sutherlandHodgmanClip([
        GeoPoint(-1 + shift.toDouble(), 1),
        const GeoPoint(2, -1),
        const GeoPoint(6, 2),
        const GeoPoint(4, 6),
        const GeoPoint(1, 5),
      ], const GeoBox(0, 0, 4, 4));
    },
  ),
  _entry(
    'ramer-douglas-peucker',
    'Ramer–Douglas–Peucker Simplification',
    'Replace a path with shortcuts that respect a distance tolerance.',
    'Measure each intermediate point’s shortest distance to the proposed '
        'endpoint segment. Keep the farthest point and recursively split when its '
        'distance exceeds tolerance. Otherwise accept the shortcut. Endpoints remain '
        'fixed; this is a tolerance guarantee, not a minimum-vertex optimization.',
    'O(n²) worst case',
    'O(n)',
    () => ramerDouglasPeucker([
      const GeoPoint(0, 0),
      const GeoPoint(1, 0.2),
      const GeoPoint(2, -0.1),
      const GeoPoint(3, 2.5),
      const GeoPoint(4, 2.8),
      const GeoPoint(5, 2.4),
      const GeoPoint(6, 0.2),
      const GeoPoint(7, 0),
    ], _pick([0.25, 0.5, 1.0, 1.5])),
  ),
  _entry(
    'de-casteljau-bezier',
    'de Casteljau Bézier Construction',
    'Build curve points by repeated linear interpolation.',
    'At a chosen parameter t, interpolate every adjacent pair of control points. '
        'Repeat on the shorter point list until one point remains on the Bézier '
        'curve. Successive construction layers expose the geometry. Green connects '
        'sampled curve points, including the exact endpoints at t=0 and t=1.',
    'O(s·d²) for s samples, degree d',
    'O(d²) construction layers',
    () => deCasteljauBezier([
      const GeoPoint(0, 0),
      GeoPoint(1, 3 + _random.nextInt(3).toDouble()),
      GeoPoint(5, 2 + _random.nextInt(4).toDouble()),
      const GeoPoint(7, 0),
    ], steps: 12),
  ),
  _entry(
    'shoelace-area',
    'Shoelace Polygon Area',
    'Accumulate signed edge cross products around a polygon.',
    'Each ordered edge contributes xᵢyᵢ₊₁ − yᵢxᵢ₊₁. Include the closing edge, '
        'then take half the absolute sum. The highlighted triangle explains the '
        'signed contribution. Simple polygons may be clockwise or counterclockwise; '
        'self-intersecting inputs are rejected rather than reporting a misleading area.',
    'O(n) sum; O(n²) validation',
    'O(n) validated input',
    () {
      final height = 3 + _random.nextInt(3).toDouble();
      return shoelaceArea([
        const GeoPoint(0, 0),
        const GeoPoint(5, 0),
        GeoPoint(6, height),
        GeoPoint(2, height + 1),
        GeoPoint(-1, height),
      ]);
    },
  ),
  _entry(
    'rotating-calipers-diameter',
    'Rotating Calipers: Polygon Diameter',
    'Find the farthest antipodal pair of a convex polygon.',
    'The vertices must describe a simple convex polygon in boundary order. '
        'Normalize clockwise input and remove collinear boundary vertices. Advance '
        'the opposite vertex while triangle area increases, then test the supporting '
        'edge’s endpoints against its antipodal contacts. Parallel-edge ties are '
        'checked explicitly. The scan is linear after input validation.',
    'O(n) scan; O(n²) validation',
    'O(n)',
    () {
      final n = 5 + _random.nextInt(3), phase = _random.nextDouble();
      return rotatingCalipersDiameter(
        List.generate(
          n,
          (i) => GeoPoint(
            4 * cos(phase + i * 2 * pi / n),
            3 * sin(phase + i * 2 * pi / n),
          ),
        ),
      );
    },
  ),
];
