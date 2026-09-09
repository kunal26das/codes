import 'dart:math' as math;

import '../models/geometry_trace.dart';

// Compare normalized directions, rather than a fixed area in world units.
// Allow roundoff in collinear points produced by interpolation before the call.
const _relativeEpsilon = 1e-12;
double _cross(GeoPoint a, GeoPoint b, GeoPoint c) =>
    (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);

int _crossSign(GeoPoint u, GeoPoint v) {
  final uScale = math.max(u.x.abs(), u.y.abs());
  final vScale = math.max(v.x.abs(), v.y.abs());
  if (uScale == 0 || vScale == 0) return 0;
  final forward = (u.x / uScale) * (v.y / vScale);
  final backward = (u.y / uScale) * (v.x / vScale);
  final value = forward - backward;
  return value > _relativeEpsilon
      ? 1
      : value < -_relativeEpsilon
      ? -1
      : 0;
}

int _turn(GeoPoint a, GeoPoint b, GeoPoint c) => _crossSign(b - a, c - a);

double _signedDoubleArea(List<GeoPoint> polygon) {
  final origin = polygon.first;
  var sum = 0.0, correction = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final term = _cross(origin, polygon[i], polygon[(i + 1) % polygon.length]);
    final adjusted = term - correction;
    final next = sum + adjusted;
    correction = (next - sum) - adjusted;
    sum = next;
  }
  return sum;
}

void _finite(Iterable<GeoPoint> points) {
  for (final point in points) {
    if (!point.x.isFinite ||
        !point.y.isFinite ||
        point.x.abs() > 1e9 ||
        point.y.abs() > 1e9) {
      throw ArgumentError('Coordinates must be finite and within ±1e9.');
    }
  }
}

void _window(GeoBox box) {
  _finite([GeoPoint(box.minX, box.minY), GeoPoint(box.maxX, box.maxY)]);
  if (box.minX >= box.maxX || box.minY >= box.maxY) {
    throw ArgumentError(
      'A clipping rectangle must have positive width and height.',
    );
  }
}

GeoBox _bounds(Iterable<GeoPoint> input) {
  final points = input.toList();
  if (points.isEmpty) return const GeoBox(-1, -1, 1, 1);
  final minX = points.map((p) => p.x).reduce(math.min),
      maxX = points.map((p) => p.x).reduce(math.max);
  final minY = points.map((p) => p.y).reduce(math.min),
      maxY = points.map((p) => p.y).reduce(math.max);
  final margin = math.max(1.0, math.max(maxX - minX, maxY - minY) * 0.1);
  return GeoBox(
    (minX - margin).floorToDouble(),
    (minY - margin).floorToDouble(),
    (maxX + margin).ceilToDouble(),
    (maxY + margin).ceilToDouble(),
  );
}

List<GeoPoint> _corners(GeoBox box) => [
  GeoPoint(box.minX, box.minY),
  GeoPoint(box.maxX, box.minY),
  GeoPoint(box.maxX, box.maxY),
  GeoPoint(box.minX, box.maxY),
];

bool _onSegment(GeoPoint a, GeoPoint b, GeoPoint p) =>
    _turn(a, b, p) == 0 &&
    p.x >= math.min(a.x, b.x) &&
    p.x <= math.max(a.x, b.x) &&
    p.y >= math.min(a.y, b.y) &&
    p.y <= math.max(a.y, b.y);

bool _intersects(GeoPoint a, GeoPoint b, GeoPoint c, GeoPoint d) {
  final abC = _turn(a, b, c),
      abD = _turn(a, b, d),
      cdA = _turn(c, d, a),
      cdB = _turn(c, d, b);
  return (abC * abD < 0 && cdA * cdB < 0) ||
      _onSegment(a, b, c) ||
      _onSegment(a, b, d) ||
      _onSegment(c, d, a) ||
      _onSegment(c, d, b);
}

List<GeoPoint> _simplePolygon(List<GeoPoint> input) {
  _finite(input);
  final points = [...input];
  if (points.length > 1 && points.first == points.last) points.removeLast();
  if (points.length < 3 || points.toSet().length != points.length) {
    throw ArgumentError(
      'A polygon requires at least three distinct ordered vertices.',
    );
  }
  for (var i = 0; i < points.length; i++) {
    for (var j = i + 1; j < points.length; j++) {
      if (j == i + 1 || (i == 0 && j == points.length - 1)) continue;
      if (_intersects(
        points[i],
        points[(i + 1) % points.length],
        points[j],
        points[(j + 1) % points.length],
      )) {
        throw ArgumentError('Polygon edges must not self-intersect.');
      }
    }
  }
  return points;
}

