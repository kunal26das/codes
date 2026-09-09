import 'dart:math';

import 'package:algoscope/algorithms/graph_extensions.dart';
import 'package:algoscope/data/graph_catalog.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/models/graph_trace.dart';
import 'package:algoscope/visualizers/graph_trace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _algorithms = <String, GraphTraceRun Function()>{
  'BFS': graphBreadthFirst,
  'DFS': graphDepthFirst,
  'Dijkstra': weightedDijkstra,
  'DFS topological': dfsTopologicalSort,
  'Kosaraju': kosarajuComponents,
  'Tarjan': tarjanComponents,
  'Bridges': graphBridges,
  'Articulation': articulationPoints,
  'Bipartite': bipartiteCheck,
  'Hierholzer': eulerianTrail,
  'DAG shortest paths': dagShortestPaths,
  'Boruvka': boruvkaMst,
  'Edmonds-Karp': edmondsKarp,
  'Warshall': warshallClosure,
  'Hamiltonian': hamiltonianCycle,
};

GraphRun _input(int n, List<(int, int, int)> edges, {bool directed = false}) =>
    GraphRun(
      nodeLabels: [for (var i = 0; i < n; i++) String.fromCharCode(65 + i)],
      positions: [
        for (var i = 0; i < n; i++)
          [0.1 + 0.8 * i / max(1, n - 1), i.isEven ? 0.25 : 0.75],
      ],
      edges: [
        for (final (a, b, w) in edges)
          directed ? GraphEdge.directed(a, b, w) : GraphEdge(a, b, w),
      ],
      frames: const [],
      directed: directed,
      weighted: true,
    );

List<List<int>> _allDistances(GraphRun graph, {bool unweighted = false}) {
  final n = graph.nodeLabels.length;
  final distances = [
    for (var i = 0; i < n; i++)
      [for (var j = 0; j < n; j++) i == j ? 0 : graphInfinity],
  ];
  for (final edge in graph.edges) {
    distances[edge.a][edge.b] = min(
      distances[edge.a][edge.b],
      unweighted ? 1 : edge.w,
    );
    if (!graph.directed) distances[edge.b][edge.a] = distances[edge.a][edge.b];
  }
  for (var k = 0; k < n; k++) {
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if (distances[i][k] != graphInfinity &&
            distances[k][j] != graphInfinity) {
          distances[i][j] = min(
            distances[i][j],
            distances[i][k] + distances[k][j],
          );
        }
      }
    }
  }
  return distances;
}

List<List<int>> _adjacency(
  GraphRun graph, {
  int? removedVertex,
  int? removedEdge,
}) {
  final adj = [for (var i = 0; i < graph.nodeLabels.length; i++) <int>[]];
  for (final edge in graph.edges) {
    if (edge.key == removedEdge ||
        edge.a == removedVertex ||
        edge.b == removedVertex) {
      continue;
    }
    adj[edge.a].add(edge.b);
    if (!graph.directed) adj[edge.b].add(edge.a);
  }
  return adj;
}

int _componentCount(GraphRun graph, {int? removedVertex, int? removedEdge}) {
  final adj = _adjacency(
    graph,
    removedVertex: removedVertex,
    removedEdge: removedEdge,
  );
  final visited = <int>{};
  var count = 0;
  for (var root = 0; root < adj.length; root++) {
    if (root == removedVertex || !visited.add(root)) continue;
    count++;
    final stack = <int>[root];
    while (stack.isNotEmpty) {
      for (final v in adj[stack.removeLast()]) {
        if (visited.add(v)) stack.add(v);
      }
    }
  }
  return count;
}

Set<String> _partition(List<List<int>> groups) => {
  for (final group in groups) (([...group]..sort()).join(',')),
};

