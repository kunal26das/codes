import 'dart:math';

import '../models/frames.dart';

/// A fixed, always-solvable 4-connected grid used by the grid-search demos.
class _Grid {
  _Grid(this.rows, this.cols, this.start, this.goal, this.walls);

  final int rows;
  final int cols;
  final int start;
  final int goal;
  final Set<int> walls;

  int rowOf(int i) => i ~/ cols;
  int colOf(int i) => i % cols;

  List<int> neighbors(int i) {
    final r = rowOf(i), c = colOf(i);
    final result = <int>[];
    if (r > 0) result.add((r - 1) * cols + c);
    if (r < rows - 1) result.add((r + 1) * cols + c);
    if (c > 0) result.add(r * cols + (c - 1));
    if (c < cols - 1) result.add(r * cols + (c + 1));
    return result;
  }
}

/// Builds a random grid with ~26% wall density, then carves the top row and
/// the rightmost column so a path from the top-left to the bottom-right always
/// exists.
_Grid _makeGrid(int? seed) {
  const rows = 11;
  const cols = 16;
  final rng = Random(seed);
  final start = 0;
  final goal = (rows - 1) * cols + (cols - 1);

  int idx(int r, int c) => r * cols + c;

  final walls = <int>{};
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (rng.nextDouble() < 0.26) walls.add(idx(r, c));
    }
  }
  for (var c = 0; c < cols; c++) {
    walls.remove(idx(0, c));
  }
  for (var r = 0; r < rows; r++) {
    walls.remove(idx(r, cols - 1));
  }
  walls
    ..remove(start)
    ..remove(goal);
  return _Grid(rows, cols, start, goal, walls);
}

GridRun _runOf(_Grid g, List<GridFrame> frames) => GridRun(
      rows: g.rows,
      cols: g.cols,
      start: g.start,
      goal: g.goal,
      walls: g.walls,
      frames: frames,
    );

List<int> _reconstruct(Map<int, int> cameFrom, int node) {
  final path = <int>[node];
  var cur = node;
  while (cameFrom.containsKey(cur)) {
    cur = cameFrom[cur]!;
    path.add(cur);
  }
  return path.reversed.toList();
}

/// Adds the path-tracing frames shared by every grid search on success.
void _tracePath(List<GridFrame> frames, Set<int> open, Set<int> closed, List<int> path) {
  for (var k = 1; k <= path.length; k++) {
    frames.add(GridFrame(
      open: {...open},
      closed: {...closed},
      path: path.sublist(0, k),
      caption: k == path.length
          ? 'Shortest path found (${path.length - 1} steps).'
          : 'Tracing the path back…',
    ));
  }
}

