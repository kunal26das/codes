import '../models/frames.dart';

// Shared weighted graph for the MST demos (minimum spanning weight = 18).
const _mstLabels = ['A', 'B', 'C', 'D', 'E', 'F'];
const _mstPositions = [
  [0.12, 0.28],
  [0.50, 0.10],
  [0.88, 0.30],
  [0.82, 0.80],
  [0.45, 0.92],
  [0.13, 0.72],
];
const _mstEdges = [
  GraphEdge(0, 1, 4),
  GraphEdge(0, 5, 3),
  GraphEdge(1, 2, 5),
  GraphEdge(1, 5, 6),
  GraphEdge(1, 4, 8),
  GraphEdge(2, 3, 2),
  GraphEdge(2, 4, 7),
  GraphEdge(3, 4, 4),
  GraphEdge(4, 5, 5),
];

String _edgeName(GraphEdge e) => '${_mstLabels[e.a]}–${_mstLabels[e.b]}';

/// Prim's algorithm grows a minimum spanning tree from a start node, repeatedly
/// adding the cheapest edge that connects the tree to a new vertex.
GraphRun primDemo() {
  const labels = _mstLabels;
  const positions = _mstPositions;
  const edges = _mstEdges;

  final inTree = <int>{0};
  final treeEdges = <int>{};
  final frames = <GraphFrame>[
    const GraphFrame(inTree: {0}, current: 0, caption: 'Start the tree at A.'),
  ];
  var totalWeight = 0;

  for (var step = 0; step < labels.length - 1; step++) {
    GraphEdge? best;
    for (final e in edges) {
      final crosses = inTree.contains(e.a) != inTree.contains(e.b);
      if (crosses && (best == null || e.w < best.w)) best = e;
    }
    if (best == null) break;

    frames.add(GraphFrame(
      inTree: {...inTree},
      treeEdges: {...treeEdges},
      candidate: best.key,
      caption: 'Cheapest edge leaving the tree: ${labels[best.a]}–${labels[best.b]} (weight ${best.w}).',
    ));

    final added = inTree.contains(best.a) ? best.b : best.a;
    inTree.add(added);
    treeEdges.add(best.key);
    totalWeight += best.w;
    frames.add(GraphFrame(
      inTree: {...inTree},
      treeEdges: {...treeEdges},
      current: added,
      caption: 'Add ${labels[added]} to the tree via that edge.',
    ));
  }

  frames.add(GraphFrame(
    inTree: {...inTree},
    treeEdges: {...treeEdges},
    caption: 'Minimum spanning tree complete — total weight $totalWeight.',
  ));

  return GraphRun(
    nodeLabels: labels,
    positions: positions,
    edges: edges,
    frames: frames,
  );
}

/// Kruskal's algorithm sorts every edge by weight and adds each one that joins
/// two separate components (detected with union–find), skipping edges that
/// would create a cycle.
GraphRun kruskalDemo() {
  final sorted = [..._mstEdges]..sort((a, b) => a.w.compareTo(b.w));
  final parent = [for (var i = 0; i < _mstLabels.length; i++) i];
  int find(int x) {
    while (parent[x] != x) {
      parent[x] = parent[parent[x]];
      x = parent[x];
    }
    return x;
  }

  final treeEdges = <int>{};
  final inTree = <int>{};
  var total = 0;
  final frames = <GraphFrame>[
    const GraphFrame(caption: 'Sort every edge by weight, then add each unless it forms a cycle.'),
  ];

  for (final e in sorted) {
    final ra = find(e.a), rb = find(e.b);
    final cycle = ra == rb;
    frames.add(GraphFrame(
      inTree: {...inTree},
      treeEdges: {...treeEdges},
      candidate: e.key,
      caption: cycle
          ? 'Edge ${_edgeName(e)} (${e.w}) would form a cycle — skip it.'
          : 'Edge ${_edgeName(e)} (${e.w}) joins two components — add it.',
    ));
    if (!cycle) {
      parent[ra] = rb;
      treeEdges.add(e.key);
      inTree
        ..add(e.a)
        ..add(e.b);
      total += e.w;
      frames.add(GraphFrame(
        inTree: {...inTree},
        treeEdges: {...treeEdges},
        current: e.b,
        caption: 'Added — the spanning forest grows.',
      ));
    }
  }

  frames.add(GraphFrame(
    inTree: {...inTree},
    treeEdges: {...treeEdges},
    caption: 'Minimum spanning tree complete — total weight $total.',
  ));

  return GraphRun(
    nodeLabels: _mstLabels,
    positions: _mstPositions,
    edges: _mstEdges,
    frames: frames,
  );
}

