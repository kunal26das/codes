import 'dart:convert';
import 'dart:math' as math;

import 'package:algoscope/algorithms/pathfinding.dart';
import 'package:algoscope/data/catalog.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/models/geometry_trace.dart';
import 'package:algoscope/models/graph_trace.dart';
import 'package:algoscope/models/sequence_trace.dart';
import 'package:algoscope/visualizers/graph_trace_view.dart';
import 'package:algoscope/visualizers/graph_view.dart';
import 'package:algoscope/visualizers/grid_view.dart';
import 'package:algoscope/visualizers/hanoi_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// This suite inspects the data actually handed to catalog visualizers. It does
// not infer correctness from captions, and deliberately includes every frame.
void _indices(Iterable<int> indices, int length, String label) {
  for (final index in indices) {
    expect(index, inInclusiveRange(0, length - 1), reason: label);
  }
}

void _optionalIndex(int? index, int length, String label) {
  if (index != null) _indices([index], length, label);
}

void _point(List<double> point, String label, {bool normalized = true}) {
  expect(point.length, 2, reason: label);
  for (final value in point) {
    expect(value.isFinite, isTrue, reason: label);
    if (normalized) expect(value, inInclusiveRange(0.0, 1.0), reason: label);
  }
}

void _rectangular(List<List<int>> cells, int rows, int cols, String label) {
  expect(rows, greaterThanOrEqualTo(0), reason: label);
  expect(cols, greaterThanOrEqualTo(0), reason: label);
  expect(cells.length, rows, reason: label);
  for (final row in cells) {
    expect(row.length, cols, reason: label);
  }
}

void _connectedTree(Map<int, List<int>> children, int? root, String label) {
  // Empty initial snapshots in general-tree views use rootId=0 as a sentinel.
  if (children.isEmpty) return;
  expect(root, isNotNull, reason: label);
  final reached = <int>{};
  void visit(int id) {
    expect(
      children.containsKey(id),
      isTrue,
      reason: '$label: dangling node $id',
    );
    expect(
      reached.add(id),
      isTrue,
      reason: '$label: repeated child or cycle at $id',
    );
    for (final child in children[id]!) {
      visit(child);
    }
  }

  visit(root!);
  expect(
    reached,
    children.keys.toSet(),
    reason: '$label: detached serialized nodes',
  );
}

void _graph(
  GraphRun run,
  GraphFrame frame,
  String label, {
  List<GraphEdge>? edges,
}) {
  final n = run.nodeLabels.length;
  expect(run.positions.length, n, reason: label);
  for (final position in run.positions) {
    _point(position, label);
  }
  final visible = edges ?? run.edges;
  final keys = <int>{};
  for (final edge in visible) {
    _indices([edge.a, edge.b], n, label);
    expect(
      keys.add(edge.key),
      isTrue,
      reason: '$label: duplicate edge identity',
    );
    expect(
      edge.directed,
      run.directed,
      reason: '$label: edge/run direction mismatch',
    );
  }
  _indices(
    [...frame.inTree, ...frame.order, ...frame.colors.keys, ...frame.dist.keys],
    n,
    label,
  );
  _optionalIndex(frame.current, n, label);
  expect(
    keys.containsAll(frame.treeEdges),
    isTrue,
    reason: '$label: highlighted edges must exist',
  );
  if (frame.candidate != null) {
    expect(keys.contains(frame.candidate), isTrue, reason: label);
  }
  for (final color in frame.colors.values) {
    expect(color, greaterThanOrEqualTo(0), reason: label);
  }
}

