import 'dart:math' as math;

import '../models/frames.dart';
import '../models/graph_trace.dart';

const graphInfinity = 1 << 29;

GraphRun _graph(
  int n,
  List<(int, int, int)> edges, {
  bool directed = false,
  bool weighted = false,
  List<String>? labels,
  List<List<double>>? positions,
}) => GraphRun(
  nodeLabels:
      labels ?? [for (var i = 0; i < n; i++) String.fromCharCode(65 + i)],
  positions:
      positions ??
      [
        for (var i = 0; i < n; i++)
          [
            0.5 + 0.38 * math.cos(-math.pi / 2 + i * 2 * math.pi / n),
            0.5 + 0.38 * math.sin(-math.pi / 2 + i * 2 * math.pi / n),
          ],
      ],
  edges: [
    for (final (a, b, w) in edges)
      directed ? GraphEdge.directed(a, b, w) : GraphEdge(a, b, w),
  ],
  frames: const [],
  directed: directed,
  weighted: weighted,
);

GraphRun _traversalGraph() => _graph(7, [
  (0, 1, 1),
  (0, 2, 1),
  (1, 3, 1),
  (1, 4, 1),
  (2, 4, 1),
  (3, 5, 1),
  (4, 5, 1),
  (5, 6, 1),
]);
GraphRun _weightedGraph() => _graph(6, [
  (0, 1, 4),
  (0, 2, 2),
  (2, 1, 1),
  (1, 3, 5),
  (2, 3, 8),
  (2, 4, 10),
  (3, 4, 2),
  (3, 5, 6),
  (4, 5, 3),
], weighted: true);
GraphRun _componentGraph() => _graph(6, [
  (0, 1, 1),
  (1, 2, 1),
  (2, 0, 1),
  (1, 3, 1),
  (3, 4, 1),
  (4, 3, 1),
  (4, 5, 1),
], directed: true);
GraphRun _cutGraph() => _graph(7, [
  (0, 1, 1),
  (1, 2, 1),
  (2, 0, 1),
  (2, 3, 1),
  (3, 4, 1),
  (4, 5, 1),
  (5, 3, 1),
  (5, 6, 1),
]);
GraphRun _dag() => _graph(
  6,
  [
    (0, 1, 4),
    (0, 2, 2),
    (1, 3, 3),
    (2, 3, 5),
    (2, 4, 6),
    (3, 4, -4),
    (4, 5, 2),
    (3, 5, 4),
  ],
  directed: true,
  weighted: true,
);

class _Trace {
  _Trace(this.graph, {bool? directed}) {
    if (n == 0 || graph.positions.length != n) {
      throw ArgumentError(
        'A graph needs vertices and one position per vertex.',
      );
    }
    if (directed != null && graph.directed != directed) {
      throw ArgumentError(
        directed
            ? 'A directed graph is required.'
            : 'An undirected graph is required.',
      );
    }
    final keys = <int>{};
    for (final e in graph.edges) {
      if (e.a < 0 ||
          e.a >= n ||
          e.b < 0 ||
          e.b >= n ||
          e.directed != graph.directed ||
          !keys.add(e.key)) {
        throw ArgumentError(
          'Edges must be unique, in bounds, and match the graph direction.',
        );
      }
    }
  }
  final GraphRun graph;
  final frames = <GraphTraceFrame>[];
  int get n => graph.nodeLabels.length;
  String label(int node) => graph.nodeLabels[node];
  List<String> names(Iterable<int> nodes) => nodes.map(label).toList();
  String number(int value) => value == graphInfinity ? '∞' : '$value';
  int key(int a, int b) =>
      graph.directed ? GraphEdge.directed(a, b, 0).key : GraphEdge(a, b, 0).key;
  List<List<(int, int)>> adjacency([List<GraphEdge>? edges]) {
    final adj = [for (var i = 0; i < n; i++) <(int, int)>[]];
    final all = edges ?? graph.edges;
    for (var i = 0; i < all.length; i++) {
      final e = all[i];
      adj[e.a].add((e.b, i));
      if (!graph.directed) adj[e.b].add((e.a, i));
    }
    return adj;
  }

  void source(int value) {
    if (value < 0 || value >= n) throw ArgumentError.value(value, 'source');
  }

  void emit(
    String caption, {
    Set<int> visited = const {},
    Set<int> selected = const {},
    int? current,
    int? candidate,
    Map<int, int> colors = const {},
    List<int> order = const [],
    List<int>? distances,
    String frontierLabel = '',
    List<String> frontier = const [],
    List<String> columns = const [],
    List<List<String>> rows = const [],
    String graphTitle = '',
    List<GraphEdge>? edges,
  }) {
    frames.add(
      GraphTraceFrame(
        graph: GraphFrame(
          inTree: {...visited},
          treeEdges: {...selected},
          current: current,
          candidate: candidate,
          colors: {...colors},
          order: [...order],
          dist: distances == null
              ? const {}
              : {for (var i = 0; i < n; i++) i: distances[i]},
          caption: caption,
        ),
        frontierLabel: frontierLabel,
        frontier: frontier,
        columns: columns,
        rows: rows,
        graphTitle: graphTitle,
        edges: edges,
      ),
    );
  }
}

