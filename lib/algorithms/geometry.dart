import 'dart:math';

import '../models/frames.dart';

// A fixed scatter of points (normalized 0..1) for the convex-hull demo.
const _points = [
  [0.15, 0.55],
  [0.30, 0.20],
  [0.50, 0.72],
  [0.70, 0.25],
  [0.86, 0.58],
  [0.45, 0.42],
  [0.25, 0.82],
  [0.60, 0.50],
  [0.80, 0.85],
  [0.38, 0.60],
  [0.55, 0.16],
  [0.90, 0.40],
];

/// Convex hull via Andrew's monotone chain: sort the points, then sweep to build
/// the lower and upper hulls, popping any point that would make a non-left turn.
List<HullFrame> convexHull() {
  final pts = _points;
  final idx = [for (var i = 0; i < pts.length; i++) i]
    ..sort((a, b) => pts[a][0] != pts[b][0] ? pts[a][0].compareTo(pts[b][0]) : pts[a][1].compareTo(pts[b][1]));

  // Cross product of OA x OB; > 0 means a counter-clockwise (left) turn.
  double cross(int o, int a, int b) =>
      (pts[a][0] - pts[o][0]) * (pts[b][1] - pts[o][1]) - (pts[a][1] - pts[o][1]) * (pts[b][0] - pts[o][0]);

  final frames = <HullFrame>[
    HullFrame(points: pts, hull: const [], caption: 'Sort the points left to right, then sweep to build the hull.'),
  ];
  final hull = <int>[];

  void build(List<int> order, int base) {
    for (final p in order) {
      while (hull.length > base && cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
        frames.add(HullFrame(points: pts, hull: [...hull], current: p, caption: 'Not a left turn - pop the last hull point.'));
        hull.removeLast();
      }
      hull.add(p);
      frames.add(HullFrame(points: pts, hull: [...hull], current: p, caption: 'Add the point to the hull.'));
    }
  }

  build(idx, 1); // lower hull
  final lowerSize = hull.length + 1;
  build([for (var i = idx.length - 2; i >= 0; i--) idx[i]], lowerSize); // upper hull
  hull.removeLast(); // drop the duplicated start point

  frames.add(HullFrame(points: pts, hull: [...hull], closed: true, caption: 'Convex hull complete - ${hull.length} vertices enclose every point.'));
  return frames;
}

// A fixed scatter of points for the closest-pair demo.
const _cpPoints = [
  [0.12, 0.30],
  [0.22, 0.65],
  [0.40, 0.20],
  [0.48, 0.55],
  [0.55, 0.58],
  [0.70, 0.30],
  [0.82, 0.70],
  [0.90, 0.40],
];

/// Closest pair of points (brute force): check every pair, keep the smallest
/// separation seen so far, and draw the current best pair as a line. (The
/// classic divide-and-conquer version reaches O(n log n).)
List<HullFrame> closestPair() {
  final pts = _cpPoints;
  double d2(int i, int j) {
    final dx = pts[i][0] - pts[j][0];
    final dy = pts[i][1] - pts[j][1];
    return dx * dx + dy * dy;
  }

  var bestA = 0, bestB = 1;
  var bestD = double.infinity;
  final frames = <HullFrame>[
    HullFrame(points: pts, hull: const [], caption: 'Find the two closest points by checking every pair.'),
  ];

  for (var i = 0; i < pts.length; i++) {
    for (var j = i + 1; j < pts.length; j++) {
      final dd = d2(i, j);
      frames.add(HullFrame(
        points: pts,
        hull: bestD == double.infinity ? const [] : [bestA, bestB],
        current: j,
        caption: 'Measure points $i and $j.',
      ));
      if (dd < bestD) {
        bestD = dd;
        bestA = i;
        bestB = j;
        frames.add(HullFrame(
          points: pts,
          hull: [bestA, bestB],
          current: j,
          caption: 'New closest pair: $i and $j.',
        ));
      }
    }
  }

  frames.add(HullFrame(
    points: pts,
    hull: [bestA, bestB],
    current: bestA,
    caption: 'Closest pair is $bestA and $bestB, distance ${sqrt(bestD).toStringAsFixed(3)}.',
  ));
  return frames;
}