// Directed acyclic graph for the topological-sort demo.
const _dagLabels = ['A', 'B', 'C', 'D', 'E', 'F'];
const _dagPositions = [
  [0.10, 0.20],
  [0.10, 0.80],
  [0.40, 0.18],
  [0.42, 0.62],
  [0.72, 0.32],
  [0.90, 0.72],
];
const _dagEdges = [
  GraphEdge(0, 2, 0), // A→C
  GraphEdge(0, 3, 0), // A→D
  GraphEdge(1, 3, 0), // B→D
  GraphEdge(2, 4, 0), // C→E
  GraphEdge(3, 4, 0), // D→E
  GraphEdge(3, 5, 0), // D→F
  GraphEdge(4, 5, 0), // E→F
];

/// Topological sort (Kahn's algorithm): repeatedly remove a node that has no
/// remaining incoming edges and append it to the order.
GraphRun topologicalSort() {
  final n = _dagLabels.length;
  final indeg = List<int>.filled(n, 0);
  for (final e in _dagEdges) {
    indeg[e.b]++;
  }

  final removed = <int>{};
  final order = <int>[];
  final frames = <GraphFrame>[
    const GraphFrame(caption: 'Repeatedly take a node with no incoming edges (Kahn’s algorithm).'),
  ];

  while (true) {
    int? pick;
    for (var i = 0; i < n; i++) {
      if (!removed.contains(i) && indeg[i] == 0) {
        pick = i;
        break;
      }
    }
    if (pick == null) break;
    removed.add(pick);
    order.add(pick);
    frames.add(GraphFrame(
      inTree: {...removed},
      current: pick,
      order: [...order],
      caption: 'Remove ${_dagLabels[pick]} (no incoming edges) and append it.',
    ));
    for (final e in _dagEdges) {
      if (e.a == pick && !removed.contains(e.b)) indeg[e.b]--;
    }
  }

  frames.add(GraphFrame(
    inTree: {...removed},
    order: [...order],
    caption: 'Topological order: ${order.map((i) => _dagLabels[i]).join(' → ')}.',
  ));

  return GraphRun(
    nodeLabels: _dagLabels,
    positions: _dagPositions,
    edges: _dagEdges,
    directed: true,
    frames: frames,
  );
}

/// Greedy graph colouring — assign each vertex the lowest colour not used by
/// any already-coloured neighbour.
GraphRun graphColoring() {
  final n = _mstLabels.length;
  final adj = [for (var i = 0; i < n; i++) <int>[]];
  for (final e in _mstEdges) {
    adj[e.a].add(e.b);
    adj[e.b].add(e.a);
  }
  final color = <int, int>{};
  final frames = <GraphFrame>[
    const GraphFrame(caption: 'Colour each vertex so no edge joins two of the same colour.'),
  ];
  for (var v = 0; v < n; v++) {
    final used = <int>{
      for (final nb in adj[v])
        if (color.containsKey(nb)) color[nb]!,
    };
    var c = 0;
    while (used.contains(c)) {
      c++;
    }
    color[v] = c;
    frames.add(GraphFrame(
      inTree: {...color.keys},
      current: v,
      colors: {...color},
      caption: '${_mstLabels[v]} takes colour ${c + 1} — the lowest its neighbours don’t use.',
    ));
  }
  final numColors = color.values.toSet().length;
  frames.add(GraphFrame(
    inTree: {...color.keys},
    colors: {...color},
    caption: 'Coloured the graph with $numColors colours.',
  ));
  return GraphRun(nodeLabels: _mstLabels, positions: _mstPositions, edges: _mstEdges, frames: frames);
}

// Directed graph containing a cycle (B→C→D→B) for cycle detection.
const _cycleLabels = ['A', 'B', 'C', 'D', 'E'];
const _cyclePositions = [
  [0.10, 0.50],
  [0.36, 0.20],
  [0.64, 0.20],
  [0.64, 0.78],
  [0.90, 0.55],
];
const _cycleEdges = [
  GraphEdge(0, 1, 0), // A→B
  GraphEdge(1, 2, 0), // B→C
  GraphEdge(2, 3, 0), // C→D
  GraphEdge(3, 1, 0), // D→B  (back edge → cycle)
  GraphEdge(2, 4, 0), // C→E
];

