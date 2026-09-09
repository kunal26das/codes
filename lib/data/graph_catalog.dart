import '../algorithms/graph_extensions.dart';
import '../models/algorithm.dart';
import '../models/graph_trace.dart';
import '../models/viz_run.dart';
import '../visualizers/graph_trace_view.dart';

VizRun _run(GraphTraceRun trace) => VizRun(
  frameCount: trace.frames.length,
  captionAt: (index) => trace.frames[index].graph.caption,
  builder: (context, index) =>
      GraphTraceView(run: trace, frame: trace.frames[index]),
);

AlgorithmInfo _entry({
  required String id,
  required String name,
  required String blurb,
  required String description,
  required String time,
  String space = 'O(V + E)',
  AlgoCategory category = AlgoCategory.graphs,
  required GraphTraceRun Function() create,
}) => AlgorithmInfo(
  id: id,
  name: name,
  category: category,
  blurb: blurb,
  description: description,
  timeComplexity: time,
  spaceComplexity: space,
  originalSources: const ['Dart'],
  create: () => _run(create()),
);

/// Graph algorithms with visible worklists, tables and independently testable results.
final List<AlgorithmInfo> graphExtensions = [
  _entry(
    id: 'graph-bfs',
    name: 'Graph Breadth-First Traversal',
    blurb: 'A queue discovers neighbours in distance layers.',
    description:
        'Breadth-first traversal starts at one graph vertex and discovers each reachable neighbour once. The queue, parent tree and distance table explain why first discovery gives the fewest edges from the source.',
    time: 'O(V + E)',
    create: graphBreadthFirst,
  ),
  _entry(
    id: 'graph-dfs',
    name: 'Graph Depth-First Traversal',
    blurb: 'Follow the call stack through a graph.',
    description:
        'Depth-first traversal explores one branch completely before returning to its caller. Discovery and finishing times, the recursive call stack and highlighted tree edges expose both the descent and the backtracking.',
    time: 'O(V + E)',
    create: graphDepthFirst,
  ),
  _entry(
    id: 'weighted-dijkstra',
    name: 'Weighted Graph Dijkstra',
    blurb: 'Settle minimum distances across unequal edge costs.',
    description:
        'Dijkstra repeatedly settles the frontier vertex with the smallest tentative distance, then relaxes its outgoing edges. This graph uses unequal nonnegative weights and scans the frontier rather than using a heap; distances and predecessor edges update together.',
    time: 'O(V² + E)',
    create: weightedDijkstra,
  ),
  _entry(
    id: 'dfs-topological-sort',
    name: 'DFS Topological Sort',
    blurb: 'Reverse finishing order to put dependencies first.',
    description:
        'A DFS topological sort finishes every outgoing neighbour before finishing its parent. Reversing that finishing order places every edge from earlier to later. A back edge into the current call stack detects a cycle instead of returning an invalid order.',
    time: 'O(V + E)',
    create: dfsTopologicalSort,
  ),
  _entry(
    id: 'kosaraju-scc',
    name: 'Kosaraju Strongly Connected Components',
    blurb: 'Two DFS passes isolate mutually reachable groups.',
    description:
        'Kosaraju first records DFS finishing times, then reverses every arrow and explores vertices in decreasing finish order. Each second-pass traversal yields one strongly connected component. The visualization switches to the transposed graph for that pass.',
    time: 'O(V + E)',
    create: kosarajuComponents,
  ),
  _entry(
    id: 'tarjan-scc',
    name: 'Tarjan Strongly Connected Components',
    blurb: 'A stack and lowlinks find components in one DFS.',
    description:
        'Tarjan assigns a discovery index and a lowlink to each vertex while keeping unresolved vertices on a stack. When a vertex is the root of an SCC, the algorithm pops that entire component. The table distinguishes active stack vertices from already assigned components.',
    time: 'O(V + E)',
    create: tarjanComponents,
  ),
  _entry(
    id: 'graph-bridges',
    name: 'Bridge Detection',
    blurb: 'Find edges whose removal disconnects the graph.',
    description:
        'During an undirected DFS, lowlinks reveal whether a child subtree can reach an ancestor without using its parent edge. A tree edge is a bridge exactly when the child lowlink exceeds the parent discovery time. Bridges remain highlighted as the DFS returns.',
    time: 'O(V + E)',
    create: graphBridges,
  ),
  _entry(
    id: 'articulation-points',
    name: 'Articulation Points',
    blurb: 'Find vertices whose removal separates components.',
    description:
        'A non-root DFS vertex is an articulation point when a child subtree cannot reach a strict ancestor. The root is a separate case: it must have more than one DFS child. Discovery times, lowlinks and parent pointers show why each vertex qualifies.',
    time: 'O(V + E)',
    create: articulationPoints,
  ),
  _entry(
    id: 'bipartite-check',
    name: 'Bipartite Graph Check',
    blurb: 'Two-colour the graph or expose an odd cycle.',
    description:
        'BFS gives each neighbour the opposite colour and restarts for disconnected components. An edge joining equal colours proves the graph is not bipartite; parent pointers reconstruct an explicit odd cycle as a witness. Otherwise the two colour classes form a valid partition.',
    time: 'O(V + E)',
    create: bipartiteCheck,
  ),
  _entry(
    id: 'eulerian-trail',
    name: 'Hierholzer Eulerian Trail',
    blurb: 'Consume every edge exactly once using a walk stack.',
    description:
        'Hierholzer follows unused edges until blocked, then appends exhausted vertices to reverse output. Reversing that output splices the walks into an Euler trail. Odd-degree counts and a final edge-count check reject graphs with no complete trail.',
    time: 'O(V + E)',
    create: eulerianTrail,
  ),
  _entry(
    id: 'dag-shortest-paths',
    name: 'DAG Shortest Paths',
    blurb: 'One ordered relaxation pass handles negative edges.',
    description:
        'A directed acyclic graph permits shortest paths in linear time: process vertices in topological order and relax each outgoing edge once. The demo first computes that order, then shows distance and parent updates, including an improving negative edge.',
    time: 'O(V + E)',
    create: dagShortestPaths,
  ),
  _entry(
    id: 'boruvka-mst',
    name: 'Borůvka Minimum Spanning Tree',
    blurb: 'Every component chooses its cheapest way out.',
    description:
        'Borůvka begins with singleton components. In each phase every component chooses its cheapest outgoing edge; union–find merges components while skipping choices that became redundant. Colours and a cheapest-exit table show the phases, and disconnected inputs produce a minimum spanning forest.',
    time: 'O(E log V)',
    create: boruvkaMst,
  ),
  _entry(
    id: 'edmonds-karp',
    name: 'Edmonds–Karp Maximum Flow',
    blurb: 'BFS residual paths can revise earlier flow choices.',
    description:
        'Edmonds–Karp repeatedly finds a shortest residual augmenting path with BFS and pushes its bottleneck capacity. The residual graph and flow table show forward capacity and reverse cancellation. This example must cancel part of its first path to reach the maximum flow; the final reachable set defines a minimum cut.',
    time: 'O(V E²)',
    space: 'O(V² + E)',
    create: edmondsKarp,
  ),
  _entry(
    id: 'warshall-closure',
    name: 'Warshall Transitive Closure',
    blurb: 'Turn direct edges into every reachable ordered pair.',
    description:
        'Warshall applies the boolean recurrence reachable[i,j] |= reachable[i,k] && reachable[k,j] for each intermediate vertex. The matrix starts with direct edges and a true diagonal, then gains reachability entries as inferred arrows appear in the graph.',
    time: 'O(V³)',
    space: 'O(V²)',
    create: warshallClosure,
  ),
  _entry(
    id: 'hamiltonian-cycle',
    name: 'Hamiltonian Cycle Backtracking',
    category: AlgoCategory.backtracking,
    blurb: 'Visit every vertex once and return to the start.',
    description:
        'Fix a start vertex, choose an unused neighbour, and undo that choice whenever the partial path gets stuck. A completed path succeeds only if its last vertex connects back to the start. The example deliberately explores dead ends before finding a cycle, showing how vertex constraints differ from an Euler trail’s edge constraint.',
    time: 'O(V!)',
    create: hamiltonianCycle,
  ),
];