// A scatter for the Graham scan demo.
const _grahamPoints = [
  [0.50, 0.05],
  [0.20, 0.30],
  [0.80, 0.28],
  [0.12, 0.62],
  [0.88, 0.60],
  [0.30, 0.88],
  [0.70, 0.86],
  [0.50, 0.50],
  [0.40, 0.40],
  [0.62, 0.45],
];

/// Convex hull via the Graham scan: sort points by polar angle around the
/// lowest point, then sweep, popping any point that makes a non-left turn.
List<HullFrame> grahamScan() {
  final pts = _grahamPoints;
  // Pivot = lowest y (then lowest x).
  var pivot = 0;
  for (var i = 1; i < pts.length; i++) {
    if (pts[i][1] > pts[pivot][1] || (pts[i][1] == pts[pivot][1] && pts[i][0] < pts[pivot][0])) {
      pivot = i;
    }
  }
  final order = [for (var i = 0; i < pts.length; i++) i]..remove(pivot);
  double ang(int i) => atan2(pts[i][1] - pts[pivot][1], pts[i][0] - pts[pivot][0]);
  order.sort((a, b) => ang(a).compareTo(ang(b)));

  double cross(int o, int a, int b) =>
      (pts[a][0] - pts[o][0]) * (pts[b][1] - pts[o][1]) - (pts[a][1] - pts[o][1]) * (pts[b][0] - pts[o][0]);

  final hull = <int>[pivot];
  final frames = <HullFrame>[
    HullFrame(points: pts, hull: [pivot], current: pivot, caption: 'Start at the lowest point; sort the rest by angle.'),
  ];
  for (final p in order) {
    while (hull.length >= 2 && cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
      frames.add(HullFrame(points: pts, hull: [...hull], current: p, caption: 'Non-left turn — pop the last hull point.'));
      hull.removeLast();
    }
    hull.add(p);
    frames.add(HullFrame(points: pts, hull: [...hull], current: p, caption: 'Add the point to the hull.'));
  }
  frames.add(HullFrame(points: pts, hull: [...hull], closed: true, caption: 'Graham scan complete — ${hull.length} hull vertices.'));
  return frames;
}

// A fixed polygon (vertices in order) plus a test point for point-in-polygon.
const _polygon = [
  [0.20, 0.25],
  [0.55, 0.12],
  [0.85, 0.40],
  [0.72, 0.80],
  [0.30, 0.75],
];
const _testPoint = [0.50, 0.50];

/// Point-in-polygon by ray casting: shoot a ray from the test point and count
/// how many polygon edges it crosses — odd means inside, even means outside.
List<HullFrame> pointInPolygon() {
  final pts = [..._polygon.map((p) => [p[0], p[1]]), [_testPoint[0], _testPoint[1]]];
  final n = _polygon.length;
  final tIdx = n; // index of the test point
  final px = _testPoint[0], py = _testPoint[1];

  final frames = <HullFrame>[
    HullFrame(points: pts, hull: [for (var i = 0; i < n; i++) i], closed: true, current: tIdx, caption: 'Cast a ray from the test point and count edge crossings.'),
  ];

  var crossings = 0;
  for (var i = 0, j = n - 1; i < n; j = i++) {
    final xi = _polygon[i][0], yi = _polygon[i][1];
    final xj = _polygon[j][0], yj = _polygon[j][1];
    final intersects = ((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi);
    if (intersects) crossings++;
    frames.add(HullFrame(
      points: pts,
      hull: [for (var k = 0; k < n; k++) k],
      closed: true,
      current: tIdx,
      caption: 'Edge ${j + 1}→${i + 1}: ${intersects ? 'crosses the ray' : 'no crossing'} (count $crossings).',
    ));
  }
  final inside = crossings.isOdd;
  frames.add(HullFrame(
    points: pts,
    hull: [for (var k = 0; k < n; k++) k],
    closed: true,
    current: tIdx,
    caption: '$crossings crossings → the point is ${inside ? 'inside' : 'outside'} the polygon.',
  ));
  return frames;
}