/// FIFO traversal on a graph, with discovery distances and parent edges.
GraphTraceRun graphBreadthFirst({GraphRun? input, int source = 0}) {
  final t = _Trace(input ?? _traversalGraph());
  t.source(source);
  final adj = t.adjacency();
  final queue = <int>[source], order = <int>[];
  final distances = List<int>.filled(t.n, graphInfinity)..[source] = 0;
  final parent = List<int>.filled(t.n, -1);
  final seen = <int>{source}, selected = <int>{};
  var head = 0;
  void snap(String caption, {int? current, int? candidate}) => t.emit(
    caption,
    visited: {...order},
    selected: selected,
    current: current,
    candidate: candidate,
    order: order,
    frontierLabel: 'Queue · front first',
    frontier: t.names(queue.skip(head)),
    columns: ['Vertex', 'Distance', 'Parent'],
    rows: [
      for (var i = 0; i < t.n; i++)
        [
          t.label(i),
          t.number(distances[i]),
          parent[i] < 0 ? '—' : t.label(parent[i]),
        ],
    ],
  );
  snap('Discover ${t.label(source)} at distance 0 and enqueue it.');
  while (head < queue.length) {
    final u = queue[head++];
    order.add(u);
    snap('Dequeue ${t.label(u)}; inspect each adjacent edge.', current: u);
    for (final (v, edge) in adj[u]) {
      if (!seen.add(v)) {
        snap(
          '${t.label(v)} was already discovered; do not enqueue it twice.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
        continue;
      }
      distances[v] = distances[u] + 1;
      parent[v] = u;
      queue.add(v);
      selected.add(t.graph.edges[edge].key);
      snap(
        'Discover ${t.label(v)} through ${t.label(u)} at distance ${distances[v]}.',
        current: v,
        candidate: t.graph.edges[edge].key,
      );
    }
  }
  snap('Queue empty: reached ${order.length} of ${t.n} vertices.');
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    order: order,
    distances: distances,
    resultEdges: selected,
  );
}

/// Recursive graph DFS explicitly shows its call stack and discovery/finish order.
GraphTraceRun graphDepthFirst({GraphRun? input, int source = 0}) {
  final t = _Trace(input ?? _traversalGraph());
  t.source(source);
  final adj = t.adjacency();
  final seen = <int>{}, finished = <int>{}, selected = <int>{};
  final stack = <int>[], order = <int>[];
  final discovery = List<int>.filled(t.n, -1),
      finish = List<int>.filled(t.n, -1);
  var clock = 0;
  void snap(String caption, {int? current, int? candidate}) => t.emit(
    caption,
    visited: finished,
    selected: selected,
    current: current,
    candidate: candidate,
    order: order,
    frontierLabel: 'Call stack · top last',
    frontier: t.names(stack),
    columns: ['Vertex', 'Discover', 'Finish'],
    rows: [
      for (var i = 0; i < t.n; i++)
        [
          t.label(i),
          discovery[i] < 0 ? '—' : '${discovery[i]}',
          finish[i] < 0 ? '—' : '${finish[i]}',
        ],
    ],
  );
  void visit(int u) {
    seen.add(u);
    stack.add(u);
    order.add(u);
    discovery[u] = clock++;
    snap('Enter ${t.label(u)} and push its recursive call.', current: u);
    for (final (v, edge) in adj[u]) {
      snap(
        'Inspect ${t.label(u)}–${t.label(v)}.',
        current: u,
        candidate: t.graph.edges[edge].key,
      );
      if (!seen.contains(v)) {
        selected.add(t.graph.edges[edge].key);
        visit(v);
      }
    }
    stack.removeLast();
    finished.add(u);
    finish[u] = clock++;
    snap('Finish ${t.label(u)} and return to its caller.', current: u);
  }

  snap('Start depth-first traversal at ${t.label(source)}.');
  visit(source);
  snap('Traversal complete: reached ${order.length} of ${t.n} vertices.');
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    order: order,
    resultEdges: selected,
  );
}

/// Dijkstra selects the minimum tentative distance by scanning the frontier.
GraphTraceRun weightedDijkstra({GraphRun? input, int source = 0}) {
  final t = _Trace(input ?? _weightedGraph());
  t.source(source);
  if (t.graph.edges.any((e) => e.w < 0)) {
    throw ArgumentError('Dijkstra requires nonnegative weights.');
  }
  final adj = t.adjacency();
  final distances = List<int>.filled(t.n, graphInfinity)..[source] = 0;
  final parent = List<int>.filled(t.n, -1);
  final open = <int>{source}, settled = <int>{};
  final order = <int>[];
  Set<int> tree() => {
    for (var v = 0; v < t.n; v++)
      if (parent[v] >= 0) t.key(parent[v], v),
  };
  void snap(String caption, {int? current, int? candidate}) {
    final frontier = open.toList()
      ..sort((a, b) => distances[a].compareTo(distances[b]));
    t.emit(
      caption,
      visited: settled,
      selected: tree(),
      current: current,
      candidate: candidate,
      distances: distances,
      frontierLabel: 'Frontier · smallest distance first',
      frontier: [for (final v in frontier) '${t.label(v)}:${distances[v]}'],
      columns: ['Vertex', 'Distance', 'Parent'],
      rows: [
        for (var v = 0; v < t.n; v++)
          [
            t.label(v),
            t.number(distances[v]),
            parent[v] < 0 ? '—' : t.label(parent[v]),
          ],
      ],
    );
  }

  snap('Set ${t.label(source)} to 0; other distances are infinite.');
  while (open.isNotEmpty) {
    final u = open.reduce((a, b) => distances[a] <= distances[b] ? a : b);
    open.remove(u);
    settled.add(u);
    order.add(u);
    snap(
      'Settle ${t.label(u)} at distance ${distances[u]}; this value is final.',
      current: u,
    );
    for (final (v, edge) in adj[u]) {
      if (settled.contains(v)) continue;
      final candidate = distances[u] + t.graph.edges[edge].w;
      if (candidate < distances[v]) {
        distances[v] = candidate;
        parent[v] = u;
        open.add(v);
        snap(
          'Relax ${t.label(u)}→${t.label(v)}: a shorter route costs $candidate.',
          current: v,
          candidate: t.graph.edges[edge].key,
        );
      } else {
        snap(
          'The route through ${t.label(u)} costs $candidate; keep ${t.number(distances[v])} for ${t.label(v)}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
      }
    }
  }
  snap('Frontier empty: all reachable shortest distances are final.');
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    distances: distances,
    order: order,
    resultEdges: tree(),
  );
}

