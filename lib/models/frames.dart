import 'package:flutter/foundation.dart';

/// A single snapshot of an array-based algorithm (sorting & searching).
@immutable
class ArrayFrame {
  const ArrayFrame({
    required this.values,
    this.comparing = const {},
    this.active = const {},
    this.done = const {},
    this.windowLo,
    this.windowHi,
    this.pivot,
    this.target,
    this.caption = '',
  });

  final List<int> values;
  final Set<int> comparing; // indices currently being compared
  final Set<int> active; // indices being swapped / the moving element
  final Set<int> done; // finalized indices
  final int? windowLo; // search window lower bound (inclusive)
  final int? windowHi; // search window upper bound (inclusive)
  final int? pivot; // pivot index (quick sort)
  final int? target; // search target value
  final String caption;
}

/// A node in a serialized binary-search-tree snapshot.
@immutable
class BstNode {
  const BstNode({required this.id, required this.value, this.left, this.right});
  final int id;
  final int value;
  final int? left; // child node id
  final int? right; // child node id
}

/// A snapshot of a BST during insertion or traversal.
@immutable
class TreeFrame {
  const TreeFrame({
    required this.nodes,
    this.rootId,
    this.highlight = const {},
    this.output = const [],
    this.caption = '',
  });

  final List<BstNode> nodes;
  final int? rootId;
  final Set<int> highlight; // highlighted node ids
  final List<int> output; // emitted traversal values so far
  final String caption;
}

/// A snapshot of an A* search over a grid.
@immutable
class GridFrame {
  const GridFrame({
    this.open = const {},
    this.closed = const {},
    this.path = const [],
    this.current,
    this.caption = '',
  });

  final Set<int> open; // frontier cell indices
  final Set<int> closed; // visited cell indices
  final List<int> path; // reconstructed path (cell indices)
  final int? current; // cell being expanded
  final String caption;
}

/// Fixed configuration plus the animated frames for a grid search.
@immutable
class GridRun {
  const GridRun({
    required this.rows,
    required this.cols,
    required this.start,
    required this.goal,
    required this.walls,
    required this.frames,
  });

  final int rows;
  final int cols;
  final int start; // cell index
  final int goal; // cell index
  final Set<int> walls; // wall cell indices
  final List<GridFrame> frames;
}

/// A snapshot of the N-Queens backtracking search.
@immutable
class BoardFrame {
  const BoardFrame({
    required this.n,
    required this.queens,
    this.tryRow,
    this.tryCol,
    this.conflict = false,
    this.solved = false,
    this.caption = '',
  });

  final int n;
  final List<int> queens; // queens[row] = col, or -1 if none placed yet
  final int? tryRow;
  final int? tryCol;
  final bool conflict;
  final bool solved;
  final String caption;
}

/// A snapshot of the Tower of Hanoi.
@immutable
class HanoiFrame {
  const HanoiFrame({
    required this.pegs,
    this.movingDisk,
    this.fromPeg,
    this.toPeg,
    this.caption = '',
  });

  final List<List<int>> pegs; // pegs[i] = disks bottom..top (disk size ints)
  final int? movingDisk;
  final int? fromPeg;
  final int? toPeg;
  final String caption;
}

/// A snapshot of the Knight's Tour (Warnsdorff) search.
@immutable
class KnightFrame {
  const KnightFrame({
    required this.n,
    required this.board, // board[cell] = visit order (1-based), 0 if unvisited
    this.current,
    this.tryCell, // candidate square being considered
    this.backtrack = false,
    this.solved = false,
    this.caption = '',
  });

  final int n;
  final List<int> board;
  final int? current;
  final int? tryCell;
  final bool backtrack;
  final bool solved;
  final String caption;
}

/// A snapshot of a dynamic-programming table being filled cell by cell.
@immutable
class TableFrame {
  const TableFrame({
    required this.rows,
    required this.cols,
    required this.cells,
    this.rowHeader = const [],
    this.colHeader = const [],
    this.activeR, // cell currently being computed
    this.activeC,
    this.refs = const {}, // referenced cell keys (r * cols + c)
    this.filled = const {}, // computed cell keys (r * cols + c)
    this.caption = '',
  });

  final int rows;
  final int cols;
  final List<List<int>> cells;
  final List<String> rowHeader;
  final List<String> colHeader;
  final int? activeR;
  final int? activeC;
  final Set<int> refs;
  final Set<int> filled;
  final String caption;
}

/// A snapshot of the Sieve of Eratosthenes over numbers 1..[maxN].
@immutable
class NumberGridFrame {
  const NumberGridFrame({
    required this.maxN,
    this.current, // number currently highlighted
    this.multiplesOf, // prime whose multiples are being struck out
    this.marked = const {}, // composite numbers
    this.primes = const {}, // confirmed primes
    this.caption = '',
  });