List<GeometryTrace> bresenhamLine(int x0, int y0, int x1, int y1) {
  final start = GeoPoint(x0.toDouble(), y0.toDouble()),
      end = GeoPoint(x1.toDouble(), y1.toDouble());
  _finite([start, end]);
  final bounds = _bounds([start, end]),
      pixels = <GeoPoint>[],
      frames = <GeometryTrace>[];
  final dx = (x1 - x0).abs(),
      dy = -(y1 - y0).abs(),
      sx = x0 < x1 ? 1 : -1,
      sy = y0 < y1 ? 1 : -1;
  var x = x0, y = y0, error = dx + dy;
  void snap(String caption, {bool complete = false}) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      layers: [
        GeometryLayer('Ideal segment', [start, end], role: GeoRole.original),
        GeometryLayer(
          'Pixels',
          pixels,
          shape: GeoShape.pixels,
          role: GeoRole.result,
        ),
        GeometryLayer('Current pixel', [
          GeoPoint(x.toDouble(), y.toDouble()),
        ], shape: GeoShape.pixels),
      ],
      variables: {'x': x, 'y': y, 'error': error, 'dx': dx, 'dy': dy},
      output: complete ? pixels : [],
      result: complete
          ? '${pixels.length} connected integer pixels, including both endpoints.'
          : '',
    ),
  );
  snap('Use an integer error accumulator to choose each next grid cell.');
  while (true) {
    pixels.add(GeoPoint(x.toDouble(), y.toDouble()));
    snap(
      'Plot ($x, $y); doubled error ${2 * error} determines the next x/y steps.',
    );
    if (x == x1 && y == y1) break;
    final doubled = 2 * error;
    if (doubled >= dy) {
      error += dy;
      x += sx;
    }
    if (doubled <= dx) {
      error += dx;
      y += sy;
    }
  }
  snap('The destination pixel is reached.', complete: true);
  return frames;
}

List<GeometryTrace> midpointCircle(int cx, int cy, int radius) {
  if (radius < 0) throw ArgumentError('Radius must be nonnegative.');
  final center = GeoPoint(cx.toDouble(), cy.toDouble());
  _finite([
    center,
    GeoPoint(cx + radius.toDouble(), cy + radius.toDouble()),
    GeoPoint(cx - radius.toDouble(), cy - radius.toDouble()),
  ]);
  final bounds = _bounds([
    GeoPoint(cx - radius.toDouble(), cy - radius.toDouble()),
    GeoPoint(cx + radius.toDouble(), cy + radius.toDouble()),
  ]);
  final ideal = List.generate(
    65,
    (i) => GeoPoint(
      cx + radius * math.cos(2 * math.pi * i / 64),
      cy + radius * math.sin(2 * math.pi * i / 64),
    ),
  );
  final pixels = <GeoPoint>{}, frames = <GeometryTrace>[];
  var x = 0, y = radius, decision = 1 - radius;
  var octants = <GeoPoint>[];
  void snap(String caption, {bool complete = false}) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      layers: [
        GeometryLayer('Ideal circle', ideal, role: GeoRole.original),
        GeometryLayer(
          'Circle pixels',
          pixels,
          shape: GeoShape.pixels,
          role: GeoRole.result,
        ),
        GeometryLayer('Eightfold step', octants, shape: GeoShape.pixels),
      ],
      variables: {
        'octant x': x,
        'octant y': y,
        'decision': decision,
        'radius': radius,
      },
      output: complete ? pixels : [],
      result: complete
          ? '${pixels.length} unique pixels generated by eightfold symmetry.'
          : '',
    ),
  );
  snap('Compute one octant; reflect every selected cell into the other seven.');
  while (x <= y) {
    octants = [
      for (final (dx, dy) in [
        (x, y),
        (y, x),
        (-x, y),
        (-y, x),
        (x, -y),
        (y, -x),
        (-x, -y),
        (-y, -x),
      ])
        GeoPoint((cx + dx).toDouble(), (cy + dy).toDouble()),
    ];
    pixels.addAll(octants);
    snap(
      'Reflect ($x, $y); decision $decision chooses east or southeast in the next octant step.',
    );
    x++;
    if (decision < 0) {
      decision += 2 * x + 1;
    } else {
      y--;
      decision += 2 * (x - y) + 1;
    }
  }
  octants = [];
  snap(
    'The octant boundary is crossed; symmetry completes the circle.',
    complete: true,
  );
  return frames;
}