/// Topological ordering by reversing DFS finishing order, with cycle detection.
GraphTraceRun dfsTopologicalSort({GraphRun? input}) {
  final t = _Trace(input ?? _dag(), directed: true);
  final adj = t.adjacency();
  final state = List<int>.filled(t.n, 0), stack = <int>[], finish = <int>[];
  var cycle = false;
  void snap(String caption, {int? current, int? candidate}) => t.emit(
    caption,
    visited: finish.toSet(),
    current: current,
    candidate: candidate,
    frontierLabel: 'Call stack · top last',
    frontier: t.names(stack),
    columns: ['Vertex', 'DFS state', 'Finish rank'],
    rows: [
      for (var i = 0; i < t.n; i++)
        [
          t.label(i),
          ['Unseen', 'On stack', 'Finished'][state[i]],
          finish.contains(i) ? '${finish.indexOf(i) + 1}' : '—',
        ],
    ],
  );
  void visit(int u) {
    state[u] = 1;
    stack.add(u);
    snap('Enter ${t.label(u)}.', current: u);
    for (final (v, edge) in adj[u]) {
      if (state[v] == 1) {
        cycle = true;
        snap(
          'Back edge ${t.label(u)}→${t.label(v)} reaches the current call stack; no topological order exists.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
        return;
      }
      if (state[v] == 0) {
        snap(
          'Follow ${t.label(u)}→${t.label(v)} before finishing ${t.label(u)}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
        visit(v);
        if (cycle) return;
      }
    }
    state[u] = 2;
    stack.removeLast();
    finish.add(u);
    snap(
      'Finish ${t.label(u)} after all of its outgoing neighbours.',
      current: u,
    );
  }

  snap('DFS each component and record finishing order.');
  for (var u = 0; u < t.n && !cycle; u++) {
    if (state[u] == 0) visit(u);
  }
  final order = cycle ? <int>[] : finish.reversed.toList();
  if (!cycle) {
    t.emit(
      'Reverse finishing order: ${t.names(order).join(' → ')}.',
      visited: order.toSet(),
      order: order,
      frontierLabel: 'Topological order',
      frontier: t.names(order),
    );
  }
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    order: order,
    success: !cycle,
  );
}

/// Kosaraju uses finishing order, then traverses the graph with all arcs reversed.
GraphTraceRun kosarajuComponents({GraphRun? input}) {
  final t = _Trace(input ?? _componentGraph(), directed: true);
  final adj = t.adjacency(), seen = <int>{}, finish = <int>[], stack = <int>[];
  final components = <List<int>>[], colors = <int, int>{};
  final transpose = [
    for (final e in t.graph.edges) GraphEdge.directed(e.b, e.a, e.w),
  ];
  final reverseAdj = t.adjacency(transpose);
  void snap(
    String caption, {
    int? current,
    int? candidate,
    bool reversed = false,
  }) => t.emit(
    caption,
    visited: seen,
    current: current,
    candidate: candidate,
    colors: colors,
    frontierLabel: 'Call stack · top last',
    frontier: t.names(stack),
    graphTitle: reversed
        ? 'Pass 2 · transposed graph'
        : 'Pass 1 · original graph',
    edges: reversed ? transpose : null,
    columns: ['Vertex', 'Finish rank', 'Component'],
    rows: [
      for (var u = 0; u < t.n; u++)
        [
          t.label(u),
          finish.contains(u) ? '${finish.indexOf(u) + 1}' : '—',
          colors.containsKey(u) ? '${colors[u]! + 1}' : '—',
        ],
    ],
  );
  void first(int u) {
    seen.add(u);
    stack.add(u);
    snap('First pass: enter ${t.label(u)}.', current: u);
    for (final (v, edge) in adj[u]) {
      if (!seen.contains(v)) {
        snap(
          'Follow ${t.label(u)}→${t.label(v)}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
        first(v);
      }
    }
    stack.removeLast();
    finish.add(u);
    snap('Finish ${t.label(u)} and append it to finishing order.', current: u);
  }

  snap('First pass computes finishing order on the original directed graph.');
  for (var u = 0; u < t.n; u++) {
    if (!seen.contains(u)) first(u);
  }
  seen.clear();
  snap(
    'Reverse every arc. Process vertices in decreasing finish time.',
    reversed: true,
  );
  void second(int u, List<int> component) {
    seen.add(u);
    stack.add(u);
    component.add(u);
    colors[u] = components.length;
    snap(
      '${t.label(u)} belongs to component ${components.length + 1}.',
      current: u,
      reversed: true,
    );
    for (final (v, edge) in reverseAdj[u]) {
      if (!seen.contains(v)) {
        snap(
          'Follow reversed arc ${t.label(u)}→${t.label(v)}.',
          current: u,
          candidate: transpose[edge].key,
          reversed: true,
        );
        second(v, component);
      }
    }
    stack.removeLast();
  }

  for (final u in finish.reversed) {
    if (seen.contains(u)) continue;
    final component = <int>[];
    second(u, component);
    components.add(component);
    snap(
      'Component ${components.length} complete: ${t.names(component).join(', ')}.',
      reversed: true,
    );
  }
  t.emit(
    'Found ${components.length} strongly connected components; restore the original arrows.',
    colors: colors,
    visited: seen,
    columns: ['Component', 'Vertices'],
    rows: [
      for (var i = 0; i < components.length; i++)
        ['${i + 1}', t.names(components[i]).join(', ')],
    ],
  );
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    components: components,
  );
}

/// Tarjan computes SCCs in one DFS, tracking discovery indices and lowlinks.
GraphTraceRun tarjanComponents({GraphRun? input}) {
  final t = _Trace(input ?? _componentGraph(), directed: true);
  final adj = t.adjacency();
  final discovery = List<int>.filled(t.n, -1), low = List<int>.filled(t.n, -1);
  final stack = <int>[], onStack = <int>{}, components = <List<int>>[];
  final colors = <int, int>{};
  var next = 0;
  void snap(String caption, {int? current, int? candidate}) => t.emit(
    caption,
    current: current,
    candidate: candidate,
    colors: colors,
    frontierLabel: 'SCC stack · top last',
    frontier: t.names(stack),
    columns: ['Vertex', 'Index', 'Low', 'On stack'],
    rows: [
      for (var u = 0; u < t.n; u++)
        [
          t.label(u),
          discovery[u] < 0 ? '—' : '${discovery[u]}',
          low[u] < 0 ? '—' : '${low[u]}',
          onStack.contains(u) ? 'Yes' : 'No',
        ],
    ],
  );
  void visit(int u) {
    discovery[u] = low[u] = next++;
    stack.add(u);
    onStack.add(u);
    snap(
      'Discover ${t.label(u)} with index ${discovery[u]}; push it onto the SCC stack.',
      current: u,
    );
    for (final (v, edge) in adj[u]) {
      if (discovery[v] < 0) {
        visit(v);
        low[u] = math.min(low[u], low[v]);
        snap(
          'Return from ${t.label(v)}: low[${t.label(u)}] becomes ${low[u]}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
      } else if (onStack.contains(v)) {
        low[u] = math.min(low[u], discovery[v]);
        snap(
          '${t.label(v)} is still on the SCC stack; lower ${t.label(u)} to index ${low[u]}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
      } else {
        snap(
          '${t.label(v)} is already assigned to a component; ignore this cross edge.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
      }
    }
    if (low[u] == discovery[u]) {
      final component = <int>[];
      int v;
      do {
        v = stack.removeLast();
        onStack.remove(v);
        component.add(v);
        colors[v] = components.length;
        snap(
          'Pop ${t.label(v)} into component ${components.length + 1}; ${t.label(u)} is its root.',
          current: v,
        );
      } while (v != u);
      components.add(component);
    }
  }

  snap(
    'Run one DFS; each lowlink records the earliest active vertex reachable.',
  );
  for (var u = 0; u < t.n; u++) {
    if (discovery[u] < 0) visit(u);
  }
  snap(
    'SCC stack empty: found ${components.length} strongly connected components.',
  );
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    components: components,
  );
}

GraphTraceRun _cuts({GraphRun? input, required bool articulation}) {
  final t = _Trace(input ?? _cutGraph(), directed: false);
  final adj = t.adjacency();
  final discovery = List<int>.filled(t.n, -1), low = List<int>.filled(t.n, -1);
  final parent = List<int>.filled(t.n, -1), stack = <int>[];
  final bridges = <int>{}, vertices = <int>{}, finished = <int>{};
  var clock = 0;
  void snap(String caption, {int? current, int? candidate}) => t.emit(
    caption,
    visited: finished,
    selected: articulation ? const {} : bridges,
    colors: articulation ? {for (final u in vertices) u: 1} : const {},
    current: current,
    candidate: candidate,
    frontierLabel: 'DFS call stack · top last',
    frontier: t.names(stack),
    columns: ['Vertex', 'Discover', 'Low', 'Parent'],
    rows: [
      for (var u = 0; u < t.n; u++)
        [
          t.label(u),
          discovery[u] < 0 ? '—' : '${discovery[u]}',
          low[u] < 0 ? '—' : '${low[u]}',
          parent[u] < 0 ? '—' : t.label(parent[u]),
        ],
    ],
  );
  void visit(int u, int parentEdge) {
    discovery[u] = low[u] = clock++;
    stack.add(u);
    var children = 0;
    snap('Discover ${t.label(u)} at time ${discovery[u]}.', current: u);
    for (final (v, edge) in adj[u]) {
      if (edge == parentEdge) continue;
      if (discovery[v] < 0) {
        parent[v] = u;
        children++;
        visit(v, edge);
        low[u] = math.min(low[u], low[v]);
        if (low[v] > discovery[u]) bridges.add(t.graph.edges[edge].key);
        if (parentEdge >= 0 && low[v] >= discovery[u]) vertices.add(u);
        final separates = articulation
            ? parentEdge >= 0 && low[v] >= discovery[u]
            : low[v] > discovery[u];
        snap(
          separates
              ? articulation
                    ? 'low[${t.label(v)}] = ${low[v]} ≥ discover[${t.label(u)}] = ${discovery[u]}; removing ${t.label(u)} separates this child.'
                    : 'low[${t.label(v)}] = ${low[v]} > discover[${t.label(u)}] = ${discovery[u]}; ${t.label(u)}–${t.label(v)} is a bridge.'
              : 'Return from ${t.label(v)}; update low[${t.label(u)}] to ${low[u]}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
      } else {
        low[u] = math.min(low[u], discovery[v]);
        snap(
          'Back edge to ${t.label(v)} gives low[${t.label(u)}] = ${low[u]}.',
          current: u,
          candidate: t.graph.edges[edge].key,
        );
      }
    }
    if (parentEdge < 0 && children > 1) {
      vertices.add(u);
      snap(
        'DFS root ${t.label(u)} has $children children; it is an articulation point.',
        current: u,
      );
    }
    stack.removeLast();
    finished.add(u);
  }

  snap(
    articulation
        ? 'Find vertices whose removal disconnects an undirected graph.'
        : 'Find edges with no alternate route around them.',
  );
  for (var u = 0; u < t.n; u++) {
    if (discovery[u] < 0) visit(u, -1);
  }
  snap(
    articulation
        ? 'Found ${vertices.length} articulation points: ${t.names(vertices).join(', ')}.'
        : 'Found ${bridges.length} bridges; highlighted edges are the only routes between their sides.',
  );
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    resultEdges: articulation ? const {} : bridges,
    resultVertices: articulation ? vertices : const {},
  );
}

GraphTraceRun graphBridges({GraphRun? input}) =>
    _cuts(input: input, articulation: false);
GraphTraceRun articulationPoints({GraphRun? input}) =>
    _cuts(input: input, articulation: true);

/// BFS two-colouring either produces a partition or an explicit odd cycle.
GraphTraceRun bipartiteCheck({GraphRun? input}) {
  final t = _Trace(
    input ??
        _graph(6, [
          (0, 1, 1),
          (1, 2, 1),
          (2, 3, 1),
          (3, 4, 1),
          (4, 0, 1),
          (2, 5, 1),
        ]),
    directed: false,
  );
  final adj = t.adjacency(), colors = <int, int>{};
  final parent = List<int>.filled(t.n, -1), queue = <int>[];
  var head = 0;
  void snap(
    String caption, {
    int? current,
    int? candidate,
    List<int>? witness,
  }) => t.emit(
    caption,
    colors: colors,
    current: current,
    candidate: candidate,
    frontierLabel: witness == null
        ? 'Queue · front first'
        : 'Odd-cycle witness',
    frontier: t.names(witness ?? queue.skip(head).toList()),
    columns: ['Vertex', 'Colour', 'Parent'],
    rows: [
      for (var u = 0; u < t.n; u++)
        [
          t.label(u),
          colors.containsKey(u) ? '${colors[u]! + 1}' : '—',
          parent[u] < 0 ? '—' : t.label(parent[u]),
        ],
    ],
  );
  List<int> oddCycle(int u, int v) {
    final left = <int>[], right = <int>[];
    for (var x = u; x >= 0; x = parent[x]) {
      left.add(x);
    }
    for (var x = v; x >= 0; x = parent[x]) {
      right.add(x);
    }
    var i = left.length - 1, j = right.length - 1;
    while (i >= 0 && j >= 0 && left[i] == right[j]) {
      i--;
      j--;
    }
    return [...left.take(i + 2), ...right.take(j + 1).toList().reversed, u];
  }

  snap('Try to colour every edge with opposite colours at its endpoints.');
  for (var start = 0; start < t.n; start++) {
    if (colors.containsKey(start)) continue;
    colors[start] = 0;
    queue.add(start);
    snap(
      'Start a new component at ${t.label(start)} with colour 1.',
      current: start,
    );
    while (head < queue.length) {
      final u = queue[head++];
      for (final (v, edge) in adj[u]) {
        if (!colors.containsKey(v)) {
          colors[v] = 1 - colors[u]!;
          parent[v] = u;
          queue.add(v);
          snap(
            'Give ${t.label(v)} the opposite colour to ${t.label(u)}.',
            current: v,
            candidate: t.graph.edges[edge].key,
          );
        } else if (colors[v] == colors[u]) {
          final witness = oddCycle(u, v);
          snap(
            '${t.label(u)} and ${t.label(v)} share a colour: an odd cycle of ${witness.length - 1} edges proves this graph is not bipartite.',
            current: u,
            candidate: t.graph.edges[edge].key,
            witness: witness,
          );
          return GraphTraceRun(
            graph: t.graph,
            frames: t.frames,
            success: false,
            path: witness,
          );
        }
      }
    }
  }
  snap('Every edge joins opposite colours: the graph is bipartite.');
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    success: true,
    components: [
      for (var c = 0; c < 2; c++)
        [
          for (var u = 0; u < t.n; u++)
            if (colors[u] == c) u,
        ],
    ],
  );
}

/// Hierholzer consumes each undirected edge once and builds the trail backwards.
GraphTraceRun eulerianTrail({GraphRun? input}) {
  final t = _Trace(
    input ??
        _graph(6, [
          (0, 1, 1),
          (1, 2, 1),
          (2, 0, 1),
          (2, 3, 1),
          (3, 4, 1),
          (4, 2, 1),
          (4, 5, 1),
        ]),
    directed: false,
  );
  final adj = t.adjacency();
  final odd = [
    for (var u = 0; u < t.n; u++)
      if (adj[u].length.isOdd) u,
  ];
  final used = <int>{}, stack = <int>[], circuit = <int>[];
  final cursor = List<int>.filled(t.n, 0);
  void snap(String caption, {int? candidate}) => t.emit(
    caption,
    visited: circuit.toSet(),
    selected: {for (final i in used) t.graph.edges[i].key},
    current: stack.isEmpty ? null : stack.last,
    candidate: candidate,
    frontierLabel: 'Walk stack · top last',
    frontier: t.names(stack),
    columns: ['State', 'Vertices'],
    rows: [
      ['Odd-degree vertices', t.names(odd).join(', ')],
      ['Reverse output', t.names(circuit).join(' → ')],
      ['Trail so far', t.names(circuit.reversed).join(' → ')],
    ],
  );
  snap(
    'An Euler trail uses every edge exactly once; zero or two vertices may have odd degree.',
  );
  if (odd.isNotEmpty && odd.length != 2) {
    snap('${odd.length} odd-degree vertices: no Euler trail exists.');
    return GraphTraceRun(graph: t.graph, frames: t.frames, success: false);
  }
  final start = odd.isNotEmpty
      ? odd.first
      : List.generate(
          t.n,
          (i) => i,
        ).firstWhere((u) => adj[u].isNotEmpty, orElse: () => 0);
  stack.add(start);
  snap('Start at ${t.label(start)}.');
  while (stack.isNotEmpty) {
    final u = stack.last;
    while (cursor[u] < adj[u].length && used.contains(adj[u][cursor[u]].$2)) {
      cursor[u]++;
    }
    if (cursor[u] == adj[u].length) {
      circuit.add(stack.removeLast());
      snap('No unused edge leaves ${t.label(u)}; append it to reverse output.');
    } else {
      final (v, edge) = adj[u][cursor[u]++];
      used.add(edge);
      stack.add(v);
      snap(
        'Consume ${t.label(u)}–${t.label(v)} and continue at ${t.label(v)}.',
        candidate: t.graph.edges[edge].key,
      );
    }
  }
  final complete = used.length == t.graph.edges.length;
  final path = complete ? circuit.reversed.toList() : <int>[];
  snap(
    complete
        ? 'Reverse the output: an Euler trail uses all ${used.length} edges.'
        : 'Some edges lie in another component; there is no trail using every edge.',
  );
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    path: path,
    success: complete,
    resultEdges: {for (final i in used) t.graph.edges[i].key},
  );
}

/// A DAG permits one relaxation pass in topological order, even with negative edges.
GraphTraceRun dagShortestPaths({GraphRun? input, int source = 0}) {
  final t = _Trace(input ?? _dag(), directed: true);
  t.source(source);
  final topo = dfsTopologicalSort(input: t.graph);
  t.frames.addAll(topo.frames);
  if (topo.success != true) {
    return GraphTraceRun(graph: t.graph, frames: t.frames, success: false);
  }
  final adj = t.adjacency();
  final distances = List<int>.filled(t.n, graphInfinity)..[source] = 0;
  final parent = List<int>.filled(t.n, -1), settled = <int>{};
  var at = 0;
  Set<int> tree() => {
    for (var v = 0; v < t.n; v++)
      if (parent[v] >= 0) t.key(parent[v], v),
  };
  void snap(String caption, {int? current, int? candidate}) => t.emit(
    caption,
    visited: settled,
    selected: tree(),
    distances: distances,
    current: current,
    candidate: candidate,
    frontierLabel: 'Remaining topological order',
    frontier: t.names(topo.order.skip(at)),
    columns: ['Vertex', 'Distance', 'Parent'],
    rows: [
      for (var v = 0; v < t.n; v++)
        [
          t.label(v),
          t.number(distances[v]),
          parent[v] < 0 ? '—' : t.label(parent[v]),
        ],
    ],
  );
  snap(
    'Use the computed topological order; source ${t.label(source)} starts at 0.',
  );
  for (final u in topo.order) {
    at++;
    settled.add(u);
    if (distances[u] == graphInfinity) {
      snap(
        '${t.label(u)} is unreachable from ${t.label(source)}; skip its outgoing edges.',
        current: u,
      );
      continue;
    }
    snap(
      'Process ${t.label(u)} after every predecessor; its distance ${distances[u]} is final.',
      current: u,
    );
    for (final (v, edge) in adj[u]) {
      final next = distances[u] + t.graph.edges[edge].w;
      final improves = next < distances[v];
      if (improves) {
        distances[v] = next;
        parent[v] = u;
      }
      snap(
        improves
            ? 'Relax ${t.label(u)}→${t.label(v)} to $next, including its possibly negative weight.'
            : 'Route through ${t.label(u)} costs $next; ${t.label(v)} already has ${t.number(distances[v])}.',
        current: v,
        candidate: t.graph.edges[edge].key,
      );
    }
  }
  snap('One ordered relaxation pass completes the shortest paths.');
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    success: true,
    order: topo.order,
    distances: distances,
    resultEdges: tree(),
  );
}