void _grid(GridRun run, GridFrame frame, String label) {
  expect(run.rows, greaterThan(0), reason: label);
  expect(run.cols, greaterThan(0), reason: label);
  final n = run.rows * run.cols;
  _indices(
    [
      run.start,
      run.goal,
      ...run.walls,
      ...frame.open,
      ...frame.closed,
      ...frame.path,
    ],
    n,
    label,
  );
  _optionalIndex(frame.current, n, label);
  expect(
    run.walls.contains(run.start) || run.walls.contains(run.goal),
    isFalse,
    reason: label,
  );
  expect(
    {...frame.open, ...frame.closed, ...frame.path}.intersection(run.walls),
    isEmpty,
    reason: '$label: search cannot occupy a wall',
  );
  if (frame.current != null) {
    expect(run.walls.contains(frame.current), isFalse, reason: label);
  }
  expect(frame.open.intersection(frame.closed), isEmpty, reason: label);
  expect(
    frame.path.toSet().length,
    frame.path.length,
    reason: '$label: path must be simple',
  );
  if (frame.path.isNotEmpty) expect(frame.path.first, run.start, reason: label);
  for (var i = 1; i < frame.path.length; i++) {
    final a = frame.path[i - 1], b = frame.path[i];
    expect(
      (a ~/ run.cols - b ~/ run.cols).abs() +
          (a % run.cols - b % run.cols).abs(),
      1,
      reason: '$label: nonadjacent path cells',
    );
  }
}