  final int maxN;
  final int? current;
  final int? multiplesOf;
  final Set<int> marked;
  final Set<int> primes;
  final String caption;
}

/// A snapshot of Pascal's triangle being built row by row.
@immutable
class PascalFrame {
  const PascalFrame({
    required this.rows, // rows[r][c], -1 for not-yet-computed cells
    this.highlightRow,
    this.highlightCol,
    this.addends = const [], // up to two [r, c] cells feeding the current cell
    this.caption = '',
  });

  final List<List<int>> rows;
  final int? highlightRow;
  final int? highlightCol;
  final List<List<int>> addends;
  final String caption;
}

/// A weighted, undirected edge in a graph.
@immutable
class GraphEdge {
  const GraphEdge(this.a, this.b, this.w);
  final int a;
  final int b;
  final int w;

  /// Order-independent identifier so an edge matches regardless of endpoint order.
  int get key => a < b ? a * 100 + b : b * 100 + a;
}

/// A snapshot of a graph algorithm (e.g. Prim's MST).
@immutable
class GraphFrame {
  const GraphFrame({
    this.inTree = const {}, // node ids included / processed so far
    this.treeEdges = const {}, // chosen edge keys
    this.candidate, // edge key currently being considered
    this.current, // node just added / removed
    this.order = const [], // emitted node order (e.g. topological sort)
    this.colors = const {}, // node id -> colour index (graph colouring)
    this.dist = const {}, // node id -> shortest distance (Bellman–Ford)
    this.caption = '',
  });

  final Set<int> inTree;
  final Set<int> treeEdges;
  final int? candidate;
  final int? current;
  final List<int> order;
  final Map<int, int> colors;
  final Map<int, int> dist;
  final String caption;
}

/// Fixed graph layout plus the animated frames for a graph algorithm.
@immutable
class GraphRun {
  const GraphRun({
    required this.nodeLabels,
    required this.positions, // [x, y] each normalized to 0..1
    required this.edges,
    required this.frames,
    this.directed = false,
  });

  final List<String> nodeLabels;
  final List<List<double>> positions;
  final List<GraphEdge> edges;
  final List<GraphFrame> frames;
  final bool directed;
}

/// A snapshot of a matrix operation (A op B = C) being computed cell by cell.
@immutable
class MatrixFrame {
  const MatrixFrame({
    required this.a,
    required this.b,
    required this.c,
    required this.op, // '×' or '+'
    this.aRows = const {},
    this.aCols = const {},
    this.bRows = const {},
    this.bCols = const {},
    this.activeR, // result cell being computed
    this.activeC,
    this.filled = const {}, // result cell keys computed (r * cCols + c)
    this.caption = '',
  });

  final List<List<int>> a;
  final List<List<int>> b;
  final List<List<int>> c;
  final String op;
  final Set<int> aRows;
  final Set<int> aCols;
  final Set<int> bRows;
  final Set<int> bCols;
  final int? activeR;
  final int? activeC;
  final Set<int> filled;
  final String caption;
}

/// A snapshot of a string-matching algorithm aligning a pattern against text.
@immutable
class StringMatchFrame {
  const StringMatchFrame({
    required this.text,
    required this.pattern,
    required this.offset, // index in text where pattern[0] currently aligns
    this.compareIndex, // index within the pattern being compared
    this.matched = const {}, // pattern indices matched at this offset
    this.mismatch, // pattern index that mismatched
    this.found = const {}, // text indices of a confirmed match
    this.caption = '',
  });

  final String text;
  final String pattern;
  final int offset;
  final int? compareIndex;
  final Set<int> matched;
  final int? mismatch;
  final Set<int> found;
  final String caption;
}

/// A snapshot of a hash table using open addressing (linear probing).
@immutable
class HashFrame {
  const HashFrame({
    required this.size,
    required this.slots, // slot values, -1 for empty
    this.probe, // slot index currently being probed
    this.inserting, // key being inserted
    this.placed, // slot where the key was just placed
    this.caption = '',
  });

  final int size;
  final List<int> slots;
  final int? probe;
  final int? inserting;
  final int? placed;
  final String caption;
}

/// A snapshot of a linear container (stack or queue) during an operation.
@immutable
class SequenceFrame {
  const SequenceFrame({
    required this.values,
    required this.vertical, // true = stack (grows up), false = queue (row)
    this.highlight, // index just pushed/popped
    this.removed = false, // whether the highlight marks an outgoing element
    this.caption = '',
  });

  final List<int> values;
  final bool vertical;
  final int? highlight;
  final bool removed;
  final String caption;
}

/// A snapshot of a genetic algorithm evolving a population toward a target.
@immutable
class GeneticFrame {
  const GeneticFrame({
    required this.target,
    required this.population, // candidate strings
    required this.fitness, // matching characters per candidate
    required this.best, // index of the fittest candidate
    required this.generation,
    this.caption = '',
  });