/// Borůvka simultaneously chooses the cheapest outgoing edge of each component.
GraphTraceRun boruvkaMst({GraphRun? input}) {
  final t = _Trace(input ?? _weightedGraph(), directed: false);
  final parent = List.generate(t.n, (i) => i), size = List<int>.filled(t.n, 1);
  final selected = <int>{}, cheapest = <int, int>{};
  var count = t.n, total = 0, phase = 0;
  int find(int u) {
    while (parent[u] != u) {
      parent[u] = parent[parent[u]];
      u = parent[u];
    }
    return u;
  }

  String edgeName(int edge) {
    final e = t.graph.edges[edge];
    return '${t.label(e.a)}–${t.label(e.b)} (${e.w})';
  }

  void snap(String caption, {int? candidate}) => t.emit(
    caption,
    selected: selected,
    candidate: candidate,
    colors: {for (var u = 0; u < t.n; u++) u: find(u)},
    frontierLabel: 'Phase $phase · $count components · total weight $total',
    frontier: [for (final edge in cheapest.values.toSet()) edgeName(edge)],
    columns: ['Vertex', 'Component', 'Cheapest exit'],
    rows: [
      for (var u = 0; u < t.n; u++)
        [
          t.label(u),
          t.label(find(u)),
          cheapest.containsKey(find(u)) ? edgeName(cheapest[find(u)]!) : '—',
        ],
    ],
  );
  snap(
    'Start with one component per vertex; each chooses its cheapest outgoing edge.',
  );
  while (count > 1) {
    phase++;
    cheapest.clear();
    for (var i = 0; i < t.graph.edges.length; i++) {
      final e = t.graph.edges[i],
          a = find(t.graph.edges[i].a),
          b = find(t.graph.edges[i].b);
      if (a == b) continue;
      for (final root in [a, b]) {
        if (!cheapest.containsKey(root) ||
            e.w < t.graph.edges[cheapest[root]!].w) {
          cheapest[root] = i;
        }
      }
      snap(
        'Consider ${edgeName(i)} for the two components it connects.',
        candidate: e.key,
      );
    }
    var merged = false;
    for (final edge in cheapest.values.toSet()) {
      final e = t.graph.edges[edge];
      var a = find(e.a), b = find(e.b);
      if (a == b) continue;
      if (size[a] < size[b]) {
        final swap = a;
        a = b;
        b = swap;
      }
      parent[b] = a;
      size[a] += size[b];
      count--;
      merged = true;
      selected.add(e.key);
      total += e.w;
      snap('Add ${edgeName(edge)} and merge its components.', candidate: e.key);
    }
    if (!merged) break;
  }
  cheapest.clear();
  snap(
    count == 1
        ? 'Minimum spanning tree complete: total weight $total.'
        : 'No edge joins the remaining $count components; minimum spanning forest weight $total.',
  );
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    resultEdges: selected,
    total: total,
    success: count == 1,
  );
}