List<GeometryTrace> cohenSutherlandClip(
  GeoPoint start,
  GeoPoint end,
  GeoBox window,
) {
  _finite([start, end]);
  _window(window);
  var a = start, b = end;
  final frames = <GeometryTrace>[],
      bounds = _bounds([start, end, ..._corners(window)]);
  int code(GeoPoint p) =>
      (p.x < window.minX ? 1 : 0) |
      (p.x > window.maxX ? 2 : 0) |
      (p.y < window.minY ? 4 : 0) |
      (p.y > window.maxY ? 8 : 0);
  void snap(String caption, {bool? accepted}) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      clipWindow: window,
      layers: [
        GeometryLayer('Original', [start, end], role: GeoRole.original),
        GeometryLayer(
          accepted == true ? 'Accepted' : 'Working segment',
          accepted == false ? [] : [a, b],
          role: accepted == true ? GeoRole.result : GeoRole.working,
        ),
      ],
      variables: {
        'A region': code(a).toRadixString(2).padLeft(4, '0'),
        'B region': code(b).toRadixString(2).padLeft(4, '0'),
        'bits': 'top bottom right left',
      },
      output: accepted == true ? [a, b] : [],
      value: accepted == null
          ? null
          : accepted
          ? 1
          : 0,
      result: accepted == null
          ? ''
          : accepted
          ? 'Accepted segment lies inside the clipping window.'
          : 'Rejected: no segment lies inside the window.',
    ),
  );
  snap('Classify each endpoint by a four-bit region code.');
  while (true) {
    final ca = code(a), cb = code(b);
    if ((ca | cb) == 0) {
      snap('Both region codes are zero: trivially accept.', accepted: true);
      break;
    }
    if ((ca & cb) != 0) {
      snap(
        'A shared outside bit proves the entire segment is outside.',
        accepted: false,
      );
      break;
    }
    final outside = ca != 0 ? ca : cb;
    late GeoPoint intersection;
    late String edge;
    if ((outside & 8) != 0) {
      edge = 'top';
      intersection = GeoPoint(
        a.x + (b.x - a.x) * (window.maxY - a.y) / (b.y - a.y),
        window.maxY,
      );
    } else if ((outside & 4) != 0) {
      edge = 'bottom';
      intersection = GeoPoint(
        a.x + (b.x - a.x) * (window.minY - a.y) / (b.y - a.y),
        window.minY,
      );
    } else if ((outside & 2) != 0) {
      edge = 'right';
      intersection = GeoPoint(
        window.maxX,
        a.y + (b.y - a.y) * (window.maxX - a.x) / (b.x - a.x),
      );
    } else {
      edge = 'left';
      intersection = GeoPoint(
        window.minX,
        a.y + (b.y - a.y) * (window.minX - a.x) / (b.x - a.x),
      );
    }
    if (outside == ca) {
      a = intersection;
    } else {
      b = intersection;
    }
    snap(
      'Replace the outside endpoint by its $edge-boundary intersection, then recalculate its region code.',
    );
  }
  return frames;
}