void _validate(Object frame, Widget view, String label) {
  switch (frame) {
    case final ArrayFrame f:
      _indices(
        {...f.comparing, ...f.active, ...f.done},
        f.values.length,
        label,
      );
      _optionalIndex(f.pivot, f.values.length, label);
      // Search windows may be exhausted: lo==n and hi==-1 are valid sentinels.
      if (f.windowLo != null) {
        expect(f.windowLo, inInclusiveRange(0, f.values.length), reason: label);
      }
      if (f.windowHi != null) {
        expect(
          f.windowHi,
          inInclusiveRange(-1, f.values.length - 1),
          reason: label,
        );
      }
    case final TreeFrame f:
      final children = {
        for (final node in f.nodes)
          node.id: [
            if (node.left != null) node.left!,
            if (node.right != null) node.right!,
          ],
      };
      expect(children.length, f.nodes.length, reason: label);
      _connectedTree(children, f.rootId, label);
      expect(
        children.keys.toSet().containsAll(f.highlight),
        isTrue,
        reason: label,
      );
    case final GTreeFrame f:
      final children = {for (final node in f.nodes) node.id: node.children};
      expect(children.length, f.nodes.length, reason: label);
      _connectedTree(children, f.rootId, label);
    case final TrieFrame f:
      final children = {for (final node in f.nodes) node.id: node.children};
      expect(children.length, f.nodes.length, reason: label);
      _connectedTree(children, f.rootId, label);
      expect(
        children.keys.toSet().containsAll(f.highlight),
        isTrue,
        reason: label,
      );
    case final GridFrame f:
      expect(view, isA<GridView2D>());
      _grid((view as GridView2D).run, f, label);
    case final GraphFrame f:
      expect(view, isA<GraphView>());
      _graph((view as GraphView).run, f, label);
    case final GraphTraceFrame f:
      expect(view, isA<GraphTraceView>());
      _graph(
        (view as GraphTraceView).run.graph,
        f.graph,
        label,
        edges: f.edges,
      );
      for (final row in f.rows) {
        expect(
          row.length,
          f.columns.length,
          reason: '$label: bookkeeping table columns',
        );
      }
    case final BoardFrame f:
      expect(f.n, greaterThan(0), reason: label);
      expect(f.queens.length, f.n, reason: label);
      for (final column in f.queens) {
        expect(column, inInclusiveRange(-1, f.n - 1), reason: label);
      }
      _optionalIndex(f.tryRow, f.n, label);
      _optionalIndex(f.tryCol, f.n, label);
      for (var a = 0; a < f.n; a++) {
        if (f.queens[a] == -1) continue;
        for (var b = a + 1; b < f.n; b++) {
          if (f.queens[b] == -1) continue;
          expect(f.queens[a], isNot(f.queens[b]), reason: label);
          expect(
            (f.queens[a] - f.queens[b]).abs(),
            isNot(b - a),
            reason: label,
          );
        }
      }
      if (f.solved) expect(f.queens.contains(-1), isFalse, reason: label);
    case final HanoiFrame f:
      final diskCount = (view as HanoiView).diskCount;
      expect(f.pegs.length, 3, reason: label);
      final disks = f.pegs.expand((peg) => peg).toList()..sort();
      expect(disks, [
        for (var d = 1; d <= diskCount; d++) d,
      ], reason: '$label: disks must be conserved');
      for (final peg in f.pegs) {
        for (var i = 1; i < peg.length; i++) {
          expect(
            peg[i],
            lessThan(peg[i - 1]),
            reason: '$label: larger disk above smaller disk',
          );
        }
      }
      _optionalIndex(f.fromPeg, 3, label);
      _optionalIndex(f.toPeg, 3, label);
      if (f.movingDisk != null) {
        expect(f.movingDisk, inInclusiveRange(1, diskCount), reason: label);
        expect(f.pegs[f.toPeg!].last, f.movingDisk, reason: label);
      }
    case final KnightFrame f:
      expect(f.n, greaterThan(0), reason: label);
      expect(f.board.length, f.n * f.n, reason: label);
      _optionalIndex(f.current, f.board.length, label);
      _optionalIndex(f.tryCell, f.board.length, label);
      final at = <int, int>{};
      for (var cell = 0; cell < f.board.length; cell++) {
        final order = f.board[cell];
        expect(order, inInclusiveRange(0, f.board.length), reason: label);
        if (order != 0) {
          expect(at.containsKey(order), isFalse, reason: label);
          at[order] = cell;
        }
      }
      expect(at.keys.toSet(), {
        for (var step = 1; step <= at.length; step++) step,
      }, reason: label);
      for (var step = 2; step <= at.length; step++) {
        final a = at[step - 1]!, b = at[step]!;
        final dr = (a ~/ f.n - b ~/ f.n).abs(), dc = (a % f.n - b % f.n).abs();
        expect({dr, dc}, {1, 2}, reason: '$label: illegal knight move');
      }
      if (f.solved) expect(at.length, f.board.length, reason: label);
    case final TableFrame f:
      _rectangular(f.cells, f.rows, f.cols, label);
      expect(f.rowHeader.length, lessThanOrEqualTo(f.rows), reason: label);
      expect(f.colHeader.length, lessThanOrEqualTo(f.cols), reason: label);
      _indices({...f.refs, ...f.filled}, f.rows * f.cols, label);
      _optionalIndex(f.activeR, f.rows, label);
      _optionalIndex(f.activeC, f.cols, label);
    case final MatrixFrame f:
      for (final matrix in [f.a, f.b, f.c]) {
        expect(matrix, isNotEmpty, reason: label);
        expect(matrix.first, isNotEmpty, reason: label);
        _rectangular(matrix, matrix.length, matrix.first.length, label);
      }
      _indices(f.aRows, f.a.length, label);
      _indices(f.aCols, f.a.first.length, label);
      _indices(f.bRows, f.b.length, label);
      _indices(f.bCols, f.b.first.length, label);
      _indices(f.filled, f.c.length * f.c.first.length, label);
      _optionalIndex(f.activeR, f.c.length, label);
      _optionalIndex(f.activeC, f.c.first.length, label);
    case final NumberGridFrame f:
      expect(f.maxN, greaterThanOrEqualTo(2), reason: label);
      _indices({...f.marked, ...f.primes}, f.maxN + 1, label);
      _optionalIndex(f.current, f.maxN + 1, label);
      _optionalIndex(f.multiplesOf, f.maxN + 1, label);
      expect(f.marked.intersection(f.primes), isEmpty, reason: label);
      bool isPrime(int value) =>
          value >= 2 &&
          ![
            for (var d = 2; d * d <= value; d++) d,
          ].any((divisor) => value % divisor == 0);
      expect(f.primes.every(isPrime), isTrue, reason: label);
      expect(
        f.marked.every((n) => n >= 2 && !isPrime(n)),
        isTrue,
        reason: label,
      );
    case final PascalFrame f:
      for (var r = 0; r < f.rows.length; r++) {
        expect(f.rows[r].length, r + 1, reason: label);
        var binomial = 1;
        for (var c = 0; c <= r; c++) {
          final value = f.rows[r][c];
          expect(value, greaterThanOrEqualTo(-1), reason: label);
          if (value != -1) expect(value, binomial, reason: label);
          binomial = binomial * (r - c) ~/ (c + 1);
        }
      }
      _optionalIndex(f.highlightRow, f.rows.length, label);
      if (f.highlightCol != null) {
        _indices([f.highlightCol!], f.rows[f.highlightRow!].length, label);
      }
      for (final addend in f.addends) {
        expect(addend.length, 2, reason: label);
        _indices([addend[0]], f.rows.length, label);
        _indices([addend[1]], f.rows[addend[0]].length, label);
        expect(
          f.rows[addend[0]][addend[1]],
          greaterThanOrEqualTo(0),
          reason: label,
        );
      }
    case final StringMatchFrame f:
      expect(f.offset, inInclusiveRange(0, f.text.length), reason: label);
      _indices(f.matched, f.pattern.length, label);
      _indices(f.found, f.text.length, label);
      _optionalIndex(f.compareIndex, f.pattern.length, label);
      _optionalIndex(f.mismatch, f.pattern.length, label);
      if (f.compareIndex != null) {
        _indices([f.offset + f.compareIndex!], f.text.length, label);
      }
      for (final index in f.matched) {
        _indices([f.offset + index], f.text.length, label);
        expect(
          f.text[f.offset + index],
          f.pattern[index],
          reason: '$label: green characters must actually match',
        );
      }
      if (f.found.isNotEmpty) {
        expect(f.found, {
          for (var i = 0; i < f.pattern.length; i++) f.offset + i,
        }, reason: label);
        expect(
          f.text.substring(f.offset, f.offset + f.pattern.length),
          f.pattern,
          reason: label,
        );
      }
    case final HashFrame f:
      expect(f.size, greaterThan(0), reason: label);
      expect(f.slots.length, f.size, reason: label);
      // -1 is the documented empty-slot value, not an index to validate.
      _optionalIndex(f.probe, f.size, label);
      _optionalIndex(f.placed, f.size, label);
    case final ChainHashFrame f:
      expect(f.buckets, isNotEmpty, reason: label);
      _optionalIndex(f.activeBucket, f.buckets.length, label);
    case final SequenceFrame f:
      _optionalIndex(f.highlight, f.values.length, label);
    case final TextFrame f:
      _indices(
        {...f.examining, ...f.matched, ...f.rejected},
        f.text.length,
        label,
      );
    case LinkedFrame _:
      // Node objects carry values and boolean state, with no external references.
      break;
    case final GeneticFrame f:
      expect(f.population, isNotEmpty, reason: label);
      expect(f.fitness.length, f.population.length, reason: label);
      _indices([f.best], f.population.length, label);
      expect(f.generation, greaterThanOrEqualTo(0), reason: label);
      for (var i = 0; i < f.population.length; i++) {
        expect(f.population[i].length, f.target.length, reason: label);
        final matches = [
          for (var j = 0; j < f.target.length; j++)
            if (f.population[i][j] == f.target[j]) j,
        ].length;
        expect(f.fitness[i], matches, reason: label);
        expect(
          f.fitness[i],
          lessThanOrEqualTo(f.fitness[f.best]),
          reason: label,
        );
      }
    case final TspFrame f:
      for (final city in f.cities) {
        _point(city, label);
      }
      _indices(f.tour, f.cities.length, label);
      if (f.tour.isNotEmpty) {
        expect(f.tour.toSet(), {
          for (var i = 0; i < f.cities.length; i++) i,
        }, reason: label);
      }
      expect(f.tour.toSet().length, f.tour.length, reason: label);
      if (f.pheromone.isNotEmpty) {
        expect(f.pheromone.length, f.cities.length, reason: label);
        for (final row in f.pheromone) {
          expect(row.length, f.cities.length, reason: label);
          for (final value in row) {
            expect(value.isFinite && value >= 0, isTrue, reason: label);
          }
        }
      }
      if (f.bestLength != null) {
        expect(
          f.bestLength!.isFinite && f.bestLength! >= 0,
          isTrue,
          reason: label,
        );
        if (f.tour.isNotEmpty) {
          var length = 0.0;
          for (var i = 0; i < f.tour.length; i++) {
            final a = f.cities[f.tour[i]],
                b = f.cities[f.tour[(i + 1) % f.tour.length]];
            length += math.sqrt(
              math.pow(a[0] - b[0], 2) + math.pow(a[1] - b[1], 2),
            );
          }
          expect(
            f.bestLength!,
            lessThanOrEqualTo(length + 1e-8),
            reason: label,
          );
        }
      }
    case final SwarmFrame f:
      for (final point in [
        ...f.particles,
        f.target,
        if (f.bestPos != null) f.bestPos!,
      ]) {
        _point(point, label);
      }
    case final HullFrame f:
      for (final point in f.points) {
        _point(point, label);
      }
      _indices(f.hull, f.points.length, label);
      _optionalIndex(f.current, f.points.length, label);
      if (f.closed) {
        expect(f.hull.length, greaterThanOrEqualTo(3), reason: label);
      }
    case final SequenceTrace f:
      for (final row in f.rows) {
        _indices(
          [...row.pointers.values, ...row.active, ...row.done],
          row.values.length,
          label,
        );
        expect(row.rangeStart == null, row.rangeEnd == null, reason: label);
        _optionalIndex(row.rangeStart, row.values.length, label);
        _optionalIndex(row.rangeEnd, row.values.length, label);
        if (row.rangeStart != null) {
          expect(
            row.rangeStart!,
            lessThanOrEqualTo(row.rangeEnd!),
            reason: label,
          );
        }
      }
    case final GeometryTrace f:
      final box = f.bounds;
      expect(
        [box.minX, box.minY, box.maxX, box.maxY].every((v) => v.isFinite),
        isTrue,
        reason: label,
      );
      expect(box.maxX, greaterThan(box.minX), reason: label);
      expect(box.maxY, greaterThan(box.minY), reason: label);
      for (final p in [
        ...f.output,
        for (final layer in f.layers) ...layer.points,
      ]) {
        _point([p.x, p.y], label, normalized: false);
      }
      if (f.value != null) expect(f.value!.isFinite, isTrue, reason: label);
    default:
      fail('No structural validator for ${frame.runtimeType}: $label');
  }
}