/// Edmonds–Karp finds shortest residual augmenting paths with BFS. The default
/// network requires a reverse residual edge to undo part of its first path.
GraphTraceRun edmondsKarp({GraphRun? input, int source = 0, int? sink}) {
  final t = _Trace(
    input ??
        _graph(
          6,
          [
            (0, 1, 1),
            (0, 2, 1),
            (1, 3, 1),
            (1, 4, 1),
            (2, 3, 1),
            (3, 5, 1),
            (4, 5, 1),
          ],
          directed: true,
          weighted: true,
          labels: ['S', 'A', 'B', 'C', 'D', 'T'],
          positions: [
            [0.06, 0.5],
            [0.3, 0.2],
            [0.3, 0.8],
            [0.65, 0.2],
            [0.65, 0.8],
            [0.94, 0.5],
          ],
        ),
    directed: true,
  );
  final target = sink ?? t.n - 1;
  t.source(source);
  t.source(target);
  if (source == target || t.graph.edges.any((e) => e.w < 0)) {
    throw ArgumentError(
      'Flow requires distinct endpoints and nonnegative capacities.',
    );
  }
  final capacity = [for (var i = 0; i < t.n; i++) List<int>.filled(t.n, 0)];
  final residual = [for (var i = 0; i < t.n; i++) List<int>.filled(t.n, 0)];
  final flow = [for (var i = 0; i < t.n; i++) List<int>.filled(t.n, 0)];
  final adj = [for (var i = 0; i < t.n; i++) <int>{}];
  for (final e in t.graph.edges) {
    capacity[e.a][e.b] = residual[e.a][e.b] = e.w;
    adj[e.a].add(e.b);
    adj[e.b].add(e.a);
  }
  var total = 0, head = 0;
  final queue = <int>[], reached = <int>{};
  List<GraphEdge> residualEdges() => [
    for (var u = 0; u < t.n; u++)
      for (final v in adj[u])
        if (residual[u][v] > 0) GraphEdge.directed(u, v, residual[u][v]),
  ];
  void snap(
    String caption, {
    int? current,
    int? candidate,
    List<int>? path,
    bool cut = false,
  }) => t.emit(
    caption,
    visited: reached,
    current: current,
    candidate: candidate,
    selected: path == null
        ? const {}
        : {for (var i = 1; i < path.length; i++) t.key(path[i - 1], path[i])},
    colors: cut
        ? {for (var u = 0; u < t.n; u++) u: reached.contains(u) ? 0 : 1}
        : const {},
    edges: residualEdges(),
    graphTitle: 'Residual network · edge labels show available capacity',
    frontierLabel: path == null
        ? 'BFS queue · current flow $total'
        : 'Augmenting path · current flow $total',
    frontier: t.names(path ?? queue.skip(head).toList()),
    columns: ['Arc', 'Flow', 'Capacity', 'Residual'],
    rows: [
      for (final e in t.graph.edges)
        [
          '${t.label(e.a)}→${t.label(e.b)}',
          '${flow[e.a][e.b]}',
          '${capacity[e.a][e.b]}',
          '${residual[e.a][e.b]}',
        ],
    ],
  );
  snap('Start with zero flow; search the residual network by BFS.');
  while (true) {
    final parent = List<int>.filled(t.n, -1);
    queue
      ..clear()
      ..add(source);
    reached
      ..clear()
      ..add(source);
    head = 0;
    snap('Start another BFS at ${t.label(source)}.', current: source);
    while (head < queue.length && !reached.contains(target)) {
      final u = queue[head++];
      for (final v in adj[u]) {
        if (residual[u][v] <= 0 || !reached.add(v)) continue;
        parent[v] = u;
        queue.add(v);
        snap(
          'Residual edge ${t.label(u)}→${t.label(v)} has capacity ${residual[u][v]}; discover ${t.label(v)}.',
          current: v,
          candidate: t.key(u, v),
        );
        if (v == target) break;
      }
    }
    if (!reached.contains(target)) break;
    final reverse = <int>[target];
    var bottleneck = graphInfinity;
    for (var v = target; v != source; v = parent[v]) {
      bottleneck = math.min(bottleneck, residual[parent[v]][v]);
      reverse.add(parent[v]);
    }
    final path = reverse.reversed.toList();
    snap(
      'Augment by the path bottleneck $bottleneck. Reverse residual arcs cancel earlier flow.',
      path: path,
    );
    for (var i = 1; i < path.length; i++) {
      final u = path[i - 1], v = path[i];
      final cancelled = math.min(bottleneck, flow[v][u]);
      flow[v][u] -= cancelled;
      flow[u][v] += bottleneck - cancelled;
      residual[u][v] -= bottleneck;
      residual[v][u] += bottleneck;
    }
    total += bottleneck;
    snap('Flow is now $total; update forward and reverse residual capacities.');
  }
  final cutEdges = {
    for (final e in t.graph.edges)
      if (reached.contains(e.a) && !reached.contains(e.b)) e.key,
  };
  snap(
    'No residual path reaches ${t.label(target)}: maximum flow $total equals the capacity of the displayed cut.',
    cut: true,
  );
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    flow: flow,
    total: total,
    resultVertices: reached,
    resultEdges: cutEdges,
    success: true,
  );
}

