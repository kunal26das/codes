import 'frames.dart';

/// A graph snapshot together with the worklist and bookkeeping that explain it.
class GraphTraceFrame {
  GraphTraceFrame({
    required this.graph,
    this.frontierLabel = '',
    List<String> frontier = const [],
    List<String> columns = const [],
    List<List<String>> rows = const [],
    this.graphTitle = '',
    List<GraphEdge>? edges,
  }) : frontier = List.unmodifiable(frontier),
       columns = List.unmodifiable(columns),
       rows = List.unmodifiable(
         rows.map((row) => List<String>.unmodifiable(row)),
       ),
       edges = edges == null ? null : List.unmodifiable(edges);

  final GraphFrame graph;
  final String frontierLabel;
  final List<String> frontier;
  final List<String> columns;
  final List<List<String>> rows;
  final String graphTitle;
  final List<GraphEdge>? edges;
}

/// Computed results accompany the animation so its outcome can be checked
/// independently of captions and rendering.
class GraphTraceRun {
  GraphTraceRun({
    required this.graph,
    required List<GraphTraceFrame> frames,
    List<int> order = const [],
    List<int> distances = const [],
    List<List<int>> components = const [],
    Set<int> resultEdges = const {},
    Set<int> resultVertices = const {},
    List<int> path = const [],
    List<List<int>> matrix = const [],
    List<List<int>> flow = const [],
    this.total,
    this.success,
  }) : frames = List.unmodifiable(frames),
       order = List.unmodifiable(order),
       distances = List.unmodifiable(distances),
       components = List.unmodifiable(
         components.map((row) => List<int>.unmodifiable(row)),
       ),
       resultEdges = Set.unmodifiable(resultEdges),
       resultVertices = Set.unmodifiable(resultVertices),
       path = List.unmodifiable(path),
       matrix = List.unmodifiable(
         matrix.map((row) => List<int>.unmodifiable(row)),
       ),
       flow = List.unmodifiable(flow.map((row) => List<int>.unmodifiable(row)));

  final GraphRun graph;
  final List<GraphTraceFrame> frames;
  final List<int> order;
  final List<int> distances;
  final List<List<int>> components;
  final Set<int> resultEdges;
  final Set<int> resultVertices;
  final List<int> path;
  final List<List<int>> matrix;
  final List<List<int>> flow;
  final int? total;
  final bool? success;
}