/// Runs A* (Manhattan heuristic, 4-connected) on a randomly generated but
/// always-solvable grid, returning the fixed grid plus animated frames.
GridRun astarDemo({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final open = <int>{g.start};
  final closed = <int>{};
  final gScore = <int, int>{g.start: 0};
  final cameFrom = <int, int>{};

  int h(int i) =>
      (g.rowOf(i) - g.rowOf(g.goal)).abs() + (g.colOf(i) - g.colOf(g.goal)).abs();
  int f(int i) => (gScore[i] ?? 1 << 30) + h(i);

  frames.add(GridFrame(open: {...open}, caption: 'Start A* from the green cell.'));

  while (open.isNotEmpty) {
    var current = open.first;
    for (final node in open) {
      if (f(node) < f(current)) current = node;
    }

    if (current == g.goal) {
      _tracePath(frames, open, closed, _reconstruct(cameFrom, current));
      return _runOf(g, frames);
    }

    open.remove(current);
    closed.add(current);
    frames.add(GridFrame(
      open: {...open},
      closed: {...closed},
      current: current,
      caption: 'Expand the frontier cell with the lowest f = g + h.',
    ));

    for (final nb in g.neighbors(current)) {
      if (g.walls.contains(nb) || closed.contains(nb)) continue;
      final tentative = (gScore[current] ?? 1 << 30) + 1;
      if (tentative < (gScore[nb] ?? 1 << 30)) {
        cameFrom[nb] = current;
        gScore[nb] = tentative;
        open.add(nb);
      }
    }
  }

  frames.add(const GridFrame(caption: 'No path exists.'));
  return _runOf(g, frames);
}

/// Breadth-first search — explores in expanding rings using a FIFO queue, so it
/// always finds a shortest path on an unweighted grid.
GridRun bfsDemo({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final queue = <int>[g.start];
  final visited = <int>{g.start};
  final cameFrom = <int, int>{};
  final open = <int>{g.start};
  final closed = <int>{};

  frames.add(GridFrame(open: {...open}, caption: 'Breadth-first search from the green cell.'));

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    open.remove(current);
    closed.add(current);

    if (current == g.goal) {
      _tracePath(frames, open, closed, _reconstruct(cameFrom, current));
      return _runOf(g, frames);
    }

    frames.add(GridFrame(
      open: {...open},
      closed: {...closed},
      current: current,
      caption: 'Dequeue this cell and visit its unseen neighbours.',
    ));

    for (final nb in g.neighbors(current)) {
      if (g.walls.contains(nb) || visited.contains(nb)) continue;
      visited.add(nb);
      cameFrom[nb] = current;
      queue.add(nb);
      open.add(nb);
    }
  }

  frames.add(const GridFrame(caption: 'No path exists.'));
  return _runOf(g, frames);
}

/// Depth-first search — dives as deep as possible using a stack before
/// backtracking. Finds *a* path, not necessarily the shortest.
GridRun dfsDemo({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final stack = <int>[g.start];
  final visited = <int>{};
  final cameFrom = <int, int>{};
  final open = <int>{g.start};
  final closed = <int>{};

  frames.add(GridFrame(open: {...open}, caption: 'Depth-first search from the green cell.'));

  while (stack.isNotEmpty) {
    final current = stack.removeLast();
    if (visited.contains(current)) continue;
    visited.add(current);
    open.remove(current);
    closed.add(current);

    if (current == g.goal) {
      _tracePath(frames, open, closed, _reconstruct(cameFrom, current));
      return _runOf(g, frames);
    }

    frames.add(GridFrame(
      open: {...open},
      closed: {...closed},
      current: current,
      caption: 'Pop the deepest cell and push its unseen neighbours.',
    ));

    for (final nb in g.neighbors(current)) {
      if (g.walls.contains(nb) || visited.contains(nb)) continue;
      cameFrom.putIfAbsent(nb, () => current);
      stack.add(nb);
      open.add(nb);
    }
  }

  frames.add(const GridFrame(caption: 'No path exists.'));
  return _runOf(g, frames);
}

/// Dijkstra's algorithm — always settles the nearest unvisited cell. On a grid
/// with uniform step cost it expands like BFS but generalises to weights.
GridRun dijkstraDemo({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final dist = <int, int>{g.start: 0};
  final open = <int>{g.start};
  final closed = <int>{};
  final cameFrom = <int, int>{};

  frames.add(GridFrame(
    open: {...open},
    caption: 'Dijkstra from the green cell (uniform step cost).',
  ));

  while (open.isNotEmpty) {
    var current = open.first;
    for (final node in open) {
      if ((dist[node] ?? 1 << 30) < (dist[current] ?? 1 << 30)) current = node;
    }
    open.remove(current);
    closed.add(current);

    if (current == g.goal) {
      _tracePath(frames, open, closed, _reconstruct(cameFrom, current));
      return _runOf(g, frames);
    }

    frames.add(GridFrame(
      open: {...open},
      closed: {...closed},
      current: current,
      caption: 'Settle the nearest unvisited cell and relax its neighbours.',
    ));

    for (final nb in g.neighbors(current)) {
      if (g.walls.contains(nb) || closed.contains(nb)) continue;
      final nd = (dist[current] ?? 1 << 30) + 1;
      if (nd < (dist[nb] ?? 1 << 30)) {
        dist[nb] = nd;
        cameFrom[nb] = current;
        open.add(nb);
      }
    }
  }

  frames.add(const GridFrame(caption: 'No path exists.'));
  return _runOf(g, frames);
}

/// Rat in a Maze — depth-first backtracking that grows a single path and
/// retreats from dead ends until it reaches the exit.
GridRun ratInMaze({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final onPath = <int>[];
  final dead = <int>{};
  final visited = <int>{};
  var found = false;
  var solution = <int>[];

  void snap(String caption, {int? current}) {
    frames.add(GridFrame(
      open: {...onPath},
      closed: {...dead},
      current: current,
      caption: caption,
    ));
  }

  bool solve(int cell) {
    visited.add(cell);
    onPath.add(cell);
    if (cell == g.goal) {
      found = true;
      solution = [...onPath];
      return true;
    }
    snap('Step into a free cell and look for a way forward.', current: cell);
    for (final nb in g.neighbors(cell)) {
      if (g.walls.contains(nb) || visited.contains(nb)) continue;
      if (solve(nb)) return true;
    }
    onPath.removeLast();
    dead.add(cell);
    snap('Dead end — retreat and try another direction.',
        current: onPath.isEmpty ? null : onPath.last);
    return false;
  }

  frames.add(GridFrame(open: {g.start}, caption: 'Find a path from start (green) to exit (red).'));
  solve(g.start);
  if (found) {
    frames.add(GridFrame(
      closed: {...dead},
      path: solution,
      caption: 'Reached the exit in ${solution.length - 1} steps.',
    ));
  } else {
    frames.add(GridFrame(closed: {...dead}, caption: 'No path to the exit.'));
  }
  return _runOf(g, frames);
}

/// Greedy best-first search — always expands the open cell with the smallest
/// heuristic (Manhattan distance to the goal). Fast, but not always shortest.
GridRun greedyBestFirstDemo({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final open = <int>{g.start};
  final closed = <int>{};
  final cameFrom = <int, int>{};
  int h(int i) => (g.rowOf(i) - g.rowOf(g.goal)).abs() + (g.colOf(i) - g.colOf(g.goal)).abs();

  frames.add(GridFrame(open: {...open}, caption: 'Greedy best-first: expand whichever frontier cell looks closest to the goal.'));
  while (open.isNotEmpty) {
    var current = open.first;
    for (final node in open) {
      if (h(node) < h(current)) current = node;
    }
    open.remove(current);
    closed.add(current);
    if (current == g.goal) {
      _tracePath(frames, open, closed, _reconstruct(cameFrom, current));
      return _runOf(g, frames);
    }
    frames.add(GridFrame(open: {...open}, closed: {...closed}, current: current, caption: 'Expand the cell with the smallest heuristic h.'));
    for (final nb in g.neighbors(current)) {
      if (g.walls.contains(nb) || closed.contains(nb) || open.contains(nb)) continue;
      cameFrom[nb] = current;
      open.add(nb);
    }
  }
  frames.add(const GridFrame(caption: 'No path exists.'));
  return _runOf(g, frames);
}

/// Flood fill — spreads from a seed cell to every connected open cell, as in a
/// paint-bucket tool.
GridRun floodFillDemo({int? seed}) {
  final g = _makeGrid(seed);
  final frames = <GridFrame>[];
  final queue = <int>[g.start];
  final filled = <int>{g.start};
  final open = <int>{g.start};
  frames.add(GridFrame(open: {...open}, caption: 'Flood fill spreads from the seed to all connected open cells.'));
  while (queue.isNotEmpty) {
    final cur = queue.removeAt(0);
    open.remove(cur);
    frames.add(GridFrame(open: {...open}, closed: {...filled}, current: cur, caption: 'Fill this cell, then spread to its open neighbours.'));
    for (final nb in g.neighbors(cur)) {
      if (g.walls.contains(nb) || filled.contains(nb)) continue;
      filled.add(nb);
      queue.add(nb);
      open.add(nb);
    }
  }
  frames.add(GridFrame(closed: {...filled}, caption: 'Region filled — ${filled.length} cells reached.'));
  return GridRun(rows: g.rows, cols: g.cols, start: g.start, goal: g.start, walls: g.walls, frames: frames);
}