/// Warshall's boolean recurrence grows reachability through intermediate vertices.
GraphTraceRun warshallClosure({GraphRun? input}) {
  final t = _Trace(
    input ??
        _graph(5, [
          (0, 1, 1),
          (1, 2, 1),
          (2, 0, 1),
          (2, 3, 1),
          (3, 4, 1),
        ], directed: true),
    directed: true,
  );
  final reachable = [
    for (var u = 0; u < t.n; u++)
      [for (var v = 0; v < t.n; v++) u == v ? 1 : 0],
  ];
  for (final e in t.graph.edges) {
    reachable[e.a][e.b] = 1;
  }
  List<GraphEdge> closureEdges() => [
    for (var u = 0; u < t.n; u++)
      for (var v = 0; v < t.n; v++)
        if (u != v && reachable[u][v] == 1) GraphEdge.directed(u, v, 1),
  ];
  void snap(
    String caption, {
    int? current,
    int? candidate,
    Set<int> selected = const {},
  }) => t.emit(
    caption,
    current: current,
    candidate: candidate,
    selected: selected,
    edges: closureEdges(),
    graphTitle: 'Reachability graph · arrows include paths discovered so far',
    columns: ['From / to', ...t.graph.nodeLabels],
    rows: [
      for (var u = 0; u < t.n; u++)
        [t.label(u), ...reachable[u].map((value) => '$value')],
    ],
  );
  snap('Start with direct edges and each vertex reaching itself (diagonal 1).');
  for (var k = 0; k < t.n; k++) {
    snap('Allow ${t.label(k)} as the next intermediate vertex.', current: k);
    for (var u = 0; u < t.n; u++) {
      for (var v = 0; v < t.n; v++) {
        if (reachable[u][v] == 0 &&
            reachable[u][k] == 1 &&
            reachable[k][v] == 1) {
          reachable[u][v] = 1;
          snap(
            '${t.label(u)} reaches ${t.label(k)}, which reaches ${t.label(v)}; add ${t.label(u)}→${t.label(v)}.',
            current: k,
            candidate: t.key(u, v),
            selected: {if (u != k) t.key(u, k), if (k != v) t.key(k, v)},
          );
        }
      }
    }
  }
  snap(
    'Transitive closure complete: every 1 records a reachable ordered pair.',
  );
  return GraphTraceRun(graph: t.graph, frames: t.frames, matrix: reachable);
}