List<GeometryTrace> sutherlandHodgmanClip(List<GeoPoint> input, GeoBox window) {
  _window(window);
  final polygon = _simplePolygon(input),
      bounds = _bounds([...input, ..._corners(window)]),
      frames = <GeometryTrace>[];
  var current = [...polygon], output = <GeoPoint>[];
  var edgeName = 'start';
  bool inside(GeoPoint p, int edge) => switch (edge) {
    0 => p.x >= window.minX,
    1 => p.x <= window.maxX,
    2 => p.y >= window.minY,
    _ => p.y <= window.maxY,
  };
  GeoPoint intersection(GeoPoint a, GeoPoint b, int edge) {
    if (edge < 2) {
      final x = edge == 0 ? window.minX : window.maxX;
      return GeoPoint(x, a.y + (b.y - a.y) * (x - a.x) / (b.x - a.x));
    }
    final y = edge == 2 ? window.minY : window.maxY;
    return GeoPoint(a.x + (b.x - a.x) * (y - a.y) / (b.y - a.y), y);
  }

  void snap(
    String caption, {
    List<GeoPoint> segment = const [],
    bool complete = false,
  }) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      clipWindow: window,
      layers: [
        GeometryLayer(
          'Original',
          polygon,
          shape: GeoShape.polygon,
          role: GeoRole.original,
        ),
        GeometryLayer(
          'Current polygon',
          current,
          shape: GeoShape.polygon,
          role: GeoRole.guide,
        ),
        GeometryLayer(
          'Emitted vertices',
          output,
          shape: GeoShape.polygon,
          role: GeoRole.result,
        ),
        GeometryLayer('Current edge', segment),
      ],
      variables: {
        'clipping boundary': edgeName,
        'input vertices': current.length,
        'output vertices': output.length,
      },
      output: complete ? current : [],
      result: complete ? 'Clipped polygon: ${current.length} vertices.' : '',
    ),
  );
  snap('Clip the polygon successively against four inside half-planes.');
  for (var edge = 0; edge < 4; edge++) {
    edgeName = ['left', 'right', 'bottom', 'top'][edge];
    output = [];
    if (current.isNotEmpty) {
      var previous = current.last;
      for (final point in current) {
        final aInside = inside(previous, edge), bInside = inside(point, edge);
        if (aInside != bInside) output.add(intersection(previous, point, edge));
        if (bInside) output.add(point);
        snap(
          aInside && bInside
              ? 'Inside → inside: emit the endpoint.'
              : aInside
              ? 'Inside → outside: emit only the exit intersection.'
              : bInside
              ? 'Outside → inside: emit the entry intersection and endpoint.'
              : 'Outside → outside: emit nothing.',
          segment: [previous, point],
        );
        previous = point;
      }
    }
    final clean = <GeoPoint>[];
    for (final point in output) {
      if (clean.isEmpty || clean.last != point) {
        clean.add(point);
      }
    }
    if (clean.length > 1 && clean.first == clean.last) {
      clean.removeLast();
    }
    current = clean;
    snap(
      'The $edgeName boundary is complete; its output becomes the next input.',
    );
  }
  output = [...current];
  snap('All four boundaries are satisfied.', complete: true);
  return frames;
}

double _segmentDistance(GeoPoint p, GeoPoint a, GeoPoint b) {
  final length2 = a.distanceSquared(b);
  if (length2 == 0) return math.sqrt(p.distanceSquared(a));
  final t = (((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / length2)
      .clamp(0.0, 1.0);
  return math.sqrt(p.distanceSquared(a + (b - a) * t));
}

List<GeometryTrace> ramerDouglasPeucker(
  List<GeoPoint> input,
  double tolerance,
) {
  _finite(input);
  if (!tolerance.isFinite || tolerance < 0) {
    throw ArgumentError('Tolerance must be finite and nonnegative.');
  }
  final bounds = _bounds(input), frames = <GeometryTrace>[], kept = <int>{};
  if (input.isNotEmpty) kept.addAll([0, input.length - 1]);
  List<GeoPoint> retained() =>
      (kept.toList()..sort()).map((i) => input[i]).toList();
  void snap(
    String caption, {
    List<GeoPoint> chord = const [],
    List<GeoPoint> farthest = const [],
    double? distance,
    bool complete = false,
  }) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      layers: [
        GeometryLayer('Original path', input, role: GeoRole.original),
        GeometryLayer('Retained path', retained(), role: GeoRole.result),
        GeometryLayer('Test chord', chord, role: GeoRole.guide),
        GeometryLayer('Farthest point', farthest, shape: GeoShape.points),
      ],
      variables: {
        'tolerance': tolerance,
        'maximum distance': distance?.toStringAsFixed(3) ?? '—',
        'retained': kept.length,
      },
      output: complete ? retained() : [],
      result: complete
          ? 'Simplified ${input.length} points to ${kept.length} within tolerance $tolerance.'
          : '',
    ),
  );
  snap('Keep endpoints; split where the farthest point exceeds the tolerance.');
  void simplify(int first, int last) {
    if (last <= first + 1) return;
    var farthest = first, distance = -1.0;
    for (var i = first + 1; i < last; i++) {
      final d = _segmentDistance(input[i], input[first], input[last]);
      if (d > distance) {
        farthest = i;
        distance = d;
      }
      snap(
        'Measure point $i against the candidate shortcut segment.',
        chord: [input[first], input[last]],
        farthest: [input[farthest]],
        distance: distance,
      );
    }
    if (distance > tolerance) {
      kept.add(farthest);
      snap(
        'Distance ${distance.toStringAsFixed(3)} exceeds tolerance: keep point $farthest and split.',
        chord: [input[first], input[last]],
        farthest: [input[farthest]],
        distance: distance,
      );
      simplify(first, farthest);
      simplify(farthest, last);
    } else {
      snap(
        'Every intermediate point lies within tolerance; accept the shortcut.',
        chord: [input[first], input[last]],
        distance: distance,
      );
    }
  }

  if (input.length > 1) simplify(0, input.length - 1);
  snap('Every retained segment passes the distance test.', complete: true);
  return frames;
}

