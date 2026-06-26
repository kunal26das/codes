import '../models/frames.dart';

const _knightMoves = [
  [2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-1, -2], [1, -2], [2, -1],
];

/// Knight's Tour using Warnsdorff's rule: from the current square, always move
/// to the reachable, unvisited square that has the fewest onward moves. This
/// finds an open tour quickly with little or no backtracking.
List<KnightFrame> knightsTour({int n = 5}) {
  final frames = <KnightFrame>[];
  final board = List<int>.filled(n * n, 0);

  int idx(int r, int c) => r * n + c;
  bool inBounds(int r, int c) => r >= 0 && r < n && c >= 0 && c < n;

  List<int> onwardCells(int cell) {
    final r = cell ~/ n, c = cell % n;
    final result = <int>[];
    for (final m in _knightMoves) {
      final nr = r + m[0], nc = c + m[1];
      if (inBounds(nr, nc) && board[idx(nr, nc)] == 0) result.add(idx(nr, nc));
    }
    return result;
  }

  var current = idx(0, 0);
  board[current] = 1;
  frames.add(KnightFrame(
    n: n,
    board: [...board],
    current: current,
    caption: 'Start the knight at the top-left corner.',
  ));

  for (var step = 2; step <= n * n; step++) {
    final candidates = onwardCells(current);
    if (candidates.isEmpty) {
      frames.add(KnightFrame(
        n: n,
        board: [...board],
        current: current,
        backtrack: true,
        caption: 'No onward move from here — tour incomplete.',
      ));
      return frames;
    }
    var best = candidates.first;
    var bestDegree = 1 << 30;
    for (final cand in candidates) {
      final degree = onwardCells(cand).length;
      if (degree < bestDegree) {
        bestDegree = degree;
        best = cand;
      }
    }
    frames.add(KnightFrame(
      n: n,
      board: [...board],
      current: current,
      tryCell: best,
      caption: 'Pick the square with the fewest onward moves (Warnsdorff’s rule).',
    ));
    current = best;
    board[current] = step;
    frames.add(KnightFrame(
      n: n,
      board: [...board],
      current: current,
      caption: 'Land move #$step.',
    ));
  }

  frames.add(KnightFrame(
    n: n,
    board: [...board],
    current: current,
    solved: true,
    caption: 'Every one of the ${n * n} squares visited exactly once — tour complete.',
  ));
  return frames;
}

/// N-Queens via backtracking. Emits a [BoardFrame] for each trial, placement,
/// and backtrack. Stops at the first complete solution.
List<BoardFrame> nQueens(int n) {
  final frames = <BoardFrame>[];
  final queens = List<int>.filled(n, -1);
  var solved = false;

  bool safe(int row, int col) {
    for (var r = 0; r < row; r++) {
      final c = queens[r];
      if (c == col) return false;
      if ((r - row).abs() == (c - col).abs()) return false;
    }
    return true;
  }

  bool place(int row) {
    if (row == n) {
      solved = true;
      frames.add(BoardFrame(n: n, queens: [...queens], solved: true, caption: 'All $n queens placed — solution found.'));
      return true;
    }
    for (var col = 0; col < n; col++) {
      final ok = safe(row, col);
      frames.add(BoardFrame(
        n: n,
        queens: [...queens],
        tryRow: row,
        tryCol: col,
        conflict: !ok,
        caption: ok
            ? 'Try a queen at row ${row + 1}, column ${col + 1}.'
            : 'Row ${row + 1}, column ${col + 1} is attacked — skip.',
      ));
      if (ok) {
        queens[row] = col;
        frames.add(BoardFrame(n: n, queens: [...queens], caption: 'Place a queen and move to the next row.'));
        if (place(row + 1)) return true;
        queens[row] = -1;
        frames.add(BoardFrame(
          n: n,
          queens: [...queens],
          tryRow: row,
          tryCol: col,
          conflict: true,
          caption: 'Dead end below — remove the queen and backtrack.',
        ));
      }
    }
    return false;
  }

  frames.add(BoardFrame(n: n, queens: [...queens], caption: 'Place $n queens so that none attack another.'));
  place(0);
  if (!solved) {
    frames.add(BoardFrame(n: n, queens: [...queens], caption: 'No solution for n = $n.'));
  }
  return frames;
}

const _pegNames = ['A', 'B', 'C'];

/// Tower of Hanoi for [disks] disks moved from peg A to peg C.
List<HanoiFrame> hanoi(int disks) {
  final pegs = <List<int>>[
    [for (var d = disks; d >= 1; d--) d],
    <int>[],
    <int>[],
  ];
  final frames = <HanoiFrame>[];

  List<List<int>> copy() => [for (final p in pegs) [...p]];

  frames.add(HanoiFrame(pegs: copy(), caption: 'Move all $disks disks from peg A to peg C.'));

  void move(int n, int from, int to, int via) {
    if (n == 0) return;
    move(n - 1, from, via, to);
    final disk = pegs[from].removeLast();
    pegs[to].add(disk);
    frames.add(HanoiFrame(
      pegs: copy(),
      movingDisk: disk,
      fromPeg: from,
      toPeg: to,
      caption: 'Move disk $disk from peg ${_pegNames[from]} to peg ${_pegNames[to]}.',
    ));
    move(n - 1, via, to, from);
  }

  move(disks, 0, 2, 1);
  frames.add(HanoiFrame(pegs: copy(), caption: 'Solved in ${(1 << disks) - 1} moves.'));
  return frames;
}