/// Cycle detection in a directed graph via DFS: a "back edge" to a vertex still
/// on the recursion stack means a cycle exists.
GraphRun cycleDetection() {
  final n = _cycleLabels.length;
  final adj = [for (var i = 0; i < n; i++) <int>[]];
  for (final e in _cycleEdges) {
    adj[e.a].add(e.b);
  }
  final state = List<int>.filled(n, 0); // 0 white, 1 gray (on stack), 2 black
  final treeEdges = <int>{};
  final frames = <GraphFrame>[
    const GraphFrame(caption: 'DFS the graph; an edge to a vertex still on the stack is a cycle.'),
  ];
  var found = false;
  int? backEdge;

  Set<int> finished() => {for (var i = 0; i < n; i++) if (state[i] == 2) i};

  void dfs(int u) {
    if (found) return;
    state[u] = 1;
    frames.add(GraphFrame(inTree: finished(), treeEdges: {...treeEdges}, current: u, caption: 'Enter ${_cycleLabels[u]} (now on the stack).'));
    for (final v in adj[u]) {
      final e = GraphEdge(u, v, 0);
      if (state[v] == 1) {
        found = true;
        backEdge = e.key;
        frames.add(GraphFrame(
          inTree: finished(),
          treeEdges: {...treeEdges},
          candidate: e.key,
          current: u,
          caption: 'Edge ${_cycleLabels[u]}→${_cycleLabels[v]} hits a stacked vertex — cycle found!',
        ));
        return;
      } else if (state[v] == 0) {
        treeEdges.add(e.key);
        dfs(v);
        if (found) return;
      }
    }
    state[u] = 2;
    frames.add(GraphFrame(inTree: finished(), treeEdges: {...treeEdges}, caption: 'Finish ${_cycleLabels[u]} and pop it.'));
  }

  for (var i = 0; i < n && !found; i++) {
    if (state[i] == 0) dfs(i);
  }
  frames.add(GraphFrame(
    inTree: finished(),
    treeEdges: {...treeEdges},
    candidate: backEdge,
    caption: found ? 'The directed graph contains a cycle.' : 'No back edges — the graph is acyclic.',
  ));
  return GraphRun(nodeLabels: _cycleLabels, positions: _cyclePositions, edges: _cycleEdges, directed: true, frames: frames);
}

// Directed weighted graph (with negative edges, no negative cycle) for Bellman–Ford.
const _bfLabels = ['A', 'B', 'C', 'D', 'E'];
const _bfPositions = [
  [0.10, 0.50],
  [0.40, 0.18],
  [0.40, 0.82],
  [0.72, 0.18],
  [0.72, 0.82],
];
const _bfEdges = [
  GraphEdge(0, 1, 6),
  GraphEdge(0, 2, 7),
  GraphEdge(1, 2, 8),
  GraphEdge(1, 3, 5),
  GraphEdge(1, 4, -4),
  GraphEdge(2, 3, -3),
  GraphEdge(2, 4, 9),
  GraphEdge(3, 1, -2),
  GraphEdge(4, 0, 2),
  GraphEdge(4, 3, 7),
];

const _bfInf = 1 << 29;

/// Bellman–Ford single-source shortest paths — relaxes every edge V−1 times,
/// handling negative edge weights.
GraphRun bellmanFord() {
  final n = _bfLabels.length;
  final dist = List<int>.filled(n, _bfInf);
  dist[0] = 0;
  Map<int, int> distMap() => {for (var i = 0; i < n; i++) i: dist[i]};

  final frames = <GraphFrame>[
    GraphFrame(dist: distMap(), current: 0, caption: 'Source ${_bfLabels[0]} starts at 0; all others at ∞.'),
  ];
  for (var pass = 1; pass < n; pass++) {
    var changed = false;
    for (final e in _bfEdges) {
      if (dist[e.a] != _bfInf && dist[e.a] + e.w < dist[e.b]) {
        dist[e.b] = dist[e.a] + e.w;
        changed = true;
        frames.add(GraphFrame(
          dist: distMap(),
          candidate: e.key,
          current: e.b,
          caption: 'Pass $pass: relax ${_bfLabels[e.a]}→${_bfLabels[e.b]} → dist[${_bfLabels[e.b]}] = ${dist[e.b]}.',
        ));
      }
    }
    if (!changed) break;
  }
  frames.add(GraphFrame(
    dist: distMap(),
    caption: 'Shortest distances from ${_bfLabels[0]}: ${[for (var i = 0; i < n; i++) '${_bfLabels[i]}=${dist[i]}'].join(', ')}.',
  ));
  return GraphRun(nodeLabels: _bfLabels, positions: _bfPositions, edges: _bfEdges, directed: true, frames: frames);
}