List<Object?> _edgeData(Iterable<GraphEdge>? edges) => [
  for (final e in edges ?? <GraphEdge>[]) [e.a, e.b, e.w, e.directed],
];

List<Object?> _graphScene(GraphRun run) => [
  run.nodeLabels,
  run.positions,
  _edgeData(run.edges),
  run.directed,
  run.weighted,
  run.activeEdgesOnly,
];

Object? _sceneData(Widget view) => switch (view) {
  final GraphView v => _graphScene(v.run),
  final GraphTraceView v => _graphScene(v.run.graph),
  final GridView2D v => [
    v.run.rows,
    v.run.cols,
    v.run.start,
    v.run.goal,
    v.run.walls.toList(),
  ],
  final HanoiView v => v.diskCount,
  _ => null,
};

// Plain-value fingerprints detect builder side effects and shared mutable state
// between old and newly generated runs. Shared constant inputs are permitted.
Object _data(Object frame) => switch (frame) {
  final ArrayFrame f => [
    f.values,
    [...f.comparing],
    [...f.active],
    [...f.done],
    f.windowLo,
    f.windowHi,
    f.pivot,
    f.target,
    f.caption,
  ],
  final TreeFrame f => [
    [
      for (final n in f.nodes) [n.id, n.value, n.left, n.right],
    ],
    f.rootId,
    [...f.highlight],
    f.output,
    f.caption,
  ],
  final GTreeFrame f => [
    [
      for (final n in f.nodes)
        [n.id, n.label, n.children, n.state.name, n.edgeLabel],
    ],
    f.rootId,
    f.caption,
  ],
  final TrieFrame f => [
    [
      for (final n in f.nodes) [n.id, n.label, n.children, n.isWord],
    ],
    f.rootId,
    [...f.highlight],
    f.caption,
  ],
  final GridFrame f => [
    [...f.open],
    [...f.closed],
    f.path,
    f.current,
    f.caption,
  ],
  final GraphFrame f => [
    [...f.inTree],
    [...f.treeEdges],
    f.candidate,
    f.current,
    f.order,
    [
      for (final e in f.colors.entries) [e.key, e.value],
    ],
    [
      for (final e in f.dist.entries) [e.key, e.value],
    ],
    f.caption,
  ],
  final GraphTraceFrame f => [
    _data(f.graph),
    f.frontierLabel,
    f.frontier,
    f.columns,
    f.rows,
    f.graphTitle,
    _edgeData(f.edges),
  ],
  final BoardFrame f => [
    f.n,
    f.queens,
    f.tryRow,
    f.tryCol,
    f.conflict,
    f.solved,
    f.caption,
  ],
  final HanoiFrame f => [f.pegs, f.movingDisk, f.fromPeg, f.toPeg, f.caption],
  final KnightFrame f => [
    f.n,
    f.board,
    f.current,
    f.tryCell,
    f.backtrack,
    f.solved,
    f.caption,
  ],
  final TableFrame f => [
    f.rows,
    f.cols,
    f.cells,
    f.rowHeader,
    f.colHeader,
    f.activeR,
    f.activeC,
    [...f.refs],
    [...f.filled],
    f.caption,
  ],
  final MatrixFrame f => [
    f.a,
    f.b,
    f.c,
    f.op,
    [...f.aRows],
    [...f.aCols],
    [...f.bRows],
    [...f.bCols],
    f.activeR,
    f.activeC,
    [...f.filled],
    f.caption,
  ],
  final NumberGridFrame f => [
    f.maxN,
    f.current,
    f.multiplesOf,
    [...f.marked],
    [...f.primes],
    f.caption,
  ],
  final PascalFrame f => [
    f.rows,
    f.highlightRow,
    f.highlightCol,
    f.addends,
    f.caption,
  ],
  final StringMatchFrame f => [
    f.text,
    f.pattern,
    f.offset,
    f.compareIndex,
    [...f.matched],
    f.mismatch,
    [...f.found],
    f.caption,
  ],
  final HashFrame f => [
    f.size,
    f.slots,
    f.probe,
    f.inserting,
    f.placed,
    f.caption,
  ],
  final ChainHashFrame f => [
    f.buckets,
    f.activeBucket,
    f.inserting,
    f.placed,
    f.caption,
  ],
  final SequenceFrame f => [
    f.values,
    f.vertical,
    f.highlight,
    f.removed,
    f.caption,
  ],
  final TextFrame f => [
    f.text,
    [...f.examining],
    [...f.matched],
    [...f.rejected],
    f.caption,
  ],
  final LinkedFrame f => [
    [
      for (final n in f.nodes) [n.value, n.highlight, n.fading],
    ],
    f.doubly,
    f.circular,
    f.caption,
  ],
  final GeneticFrame f => [
    f.target,
    f.population,
    f.fitness,
    f.best,
    f.generation,
    f.caption,
  ],
  final TspFrame f => [f.cities, f.pheromone, f.tour, f.bestLength, f.caption],
  final SwarmFrame f => [f.particles, f.target, f.bestPos, f.caption],
  final HullFrame f => [f.points, f.hull, f.current, f.closed, f.caption],
  final SequenceTrace f => [
    [
      for (final r in f.rows)
        [
          r.label,
          r.values,
          r.pointers,
          [...r.active],
          [...r.done],
          r.rangeStart,
          r.rangeEnd,
        ],
    ],
    f.variables,
    f.output,
    f.result,
    f.caption,
  ],
  final GeometryTrace f => [
    [f.bounds.minX, f.bounds.minY, f.bounds.maxX, f.bounds.maxY],
    [
      for (final l in f.layers)
        [
          l.label,
          l.shape.name,
          l.role.name,
          [
            for (final p in l.points) [p.x, p.y],
          ],
        ],
    ],
    f.clipWindow == null
        ? null
        : [
            f.clipWindow!.minX,
            f.clipWindow!.minY,
            f.clipWindow!.maxX,
            f.clipWindow!.maxY,
          ],
    f.variables,
    [
      for (final p in f.output) [p.x, p.y],
    ],
    f.value,
    f.result,
    f.caption,
  ],
  _ => throw StateError('Missing frame fingerprint: ${frame.runtimeType}'),
};