void _checkFrames(GraphTraceRun run) {
  final n = run.graph.nodeLabels.length;
  expect(run.frames.length, greaterThan(1));
  for (var index = 0; index < run.frames.length; index++) {
    final trace = run.frames[index], frame = run.frames[index].graph;
    final edges = trace.edges ?? run.graph.edges;
    final keys = edges.map((edge) => edge.key).toSet();
    expect(
      keys.length,
      edges.length,
      reason: 'Duplicate edge IDs at frame $index.',
    );
    for (final edge in edges) {
      expect(edge.a, inInclusiveRange(0, n - 1));
      expect(edge.b, inInclusiveRange(0, n - 1));
      expect(edge.directed, run.graph.directed);
    }
    expect(frame.caption.trim(), isNotEmpty);
    for (final vertex in {
      ...frame.inTree,
      ...frame.colors.keys,
      ...frame.order,
      ...frame.dist.keys,
      if (frame.current != null) frame.current!,
    }) {
      expect(vertex, inInclusiveRange(0, n - 1), reason: frame.caption);
    }
    expect(
      keys.containsAll(frame.treeEdges),
      isTrue,
      reason: 'Selected edge absent: ${frame.caption}',
    );
    if (frame.candidate != null) {
      expect(keys, contains(frame.candidate), reason: frame.caption);
    }
    for (final color in frame.colors.values) {
      expect(color, greaterThanOrEqualTo(0));
    }
    for (final row in trace.rows) {
      expect(row.length, trace.columns.length, reason: frame.caption);
    }
  }
}

void _checkTopological(GraphTraceRun result) {
  expect(result.success, isTrue);
  expect(result.order.toSet().length, result.graph.nodeLabels.length);
  for (final edge in result.graph.edges) {
    expect(
      result.order.indexOf(edge.a),
      lessThan(result.order.indexOf(edge.b)),
    );
  }
}

void _checkFlow(GraphTraceRun result, int source, int sink) {
  final graph = result.graph, n = result.graph.nodeLabels.length;
  final capacities = {for (final e in graph.edges) (e.a, e.b): e.w};
  for (var u = 0; u < n; u++) {
    var outgoing = 0, incoming = 0;
    for (var v = 0; v < n; v++) {
      expect(result.flow[u][v], inInclusiveRange(0, capacities[(u, v)] ?? 0));
      outgoing += result.flow[u][v];
      incoming += result.flow[v][u];
    }
    expect(
      outgoing - incoming,
      u == source
          ? result.total
          : u == sink
          ? -result.total!
          : 0,
    );
  }
  var minimumCut = graphInfinity;
  for (var mask = 0; mask < (1 << n); mask++) {
    if ((mask & (1 << source)) == 0 || (mask & (1 << sink)) != 0) continue;
    final capacity = graph.edges
        .where(
          (edge) => (mask & (1 << edge.a)) != 0 && (mask & (1 << edge.b)) == 0,
        )
        .fold<int>(0, (sum, edge) => sum + edge.w);
    minimumCut = min(minimumCut, capacity);
  }
  expect(result.total, minimumCut);
  expect(
    graph.edges
        .where((edge) => result.resultEdges.contains(edge.key))
        .fold<int>(0, (sum, edge) => sum + edge.w),
    minimumCut,
  );
}