List<GeometryTrace> deCasteljauBezier(
  List<GeoPoint> controls, {
  int steps = 12,
}) {
  _finite(controls);
  if (controls.isEmpty || steps < 1) {
    throw ArgumentError(
      'At least one control point and one sampling step are required.',
    );
  }
  final bounds = _bounds(controls),
      frames = <GeometryTrace>[],
      curve = <GeoPoint>[];
  var t = 0.0, level = 0;
  var construction = <List<GeoPoint>>[];
  void snap(String caption, {bool complete = false}) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      layers: [
        GeometryLayer('Control polygon', controls, role: GeoRole.original),
        for (var i = 0; i < construction.length; i++)
          GeometryLayer(
            i == construction.length - 1 ? 'Current level' : 'Interpolation',
            construction[i],
            role: i == construction.length - 1
                ? GeoRole.working
                : GeoRole.guide,
          ),
        GeometryLayer('Curve samples', curve, role: GeoRole.result),
      ],
      variables: {
        't': t.toStringAsFixed(3),
        'level': level,
        'degree': controls.length - 1,
        'samples': curve.length,
      },
      output: complete ? curve : [],
      result: complete
          ? '${curve.length} Bézier samples from repeated linear interpolation.'
          : '',
    ),
  );
  snap('At each t, interpolate adjacent points until one curve point remains.');
  for (var step = 0; step <= steps; step++) {
    t = step / steps;
    level = 0;
    construction = [];
    var points = [...controls];
    while (points.length > 1) {
      points = [
        for (var i = 0; i < points.length - 1; i++)
          points[i] * (1 - t) + points[i + 1] * t,
      ];
      construction.add(points);
      level++;
      snap('Level $level: each point is (1−t)·left + t·right.');
    }
    curve.add(points.single);
    snap(
      'Append the interpolated point at t=${t.toStringAsFixed(3)} to the curve.',
    );
  }
  snap('Sampling includes both endpoint control points.', complete: true);
  return frames;
}

List<GeometryTrace> shoelaceArea(List<GeoPoint> input) {
  final polygon = _simplePolygon(input),
      bounds = _bounds(input),
      frames = <GeometryTrace>[];
  final origin = polygon.first;
  var sum = 0.0, correction = 0.0, forward = 0.0, backward = 0.0, edge = -1;
  void snap(String caption, {bool complete = false}) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      layers: [
        GeometryLayer(
          'Polygon',
          polygon,
          shape: GeoShape.polygon,
          role: GeoRole.original,
        ),
        if (edge >= 0)
          GeometryLayer(
            'Signed triangle',
            [origin, polygon[edge], polygon[(edge + 1) % polygon.length]],
            shape: GeoShape.polygon,
            role: GeoRole.guide,
          ),
        if (edge >= 0)
          GeometryLayer('Current edge', [
            polygon[edge],
            polygon[(edge + 1) % polygon.length],
          ]),
        if (complete)
          GeometryLayer(
            'Area',
            polygon,
            shape: GeoShape.polygon,
            role: GeoRole.result,
          ),
      ],
      variables: {
        'local origin': origin,
        'x′ᵢ × y′ᵢ₊₁': forward,
        'y′ᵢ × x′ᵢ₊₁': backward,
        'signed double area': sum,
      },
      output: complete ? polygon : [],
      value: complete ? sum.abs() / 2 : null,
      result: complete
          ? 'Area = |${sum.toStringAsFixed(3)}| ÷ 2 = ${(sum.abs() / 2).toStringAsFixed(3)} square units.'
          : '',
    ),
  );
  snap(
    'Use vertex 0 as a local origin to avoid cancelling large coordinates; '
    'translation preserves area. Sum every edge, including the closing edge.',
  );
  for (edge = 0; edge < polygon.length; edge++) {
    final a = polygon[edge] - origin,
        b = polygon[(edge + 1) % polygon.length] - origin;
    forward = a.x * b.y;
    backward = a.y * b.x;
    final adjusted = forward - backward - correction;
    final next = sum + adjusted;
    correction = (next - sum) - adjusted;
    sum = next;
    snap(
      'Edge $edge contributes $forward − $backward = ${forward - backward}.',
    );
  }
  edge = -1;
  snap('Take the absolute signed sum and divide by two.', complete: true);
  return frames;
}