void main() {
  test(
    'flood fill distinguishes its frontier and fills the connected region',
    () {
      for (final seed in [0, 7, 31]) {
        final run = floodFillDemo(seed: seed);
        // Compute the connected component independently of the animation's queue.
        final reachable = <int>{run.start};
        var expanded = true;
        while (expanded) {
          expanded = false;
          for (var cell = 0; cell < run.rows * run.cols; cell++) {
            if (run.walls.contains(cell) || reachable.contains(cell)) continue;
            final row = cell ~/ run.cols, col = cell % run.cols;
            final neighbours = [
              if (row > 0) cell - run.cols,
              if (row + 1 < run.rows) cell + run.cols,
              if (col > 0) cell - 1,
              if (col + 1 < run.cols) cell + 1,
            ];
            if (neighbours.any(reachable.contains)) {
              reachable.add(cell);
              expanded = true;
            }
          }
        }
        var completed = <int>{};
        for (final frame in run.frames) {
          _grid(run, frame, 'flood fill seed $seed');
          expect(frame.closed.containsAll(completed), isTrue);
          if (frame.current != null) {
            expect(frame.closed.difference(completed), {frame.current!});
          }
          completed = frame.closed;
        }
        expect(run.frames.last.closed, reachable);
        expect(run.frames.last.open, isEmpty);
      }
    },
  );
  for (final info in catalog) {
    testWidgets('frame integrity: ${info.id}', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox.shrink();
          },
        ),
      );
      final run = info.create();
      expect(run.frameCount, greaterThan(0));
      final fingerprints = <String>[];
      for (var i = 0; i < run.frameCount; i++) {
        final view = run.builder(context, i);
        // Every catalog builder returns a view exposing its strongly typed frame.
        final frame = (view as dynamic).frame as Object;
        final label = '${info.id} frame $i: ${run.captionAt(i)}';
        expect(run.captionAt(i), isNotEmpty, reason: label);
        final caption = frame is GraphTraceFrame
            ? frame.graph.caption
            : (frame as dynamic).caption as String;
        expect(caption, run.captionAt(i), reason: label);
        _validate(frame, view, label);
        fingerprints.add(jsonEncode([_data(frame), _sceneData(view)]));
      }
      // Creating another input and scrubbing backward must preserve the old run.
      info.create();
      for (var i = run.frameCount - 1; i >= 0; i--) {
        final view = run.builder(context, i);
        final frame = (view as dynamic).frame as Object;
        expect(
          jsonEncode([_data(frame), _sceneData(view)]),
          fingerprints[i],
          reason: '${info.id} frame $i changed during replay or a new run',
        );
      }
    });
  }
}