void main() {
  group('every graph animation has valid immutable snapshots', () {
    for (final entry in _algorithms.entries) {
      test(entry.key, () {
        final run = entry.value();
        _checkFrames(run);
        expect(() => run.frames.clear(), throwsUnsupportedError);
        expect(() => run.frames.first.rows.clear(), throwsUnsupportedError);
        expect(
          () => run.frames.first.frontier.add('mutation'),
          throwsUnsupportedError,
        );
      });
    }
  });

  test('catalog exposes fifteen distinct replayable graph algorithms', () {
    expect(graphExtensions.length, _algorithms.length);
    expect(
      graphExtensions.map((entry) => entry.id).toSet().length,
      graphExtensions.length,
    );
    for (final entry in graphExtensions) {
      final run = entry.create();
      expect(run.frameCount, greaterThan(1));
      for (var i = 0; i < run.frameCount; i++) {
        expect(run.captionAt(i), isNotEmpty);
      }
    }
  });

  test(
    'graph BFS discovers minimum edge distances and handles disconnected vertices',
    () {
      final result = graphBreadthFirst();
      expect(result.order, [0, 1, 2, 3, 4, 5, 6]);
      expect(
        result.distances,
        _allDistances(result.graph, unweighted: true)[0],
      );
      final disconnected = graphBreadthFirst(
        input: _input(4, [(0, 1, 1), (2, 3, 1)]),
      );
      expect(disconnected.order, [0, 1]);
      expect(disconnected.distances, [0, 1, graphInfinity, graphInfinity]);
      _checkFrames(disconnected);
    },
  );

  test('graph DFS shows nested discovery and finishing times', () {
    final result = graphDepthFirst();
    expect(result.order, [0, 1, 3, 5, 4, 2, 6]);
    final times = result.frames.last.rows;
    final all = <int>{};
    for (final row in times) {
      final start = int.parse(row[1]), end = int.parse(row[2]);
      expect(start, lessThan(end));
      all
        ..add(start)
        ..add(end);
    }
    expect(all.length, result.graph.nodeLabels.length * 2);
    expect(
      result.frames.where((frame) => frame.frontier.length > 3),
      isNotEmpty,
    );
  });

  test('weighted Dijkstra agrees with all-pairs shortest paths', () {
    final result = weightedDijkstra();
    expect(result.distances, [0, 3, 2, 8, 10, 13]);
    expect(result.distances, _allDistances(result.graph)[0]);
    final disconnected = weightedDijkstra(
      input: _input(4, [(0, 1, 2), (2, 3, 1)]),
    );
    expect(disconnected.distances, [0, 2, graphInfinity, graphInfinity]);
    expect(
      () => weightedDijkstra(input: _input(2, [(0, 1, -1)])),
      throwsArgumentError,
    );
  });

  test('DFS topological order respects every arc and rejects cycles', () {
    _checkTopological(dfsTopologicalSort());
    final cyclic = dfsTopologicalSort(
      input: _input(3, [(0, 1, 1), (1, 2, 1), (2, 0, 1)], directed: true),
    );
    expect(cyclic.success, isFalse);
    expect(cyclic.order, isEmpty);
    expect(cyclic.frames.last.graph.caption, contains('no topological order'));
    _checkFrames(cyclic);
  });

  test(
    'both SCC algorithms match mutual reachability including isolated vertices',
    () {
      for (final graph in [
        kosarajuComponents().graph,
        _input(7, [
          (0, 1, 1),
          (1, 0, 1),
          (2, 3, 1),
          (3, 2, 1),
          (4, 5, 1),
        ], directed: true),
      ]) {
        final distances = _allDistances(graph, unweighted: true);
        final expected = <String>{};
        for (var u = 0; u < graph.nodeLabels.length; u++) {
          expected.add(
            [
              for (var v = 0; v < graph.nodeLabels.length; v++)
                if (distances[u][v] != graphInfinity &&
                    distances[v][u] != graphInfinity)
                  v,
            ].join(','),
          );
        }
        for (final result in [
          kosarajuComponents(input: graph),
          tarjanComponents(input: graph),
        ]) {
          expect(_partition(result.components), expected);
          expect(
            result.components.expand((component) => component).length,
            graph.nodeLabels.length,
          );
          _checkFrames(result);
        }
      }
      final kosaraju = kosarajuComponents();
      expect(
        kosaraju.frames.where(
          (frame) => frame.graphTitle.contains('transposed'),
        ),
        isNotEmpty,
      );
      expect(tarjanComponents().frames.last.frontier, isEmpty);
    },
  );

  test(
    'bridges and articulation points agree with removal-and-recount oracles',
    () {
      final rng = Random(431);
      final graphs = [
        graphBridges().graph,
        _input(4, [(0, 1, 1), (0, 2, 1), (0, 3, 1)]),
      ];
      for (var sample = 0; sample < 12; sample++) {
        graphs.add(
          _input(6, [
            for (var u = 0; u < 6; u++)
              for (var v = u + 1; v < 6; v++)
                if (rng.nextBool()) (u, v, 1),
          ]),
        );
      }
      for (final graph in graphs) {
        final base = _componentCount(graph);
        final expectedBridges = {
          for (final e in graph.edges)
            if (_componentCount(graph, removedEdge: e.key) > base) e.key,
        };
        final expectedVertices = {
          for (var u = 0; u < graph.nodeLabels.length; u++)
            if (_componentCount(graph, removedVertex: u) > base) u,
        };
        final bridges = graphBridges(input: graph),
            vertices = articulationPoints(input: graph);
        expect(bridges.resultEdges, expectedBridges);
        expect(vertices.resultVertices, expectedVertices);
        _checkFrames(bridges);
        _checkFrames(vertices);
      }
    },
  );

  test(
    'bipartite failure supplies an odd-cycle witness and success a valid partition',
    () {
      final odd = bipartiteCheck();
      expect(odd.success, isFalse);
      expect(odd.path.first, odd.path.last);
      expect((odd.path.length - 1).isOdd, isTrue);
      final keys = odd.graph.edges.map((edge) => edge.key).toSet();
      for (var i = 1; i < odd.path.length; i++) {
        expect(keys, contains(GraphEdge(odd.path[i - 1], odd.path[i], 0).key));
      }
      final even = bipartiteCheck(
        input: _input(6, [
          (0, 1, 1),
          (1, 2, 1),
          (2, 3, 1),
          (3, 0, 1),
          (4, 5, 1),
        ]),
      );
      expect(even.success, isTrue);
      final group = {
        for (var c = 0; c < even.components.length; c++)
          for (final u in even.components[c]) u: c,
      };
      for (final edge in even.graph.edges) {
        expect(group[edge.a], isNot(group[edge.b]));
      }
      _checkFrames(even);
    },
  );

  test(
    'Hierholzer uses each edge once and rejects incompatible components or degrees',
    () {
      final result = eulerianTrail();
      expect(result.success, isTrue);
      expect(result.path.length, result.graph.edges.length + 1);
      final traversed = [
        for (var i = 1; i < result.path.length; i++)
          GraphEdge(result.path[i - 1], result.path[i], 0).key,
      ];
      expect(traversed.toSet().length, traversed.length);
      expect(
        traversed.toSet(),
        result.graph.edges.map((edge) => edge.key).toSet(),
      );
      final disconnected = eulerianTrail(
        input: _input(6, [
          (0, 1, 1),
          (1, 2, 1),
          (2, 0, 1),
          (3, 4, 1),
          (4, 5, 1),
          (5, 3, 1),
        ]),
      );
      expect(disconnected.success, isFalse);
      expect(disconnected.path, isEmpty);
      expect(
        eulerianTrail(
          input: _input(4, [(0, 1, 1), (0, 2, 1), (0, 3, 1)]),
        ).success,
        isFalse,
      );
    },
  );

  test(
    'DAG shortest paths handle negative weights, unreachable vertices and cycles',
    () {
      final result = dagShortestPaths();
      expect(result.distances, [0, 4, 2, 7, 3, 5]);
      expect(result.distances, _allDistances(result.graph)[0]);
      _checkTopological(result);
      final disconnected = dagShortestPaths(
        input: _input(4, [(0, 1, 2), (2, 3, -5)], directed: true),
      );
      expect(disconnected.distances, [0, 2, graphInfinity, graphInfinity]);
      expect(
        dagShortestPaths(
          input: _input(2, [(0, 1, 1), (1, 0, 1)], directed: true),
        ).success,
        isFalse,
      );
    },
  );

  test(
    'Boruvka matches exhaustive spanning-tree enumeration and supports forests',
    () {
      final result = boruvkaMst(), graph = boruvkaMst().graph;
      var minimum = graphInfinity;
      for (var mask = 0; mask < (1 << graph.edges.length); mask++) {
        final chosen = [
          for (var i = 0; i < graph.edges.length; i++)
            if ((mask & (1 << i)) != 0) graph.edges[i],
        ];
        if (chosen.length != graph.nodeLabels.length - 1) continue;
        final subgraph = _input(graph.nodeLabels.length, [
          for (final edge in chosen) (edge.a, edge.b, edge.w),
        ]);
        if (_componentCount(subgraph) == 1) {
          minimum = min(minimum, chosen.fold(0, (sum, edge) => sum + edge.w));
        }
      }
      expect(result.total, minimum);
      expect(result.total, 13);
      expect(result.resultEdges.length, graph.nodeLabels.length - 1);
      final forest = boruvkaMst(input: _input(4, [(0, 1, 2), (2, 3, 3)]));
      expect(forest.success, isFalse);
      expect(forest.total, 5);
      expect(forest.resultEdges.length, 2);
      _checkFrames(forest);
    },
  );

  test(
    'Edmonds-Karp conserves flow, attains the minimum cut and cancels earlier flow',
    () {
      final result = edmondsKarp();
      _checkFlow(result, 0, 5);
      expect(result.total, 2);
      expect(
        result.frames.any(
          (frame) =>
              frame.graph.candidate == const GraphEdge.directed(3, 1, 0).key,
        ),
        isTrue,
      );
      expect(
        result.flow[1][3],
        0,
        reason:
            'The first augmenting path used A→C, which must later be cancelled.',
      );
      final opposite = edmondsKarp(
        input: _input(4, [
          (0, 1, 3),
          (1, 0, 1),
          (1, 2, 2),
          (2, 1, 4),
          (0, 2, 1),
          (2, 3, 3),
          (1, 3, 1),
        ], directed: true),
      );
      _checkFlow(opposite, 0, 3);
      _checkFrames(opposite);
      final blocked = edmondsKarp(
        input: _input(3, [(0, 1, 0), (1, 2, 1)], directed: true),
      );
      _checkFlow(blocked, 0, 2);
      expect(blocked.total, 0);
    },
  );

  test('Warshall closure equals independent source reachability', () {
    final result = warshallClosure();
    final adj = _adjacency(result.graph);
    for (var source = 0; source < adj.length; source++) {
      final reached = <int>{source}, stack = <int>[source];
      while (stack.isNotEmpty) {
        for (final v in adj[stack.removeLast()]) {
          if (reached.add(v)) stack.add(v);
        }
      }
      expect(result.matrix[source], [
        for (var v = 0; v < adj.length; v++) reached.contains(v) ? 1 : 0,
      ]);
    }
    expect(
      result.frames.any(
        (frame) => (frame.edges?.length ?? 0) > result.graph.edges.length,
      ),
      isTrue,
    );
  });

  test(
    'Hamiltonian search backtracks then returns a valid vertex-once cycle',
    () {
      final result = hamiltonianCycle();
      expect(result.success, isTrue);
      expect(result.path.length, result.graph.nodeLabels.length + 1);
      expect(result.path.first, result.path.last);
      expect(
        result.path.take(result.path.length - 1).toSet().length,
        result.graph.nodeLabels.length,
      );
      expect(
        result.frames.any(
          (frame) => frame.graph.caption.startsWith('Dead end:'),
        ),
        isTrue,
      );
      final keys = result.graph.edges.map((edge) => edge.key).toSet();
      for (var i = 1; i < result.path.length; i++) {
        expect(
          keys,
          contains(GraphEdge(result.path[i - 1], result.path[i], 0).key),
        );
      }
      final impossible = hamiltonianCycle(
        input: _input(4, [(0, 1, 1), (0, 2, 1), (0, 3, 1)]),
      );
      expect(impossible.success, isFalse);
      expect(impossible.path, isEmpty);
      _checkFrames(impossible);
    },
  );

  testWidgets(
    'graph-state panels render start, middle and final snapshots at phone and desktop sizes',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final viewport in [const Size(300, 120), const Size(900, 500)]) {
        await tester.binding.setSurfaceSize(viewport);
        for (final entry in _algorithms.entries) {
          final run = entry.value();
          for (final index in {
            0,
            run.frames.length ~/ 2,
            run.frames.length - 1,
          }) {
            await tester.pumpWidget(
              MaterialApp(
                home: GraphTraceView(run: run, frame: run.frames[index]),
              ),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key}, frame $index at $viewport',
            );
          }
        }
      }
    },
  );
}