/// Backtracking tries a Hamiltonian cycle, undoing choices at dead ends.
GraphTraceRun hamiltonianCycle({GraphRun? input, int source = 0}) {
  final t = _Trace(
    input ??
        _graph(6, [
          (0, 2, 1),
          (0, 1, 1),
          (1, 2, 1),
          (2, 3, 1),
          (3, 4, 1),
          (4, 5, 1),
          (5, 0, 1),
        ]),
    directed: false,
  );
  t.source(source);
  final adj = t.adjacency(), path = <int>[source], onPath = <int>{source};
  var solution = <int>[];
  Set<int> pathEdges() => {
    for (var i = 1; i < path.length; i++) t.key(path[i - 1], path[i]),
  };
  void snap(String caption, {int? candidate, bool solved = false}) => t.emit(
    caption,
    visited: onPath,
    selected: {...pathEdges(), if (solved) t.key(path.last, source)},
    current: path.last,
    candidate: candidate,
    frontierLabel: 'Current path · last vertex is the next decision',
    frontier: t.names(solved ? solution : path),
    columns: ['Vertex', 'On path', 'Position'],
    rows: [
      for (var u = 0; u < t.n; u++)
        [
          t.label(u),
          onPath.contains(u) ? 'Yes' : 'No',
          onPath.contains(u) ? '${path.indexOf(u) + 1}' : '—',
        ],
    ],
  );
  bool extend() {
    final u = path.last;
    if (path.length == t.n) {
      if (adj[u].any((entry) => entry.$1 == source)) {
        solution = [...path, source];
        snap(
          'Every vertex is used once and the last edge returns to ${t.label(source)}: Hamiltonian cycle found.',
          candidate: t.key(u, source),
          solved: true,
        );
        return true;
      }
      snap(
        'All vertices were used, but ${t.label(u)} cannot return to ${t.label(source)}; backtrack.',
      );
      return false;
    }
    for (final (v, edge) in adj[u]) {
      if (onPath.contains(v)) continue;
      path.add(v);
      onPath.add(v);
      snap(
        'Choose ${t.label(v)} after ${t.label(u)}.',
        candidate: t.graph.edges[edge].key,
      );
      if (extend()) return true;
      path.removeLast();
      onPath.remove(v);
      snap(
        'Dead end: remove ${t.label(v)} and try another neighbour of ${t.label(u)}.',
        candidate: t.graph.edges[edge].key,
      );
    }
    return false;
  }

  snap(
    'Fix ${t.label(source)} as the start; try unused neighbours and backtrack when necessary.',
  );
  final solved = t.n >= 3 && extend();
  if (!solved) {
    snap('No Hamiltonian cycle exists in this simple undirected graph.');
  }
  return GraphTraceRun(
    graph: t.graph,
    frames: t.frames,
    path: solution,
    success: solved,
    resultEdges: solved ? {...pathEdges(), t.key(path.last, source)} : const {},
  );
}