  final String target;
  final List<String> population;
  final List<int> fitness;
  final int best;
  final int generation;
  final String caption;
}

/// Visual state of a general-tree node.
enum GNodeState { normal, highlight, active, good, red, black, pruned }

/// A node in a general (multiway / coloured) tree snapshot. The [label] is a
/// free-form string so it can hold B-tree key lists, red-black colours, or
/// minimax scores; [edgeLabel] annotates the edge from its parent.
@immutable
class GTreeNode {
  const GTreeNode({
    required this.id,
    required this.label,
    required this.children,
    this.state = GNodeState.normal,
    this.edgeLabel,
  });

  final int id;
  final String label;
  final List<int> children;
  final GNodeState state;
  final String? edgeLabel;
}

/// A snapshot of a general tree (B-tree, red-black, heaps, game trees).
@immutable
class GTreeFrame {
  const GTreeFrame({required this.nodes, this.rootId = 0, this.caption = ''});
  final List<GTreeNode> nodes;
  final int rootId;
  final String caption;
}

/// A snapshot of a separate-chaining hash table: each bucket holds a chain.
@immutable
class ChainHashFrame {
  const ChainHashFrame({
    required this.buckets,
    this.activeBucket,
    this.inserting,
    this.placed = false,
    this.caption = '',
  });

  final List<List<int>> buckets; // bucket index -> chained keys
  final int? activeBucket;
  final int? inserting;
  final bool placed;
  final String caption;
}

/// A snapshot of a character/string operation: a row of characters with
/// per-index highlight states.
@immutable
class TextFrame {
  const TextFrame({
    required this.text,
    this.examining = const {}, // amber — currently inspected
    this.matched = const {}, // green — kept / a positive result
    this.rejected = const {}, // terracotta — mismatch / removed
    this.caption = '',
  });

  final String text;
  final Set<int> examining;
  final Set<int> matched;
  final Set<int> rejected;
  final String caption;
}

/// A node in a linked-list snapshot.
@immutable
class LinkedNode {
  const LinkedNode({required this.value, this.highlight = false, this.fading = false});
  final int value;
  final bool highlight; // the node just touched
  final bool fading; // a node being removed
}

/// A snapshot of a linked list (singly, doubly, or circular).
@immutable
class LinkedFrame {
  const LinkedFrame({
    required this.nodes,
    this.doubly = false,
    this.circular = false,
    this.caption = '',
  });

  final List<LinkedNode> nodes;
  final bool doubly;
  final bool circular;
  final String caption;
}

/// A node in a trie (prefix tree) snapshot.
@immutable
class TrieNode {
  const TrieNode({
    required this.id,
    required this.label, // the single character on the edge into this node ('' for root)
    required this.children,
    this.isWord = false,
  });

  final int id;
  final String label;
  final List<int> children; // child node ids
  final bool isWord;
}

/// A snapshot of a trie during insertion or lookup.
@immutable
class TrieFrame {
  const TrieFrame({
    required this.nodes,
    this.rootId = 0,
    this.highlight = const {},
    this.caption = '',
  });

  final List<TrieNode> nodes;
  final int rootId;
  final Set<int> highlight; // node ids on the active path
  final String caption;
}

/// A snapshot of a tour-based optimiser (Ant Colony, Simulated Annealing) over
/// a fixed set of cities.
@immutable
class TspFrame {
  const TspFrame({
    required this.cities, // [x, y] each normalized to 0..1
    this.pheromone = const [], // optional n×n edge strengths (Ant Colony)
    this.tour = const [], // current / best tour as city indices
    this.bestLength,
    this.caption = '',
  });

  final List<List<double>> cities;
  final List<List<double>> pheromone;
  final List<int> tour;
  final double? bestLength;
  final String caption;
}

/// A snapshot of a swarm / local-search optimiser (Particle Swarm, Hill
/// Climbing) over a 2-D fitness landscape with a single peak.
@immutable
class SwarmFrame {
  const SwarmFrame({
    required this.particles, // [x, y] positions, normalized
    required this.target, // [x, y] location of the optimum (the peak)
    this.bestPos, // best position found so far
    this.caption = '',
  });

  final List<List<double>> particles;
  final List<double> target;
  final List<double>? bestPos;
  final String caption;
}

/// A snapshot of a convex-hull construction over a fixed set of points.
@immutable
class HullFrame {
  const HullFrame({
    required this.points, // [x, y] each normalized to 0..1
    required this.hull, // indices currently on the hull (in order)
    this.current, // point being considered
    this.closed = false, // whether the hull polygon is complete
    this.caption = '',
  });

  final List<List<double>> points;
  final List<int> hull;
  final int? current;
  final bool closed;
  final String caption;
}