/// Diameter of a simple convex polygon in boundary order. Collinear boundary
/// vertices are removed; clockwise input is normalized. Validation is O(n²),
/// followed by the O(n) antipodal-pair scan (rather than all-pairs search).
List<GeometryTrace> rotatingCalipersDiameter(List<GeoPoint> input) {
  var polygon = _simplePolygon(input);
  final signed = _signedDoubleArea(polygon);
  if (signed == 0) {
    throw ArgumentError('A convex polygon must have nonzero area.');
  }
  final orientation = signed > 0 ? 1 : -1;
  for (var i = 0; i < polygon.length; i++) {
    if (_turn(
              polygon[i],
              polygon[(i + 1) % polygon.length],
              polygon[(i + 2) % polygon.length],
            ) *
            orientation <
        0) {
      throw ArgumentError(
        'Diameter input must be convex and in boundary order.',
      );
    }
  }
  polygon = [
    for (var i = 0; i < polygon.length; i++)
      if (_turn(
            polygon[(i - 1 + polygon.length) % polygon.length],
            polygon[i],
            polygon[(i + 1) % polygon.length],
          ) !=
          0)
        polygon[i],
  ];
  if (polygon.length < 3) {
    throw ArgumentError(
      'A convex polygon requires three noncollinear vertices.',
    );
  }
  if (orientation < 0) polygon = polygon.reversed.toList();
  final bounds = _bounds(polygon), frames = <GeometryTrace>[];
  var i = 0, j = 1, bestA = 0, bestB = 1;
  var best = polygon[0].distanceSquared(polygon[1]);
  void snap(String caption, {bool complete = false}) => frames.add(
    GeometryTrace(
      caption: caption,
      bounds: bounds,
      layers: [
        GeometryLayer(
          'Convex polygon',
          polygon,
          shape: GeoShape.polygon,
          role: GeoRole.original,
        ),
        GeometryLayer(
          'Antipodal area',
          [polygon[i], polygon[(i + 1) % polygon.length], polygon[j]],
          shape: GeoShape.polygon,
          role: GeoRole.guide,
        ),
        GeometryLayer('Candidate pair', [polygon[i], polygon[j]]),
        GeometryLayer('Best diameter', [
          polygon[bestA],
          polygon[bestB],
        ], role: GeoRole.result),
      ],
      variables: {
        'edge start': i,
        'opposite vertex': j,
        'double triangle area': _cross(
          polygon[i],
          polygon[(i + 1) % polygon.length],
          polygon[j],
        ).toStringAsFixed(3),
        'best distance': math.sqrt(best).toStringAsFixed(3),
      },
      output: complete ? [polygon[bestA], polygon[bestB]] : [],
      value: complete ? math.sqrt(best) : null,
      result: complete
          ? 'Polygon diameter: ${math.sqrt(best).toStringAsFixed(3)} units.'
          : '',
    ),
  );
  snap(
    'Advance the opposite vertex while its distance from the current edge increases.',
  );
  void consider(int a, int b) {
    final distance = polygon[a].distanceSquared(polygon[b]);
    if (distance > best) {
      best = distance;
      bestA = a;
      bestB = b;
    }
  }

  for (i = 0; i < polygon.length; i++) {
    final next = (i + 1) % polygon.length;
    int areaChange() => _crossSign(
      polygon[next] - polygon[i],
      polygon[(j + 1) % polygon.length] - polygon[j],
    );
    while (areaChange() > 0) {
      j = (j + 1) % polygon.length;
      snap('Advance the opposite contact: triangle area increases.');
    }
    consider(i, j);
    consider(next, j);
    if (areaChange() == 0) {
      consider(i, (j + 1) % polygon.length);
      consider(next, (j + 1) % polygon.length);
    }
    snap(
      'Test both endpoints of the supporting edge against its antipodal contacts.',
    );
  }
  i = bestA;
  j = bestB;
  snap(
    'Every supporting edge has been processed; the farthest antipodal pair wins.',
    complete: true,
  );
  return frames;
}
