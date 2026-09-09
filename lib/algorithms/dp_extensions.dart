import 'dart:math';

import '../models/frames.dart';

// Shared snapshot builder: recurrence values, completed cells, and dependency
// highlights are copied so scrubbing backward never shows a later state.
class _Table {
  _Table(int rows, int cols, {List<String>? rowHeader, List<String>? colHeader})
    : cells = List.generate(rows, (_) => List<int>.filled(cols, 0)),
      rowHeader = rowHeader ?? [for (var r = 0; r < rows; r++) '$r'],
      colHeader = colHeader ?? [for (var c = 0; c < cols; c++) '$c'];

  final List<List<int>> cells;
  final List<String> rowHeader;
  final List<String> colHeader;
  final filled = <int>{};
  final frames = <TableFrame>[];
  int get cols => cells.first.length;
  int key(int r, int c) => r * cols + c;

  void put(int r, int c, int value) {
    cells[r][c] = value;
    filled.add(key(r, c));
  }

  void snap(String caption, {int? r, int? c, Set<int> refs = const {}}) {
    frames.add(
      TableFrame(
        rows: cells.length,
        cols: cols,
        cells: [
          for (final row in cells) [...row],
        ],
        rowHeader: [...rowHeader],
        colHeader: [...colHeader],
        activeR: r,
        activeC: c,
        refs: {...refs},
        filled: {...filled},
        caption: caption,
      ),
    );
  }
}

void _nonnegative(int value, String name) {
  if (value < 0) throw RangeError.value(value, name, 'Must be non-negative.');
}

List<TableFrame> _emptyResult(String caption) {
  final t = _Table(1, 1);
  t.put(0, 0, 0);
  t.snap(caption, r: 0, c: 0);
  return t.frames;
}

/// Minimum scalar multiplications, with every possible split animated.
List<TableFrame> matrixChainMultiplication([
  List<int> dimensions = const [5, 3, 6, 2, 4],
]) {
  if (dimensions.length < 2 || dimensions.any((d) => d <= 0)) {
    throw ArgumentError('Provide at least two positive matrix dimensions.');
  }
  final n = dimensions.length - 1;
  final labels = [for (var i = 1; i <= n; i++) 'A$i'];
  final t = _Table(n, n, rowHeader: labels, colHeader: labels);
  final split = List.generate(n, (_) => List<int>.filled(n, 0));
  for (var i = 0; i < n; i++) {
    t.put(i, i, 0);
  }
  t.snap(
    'Matrix dimensions: ${dimensions.join(' → ')}. A single matrix needs no multiplication.',
  );
  for (var len = 2; len <= n; len++) {
    for (var i = 0; i + len <= n; i++) {
      final j = i + len - 1;
      int? best;
      for (var k = i; k < j; k++) {
        final product = dimensions[i] * dimensions[k + 1] * dimensions[j + 1];
        final candidate = t.cells[i][k] + t.cells[k + 1][j] + product;
        if (best == null || candidate < best) {
          best = candidate;
          split[i][j] = k;
        }
        t.put(i, j, best);
        t.snap(
          'Split after A${k + 1}: ${t.cells[i][k]} + ${t.cells[k + 1][j]} + $product = $candidate; best $best.',
          r: i,
          c: j,
          refs: {t.key(i, k), t.key(k + 1, j)},
        );
      }
    }
  }
  String order(int i, int j) => i == j
      ? 'A${i + 1}'
      : '(${order(i, split[i][j])} × ${order(split[i][j] + 1, j)})';
  t.snap(
    'Minimum ${t.cells[0][n - 1]} scalar multiplications: ${order(0, n - 1)}.',
    r: 0,
    c: n - 1,
  );
  return t.frames;
}

/// Interval DP: pair equal ends, otherwise discard one end.
List<TableFrame> longestPalindromicSubsequence([String text = 'BBABC']) {
  if (text.isEmpty) {
    return _emptyResult('Empty text has palindromic subsequence length 0.');
  }
  final n = text.length;
  final labels = [for (var i = 0; i < n; i++) '${text[i]}$i'];
  final t = _Table(n, n, rowHeader: labels, colHeader: labels);
  for (var i = 0; i < n; i++) {
    t.put(i, i, 1);
  }
  t.snap(
    'Each single character is a palindrome of length 1; grow the interval.',
  );
  for (var len = 2; len <= n; len++) {
    for (var i = 0; i + len <= n; i++) {
      final j = i + len - 1;
      final refs = <int>{};
      if (text[i] == text[j]) {
        final inner = len == 2 ? 0 : t.cells[i + 1][j - 1];
        if (len > 2) refs.add(t.key(i + 1, j - 1));
        t.put(i, j, inner + 2);
        t.snap(
          '${text[i]} = ${text[j]}: pair the ends, $inner + 2 = ${inner + 2}.',
          r: i,
          c: j,
          refs: refs,
        );
      } else {
        final a = t.cells[i + 1][j], b = t.cells[i][j - 1];
        t.put(i, j, max(a, b));
        t.snap(
          'Different ends: max(drop left $a, drop right $b) = ${max(a, b)}.',
          r: i,
          c: j,
          refs: {t.key(i + 1, j), t.key(i, j - 1)},
        );
      }
    }
  }
  var i = 0, j = n - 1;
  final front = <String>[], back = <String>[];
  final path = <int>{};
  while (i <= j) {
    path.add(t.key(i, j));
    if (i == j) {
      front.add(text[i]);
      break;
    }
    if (text[i] == text[j]) {
      front.add(text[i++]);
      back.add(text[j--]);
    } else if (t.cells[i + 1][j] >= t.cells[i][j - 1]) {
      i++;
    } else {
      j--;
    }
  }
  t.snap(
    'Longest palindromic subsequence: "${front.join()}${back.reversed.join()}" (length ${t.cells[0][n - 1]}).',
    r: 0,
    c: n - 1,
    refs: path,
  );
  return t.frames;
}

/// Matching suffix lengths reset to zero on a mismatch, enforcing contiguity.
List<TableFrame> longestCommonSubstring([
  String a = 'ABABC',
  String b = 'BABCA',
]) {
  final t = _Table(
    a.length + 1,
    b.length + 1,
    rowHeader: ['∅', ...a.split('')],
    colHeader: ['∅', ...b.split('')],
  );
  for (var r = 0; r <= a.length; r++) {
    t.put(r, 0, 0);
  }
  for (var c = 0; c <= b.length; c++) {
    t.put(0, c, 0);
  }
  t.snap(
    'Each cell counts a shared suffix ending at these characters; empty prefixes give 0.',
  );
  var best = 0, endA = 0, endB = 0;
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final match = a[i - 1] == b[j - 1];
      final value = match ? t.cells[i - 1][j - 1] + 1 : 0;
      t.put(i, j, value);
      if (value > best) {
        best = value;
        endA = i;
        endB = j;
      }
      t.snap(
        match
            ? '${a[i - 1]} matches: diagonal + 1 = $value.'
            : '${a[i - 1]} ≠ ${b[j - 1]}: reset the shared suffix to 0.',
        r: i,
        c: j,
        refs: match ? {t.key(i - 1, j - 1)} : {},
      );
    }
  }
  t.snap(
    'Longest common substring: "${a.substring(endA - best, endA)}" (length $best).',
    r: endA,
    c: endB,
    refs: {for (var k = 0; k < best; k++) t.key(endA - k, endB - k)},
  );
  return t.frames;
}

/// Minimum-length string containing both inputs as subsequences, plus traceback.
List<TableFrame> shortestCommonSupersequence([
  String a = 'ABAC',
  String b = 'CAB',
]) {
  final t = _Table(
    a.length + 1,
    b.length + 1,
    rowHeader: ['∅', ...a.split('')],
    colHeader: ['∅', ...b.split('')],
  );
  for (var i = 0; i <= a.length; i++) {
    t.put(i, 0, i);
  }
  for (var j = 0; j <= b.length; j++) {
    t.put(0, j, j);
  }
  t.snap(
    'An empty prefix contributes nothing; the other prefix must appear in full.',
  );
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final match = a[i - 1] == b[j - 1];
      final prior = match
          ? t.cells[i - 1][j - 1]
          : min(t.cells[i - 1][j], t.cells[i][j - 1]);
      t.put(i, j, prior + 1);
      t.snap(
        match
            ? 'Shared ${a[i - 1]} appears once: diagonal + 1 = ${prior + 1}.'
            : 'Append one end: 1 + min(up, left) = ${prior + 1}.',
        r: i,
        c: j,
        refs: match
            ? {t.key(i - 1, j - 1)}
            : {t.key(i - 1, j), t.key(i, j - 1)},
      );
    }
  }
  var i = a.length, j = b.length;
  final reversed = <String>[], path = <int>{};
  while (i > 0 || j > 0) {
    path.add(t.key(i, j));
    if (i == 0) {
      reversed.add(b[--j]);
    } else if (j == 0) {
      reversed.add(a[--i]);
    } else if (a[i - 1] == b[j - 1]) {
      reversed.add(a[--i]);
      j--;
    } else if (t.cells[i - 1][j] <= t.cells[i][j - 1]) {
      reversed.add(a[--i]);
    } else {
      reversed.add(b[--j]);
    }
  }
  t.snap(
    'Shortest common supersequence: "${reversed.reversed.join()}" (length ${t.cells[a.length][b.length]}).',
    r: a.length,
    c: b.length,
    refs: path,
  );
  return t.frames;
}

List<TableFrame> unboundedKnapsack({
  List<int> weights = const [2, 3, 4],
  List<int> values = const [4, 5, 7],
  int capacity = 7,
}) {
  _nonnegative(capacity, 'capacity');
  if (weights.length != values.length || weights.any((w) => w <= 0)) {
    throw ArgumentError('Each item needs one value and a positive weight.');
  }
  final n = weights.length;
  final t = _Table(
    n + 1,
    capacity + 1,
    rowHeader: [
      '∅',
      for (var i = 0; i < n; i++) 'w${weights[i]} v${values[i]}',
    ],
  );
  for (var c = 0; c <= capacity; c++) {
    t.put(0, c, 0);
  }
  t.snap('Unlimited copies of every item. Row 0 has no items and earns 0.');
  for (var i = 1; i <= n; i++) {
    for (var c = 0; c <= capacity; c++) {
      final skip = t.cells[i - 1][c];
      final refs = {t.key(i - 1, c)};
      var best = skip;
      var formula =
          'Weight ${weights[i - 1]} does not fit: copy $skip from above.';
      if (weights[i - 1] <= c) {
        final remainder = c - weights[i - 1];
        final take = values[i - 1] + t.cells[i][remainder];
        best = max(skip, take);
        refs.add(t.key(i, remainder));
        formula =
            'max(skip $skip, take ${values[i - 1]} + same-row ${t.cells[i][remainder]}) = $best; same row permits reuse.';
      }
      t.put(i, c, best);
      t.snap(formula, r: i, c: c, refs: refs);
    }
  }
  var i = n, c = capacity;
  final counts = List<int>.filled(n, 0);
  while (i > 0) {
    if (t.cells[i][c] == t.cells[i - 1][c]) {
      i--;
    } else {
      counts[i - 1]++;
      c -= weights[i - 1];
    }
  }
  t.snap(
    'Best value ${t.cells[n][capacity]}; copies per item: [${counts.join(', ')}].',
    r: n,
    c: capacity,
  );
  return t.frames;
}

/// Count unordered combinations; the current row allows repeated use of a coin.
List<TableFrame> coinChangeWays([
  List<int> coins = const [1, 2, 3],
  int amount = 6,
]) {
  _nonnegative(amount, 'amount');
  if (coins.any((c) => c <= 0) || coins.toSet().length != coins.length) {
    throw ArgumentError(
      'Coin denominations must be distinct positive integers.',
    );
  }
  final t = _Table(
    coins.length + 1,
    amount + 1,
    rowHeader: ['∅', for (final c in coins) '+$c'],
  );
  for (var s = 0; s <= amount; s++) {
    t.put(0, s, s == 0 ? 1 : 0);
  }
  t.snap(
    'One way makes 0: choose no coins. Process denominations once to avoid counting different orders.',
  );
  for (var i = 1; i <= coins.length; i++) {
    for (var s = 0; s <= amount; s++) {
      final skip = t.cells[i - 1][s];
      final use = s >= coins[i - 1] ? t.cells[i][s - coins[i - 1]] : 0;
      t.put(i, s, skip + use);
      t.snap(
        'Ways for $s: without ${coins[i - 1]} ($skip) + with it ($use) = ${skip + use}.',
        r: i,
        c: s,
        refs: {
          t.key(i - 1, s),
          if (s >= coins[i - 1]) t.key(i, s - coins[i - 1]),
        },
      );
    }
  }
  t.snap(
    '${t.cells[coins.length][amount]} combinations make $amount.',
    r: coins.length,
    c: amount,
  );
  return t.frames;
}

/// Count right/down routes, with blocked cells contributing zero routes.
List<TableFrame> uniqueGridPaths({
  int rows = 3,
  int cols = 4,
  Set<int> blocked = const {5},
}) {
  if (rows < 1 || cols < 1 || blocked.any((k) => k < 0 || k >= rows * cols)) {
    throw ArgumentError('Use a nonempty grid and valid blocked-cell indices.');
  }
  final t = _Table(rows, cols);
  t.snap(
    'Move only right or down. Blocked cells: ${blocked.map((k) => '(${k ~/ cols},${k % cols})').join(', ')}.',
  );
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (blocked.contains(t.key(r, c))) {
        t.put(r, c, 0);
        t.snap('Cell ($r,$c) is blocked: 0 routes.', r: r, c: c);
      } else if (r == 0 && c == 0) {
        t.put(r, c, 1);
        t.snap('Start: one empty route reaches (0,0).', r: r, c: c);
      } else {
        final up = r > 0 ? t.cells[r - 1][c] : 0;
        final left = c > 0 ? t.cells[r][c - 1] : 0;
        t.put(r, c, up + left);
        t.snap(
          'Routes into ($r,$c): from above $up + from left $left = ${up + left}.',
          r: r,
          c: c,
          refs: {if (r > 0) t.key(r - 1, c), if (c > 0) t.key(r, c - 1)},
        );
      }
    }
  }
  t.snap(
    '${t.cells.last.last} routes reach the bottom-right corner.',
    r: rows - 1,
    c: cols - 1,
  );
  return t.frames;
}

/// Lowest-cost right/down path; the final highlights reconstruct the route.
List<TableFrame> minimumGridPathSum([
  List<List<int>> costs = const [
    [1, 3, 1, 4],
    [2, 1, 5, 1],
    [4, 2, 1, 2],
  ],
]) {
  if (costs.isEmpty ||
      costs.first.isEmpty ||
      costs.any((row) => row.length != costs.first.length)) {
    throw ArgumentError('Costs must form a nonempty rectangular grid.');
  }
  final rows = costs.length, cols = costs.first.length;
  final t = _Table(rows, cols);
  final parent = <int, int>{};
  t.snap(
    'Each cell will show the cheapest total from the top-left. Cell costs: ${costs.map((r) => r.join(',')).join(' / ')}.',
  );
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      if (r == 0 && c == 0) {
        t.put(0, 0, costs[0][0]);
        t.snap('Start with cost ${costs[0][0]}.', r: 0, c: 0);
        continue;
      }
      final fromUp =
          r > 0 && (c == 0 || t.cells[r - 1][c] <= t.cells[r][c - 1]);
      final previous = fromUp ? t.cells[r - 1][c] : t.cells[r][c - 1];
      parent[t.key(r, c)] = fromUp ? t.key(r - 1, c) : t.key(r, c - 1);
      t.put(r, c, previous + costs[r][c]);
      t.snap(
        'Cost ${costs[r][c]} + best reachable neighbour $previous = ${t.cells[r][c]} (from ${fromUp ? 'above' : 'left'}).',
        r: r,
        c: c,
        refs: {if (r > 0) t.key(r - 1, c), if (c > 0) t.key(r, c - 1)},
      );
    }
  }
  final path = <int>{};
  var at = rows * cols - 1;
  while (true) {
    path.add(at);
    if (at == 0) break;
    at = parent[at]!;
  }
  t.snap(
    'Minimum path sum = ${t.cells.last.last}; highlighted cells form an optimal route.',
    r: rows - 1,
    c: cols - 1,
    refs: path,
  );
  return t.frames;
}

/// Maximum total from nonadjacent houses, allowing the empty selection.
List<TableFrame> houseRobber([List<int> values = const [2, 7, 9, 3, 1]]) {
  final n = values.length;
  final t = _Table(
    2,
    n + 1,
    rowHeader: ['value', 'best'],
    colHeader: ['∅', for (var i = 0; i < n; i++) 'H$i'],
  );
  t.put(0, 0, 0);
  t.put(1, 0, 0);
  for (var i = 0; i < n; i++) {
    t.put(0, i + 1, values[i]);
  }
  t.snap(
    'Choose houses without taking two neighbours. An empty prefix earns 0.',
  );
  for (var i = 1; i <= n; i++) {
    final before = max(0, i - 2);
    final skip = t.cells[1][i - 1], take = values[i - 1] + t.cells[1][before];
    t.put(1, i, max(skip, take));
    t.snap(
      'H${i - 1}: max(skip $skip, take ${values[i - 1]} + ${t.cells[1][before]}) = ${max(skip, take)}.',
      r: 1,
      c: i,
      refs: {t.key(0, i), t.key(1, i - 1), t.key(1, before)},
    );
  }
  final chosen = <int>[];
  var i = n;
  while (i > 0) {
    if (t.cells[1][i] > t.cells[1][i - 1]) {
      chosen.add(i - 1);
      i -= 2;
    } else {
      i--;
    }
  }
  t.snap(
    'Maximum ${t.cells[1][n]}; choose houses ${chosen.reversed.toList()}.',
    r: 1,
    c: n,
    refs: {for (final h in chosen) t.key(0, h + 1)},
  );
  return t.frames;
}

/// Minimax DP: try a drop floor and plan for the worse break/survive outcome.
List<TableFrame> eggDropping({int eggs = 2, int floors = 6}) {
  if (eggs < 1) {
    throw RangeError.value(eggs, 'eggs', 'At least one egg is required.');
  }
  _nonnegative(floors, 'floors');
  const infinity = 1 << 29;
  final t = _Table(
    eggs + 1,
    floors + 1,
    rowHeader: [for (var e = 0; e <= eggs; e++) '$e eggs'],
  );
  for (var f = 0; f <= floors; f++) {
    t.put(0, f, f == 0 ? 0 : infinity);
    t.put(1, f, f);
  }
  for (var e = 2; e <= eggs; e++) {
    t.put(e, 0, 0);
  }
  t.snap(
    '0 floors need 0 drops; one egg requires a linear scan. No eggs cannot resolve a positive number of floors.',
  );
  for (var e = 2; e <= eggs; e++) {
    for (var f = 1; f <= floors; f++) {
      var best = infinity;
      for (var drop = 1; drop <= f; drop++) {
        final broken = t.cells[e - 1][drop - 1],
            survived = t.cells[e][f - drop];
        final candidate = 1 + max<int>(broken, survived);
        best = min(best, candidate);
        t.put(e, f, best);
        t.snap(
          'Drop at $drop: 1 + max(break $broken, survive $survived) = $candidate; best worst-case $best.',
          r: e,
          c: f,
          refs: {t.key(e - 1, drop - 1), t.key(e, f - drop)},
        );
      }
    }
  }
  t.snap(
    '$eggs eggs and $floors floors need ${t.cells[eggs][floors]} drops in the worst case.',
    r: eggs,
    c: floors,
  );
  return t.frames;
}

/// Count true and false parenthesizations of an expression of T/F and &/|/^.
List<TableFrame> booleanParenthesization([String expression = 'T|F&T^T']) {
  final expr = expression.replaceAll(' ', '');
  if (!RegExp(r'^[TF](?:[&|^][TF])*$').hasMatch(expr)) {
    throw ArgumentError('Alternate T/F operands with &, |, or ^ operators.');
  }
  final n = (expr.length + 1) ~/ 2;
  final t = _Table(
    2 * n,
    n,
    rowHeader: [
      for (final kind in ['T', 'F'])
        for (var i = 0; i < n; i++) '$kind:$i',
    ],
    colHeader: [for (var i = 0; i < n; i++) '${expr[i * 2]}$i'],
  );
  for (var i = 0; i < n; i++) {
    t.put(i, i, expr[i * 2] == 'T' ? 1 : 0);
    t.put(n + i, i, expr[i * 2] == 'F' ? 1 : 0);
  }
  t.snap(
    '$expr: upper rows count true outcomes; lower rows count false outcomes for each interval.',
  );
  for (var len = 2; len <= n; len++) {
    for (var i = 0; i + len <= n; i++) {
      final j = i + len - 1;
      var trueWays = 0, falseWays = 0;
      for (var k = i; k < j; k++) {
        final lt = t.cells[i][k], lf = t.cells[n + i][k];
        final rt = t.cells[k + 1][j], rf = t.cells[n + k + 1][j];
        final total = (lt + lf) * (rt + rf);
        final op = expr[k * 2 + 1];
        final addTrue = op == '&'
            ? lt * rt
            : op == '|'
            ? total - lf * rf
            : lt * rf + lf * rt;
        trueWays += addTrue;
        falseWays += total - addTrue;
        final refs = {
          t.key(i, k),
          t.key(n + i, k),
          t.key(k + 1, j),
          t.key(n + k + 1, j),
        };
        t.put(i, j, trueWays);
        t.put(n + i, j, falseWays);
        t.snap(
          'Split at $op after operand $k: $addTrue true and ${total - addTrue} false combinations; true total $trueWays.',
          r: i,
          c: j,
          refs: refs,
        );
        t.snap(
          'The same split adds ${total - addTrue} false outcomes; false total $falseWays.',
          r: n + i,
          c: j,
          refs: refs,
        );
      }
    }
  }
  t.snap(
    '$expr has ${t.cells[0][n - 1]} true and ${t.cells[n][n - 1]} false parenthesizations.',
    r: 0,
    c: n - 1,
  );
  return t.frames;
}

typedef WeightedJob = ({int start, int end, int value});

/// Finish-time ordering + binary-search predecessors + a take/skip recurrence.
List<TableFrame> weightedIntervalScheduling([
  List<WeightedJob> jobs = const [
    (start: 1, end: 3, value: 5),
    (start: 2, end: 5, value: 6),
    (start: 4, end: 6, value: 5),
    (start: 6, end: 7, value: 4),
    (start: 5, end: 8, value: 11),
    (start: 7, end: 9, value: 2),
  ],
]) {
  if (jobs.any((j) => j.end <= j.start)) {
    throw ArgumentError('Each job must finish after it starts.');
  }
  final order = [for (var i = 0; i < jobs.length; i++) i]
    ..sort(
      (a, b) => jobs[a].end == jobs[b].end
          ? a.compareTo(b)
          : jobs[a].end.compareTo(jobs[b].end),
    );
  final n = jobs.length;
  final t = _Table(
    4,
    n + 1,
    rowHeader: ['start', 'end', 'value', 'best'],
    colHeader: ['∅', for (final i in order) 'J$i'],
  );
  final previous = List<int>.filled(n + 1, 0);
  for (var r = 0; r < 4; r++) {
    t.put(r, 0, 0);
  }
  for (var i = 1; i <= n; i++) {
    final job = jobs[order[i - 1]];
    t.put(0, i, job.start);
    t.put(1, i, job.end);
    t.put(2, i, job.value);
  }
  t.snap(
    'Sort jobs by finish time. Jobs that touch at an endpoint are compatible.',
  );
  for (var i = 1; i <= n; i++) {
    final job = jobs[order[i - 1]];
    var lo = 0, hi = i - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (jobs[order[mid - 1]].end <= job.start) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    previous[i] = lo;
    final take = job.value + t.cells[3][lo], skip = t.cells[3][i - 1];
    t.put(3, i, max(skip, take));
    t.snap(
      'J${order[i - 1]}: compatible prefix has $lo jobs. max(skip $skip, take ${job.value} + ${t.cells[3][lo]}) = ${max(skip, take)}.',
      r: 3,
      c: i,
      refs: {t.key(2, i), t.key(3, lo), t.key(3, i - 1)},
    );
  }
  final chosen = <int>[];
  var i = n;
  while (i > 0) {
    if (t.cells[3][i] > t.cells[3][i - 1]) {
      chosen.add(i);
      i = previous[i];
    } else {
      i--;
    }
  }
  t.snap(
    'Maximum value ${t.cells[3][n]}; choose ${chosen.reversed.map((i) => 'J${order[i - 1]}').join(', ')}.',
    r: 3,
    c: n,
    refs: {for (final i in chosen) t.key(2, i)},
  );
  return t.frames;
}

/// Catalan convolution counts balanced bracketings (among many interpretations).
List<TableFrame> catalanNumbers([int n = 7]) {
  _nonnegative(n, 'n');
  final t = _Table(1, n + 1, rowHeader: ['Catalan']);
  t.put(0, 0, 1);
  t.snap(
    'C₀ = 1: one empty structure. Split a structure into left and right parts.',
  );
  for (var k = 1; k <= n; k++) {
    var total = 0;
    for (var left = 0; left < k; left++) {
      final right = k - 1 - left;
      final product = t.cells[0][left] * t.cells[0][right];
      total += product;
      t.put(0, k, total);
      t.snap(
        'C$k: add C$left × C$right = $product; running total $total.',
        r: 0,
        c: k,
        refs: {t.key(0, left), t.key(0, right)},
      );
    }
  }
  t.snap(
    'C$n = ${t.cells[0][n]} balanced arrangements of $n pairs.',
    r: 0,
    c: n,
  );
  return t.frames;
}

/// Permutations with no fixed point: Dₙ = (n−1)(Dₙ₋₁ + Dₙ₋₂).
List<TableFrame> derangements([int n = 7]) {
  _nonnegative(n, 'n');
  final t = _Table(1, n + 1, rowHeader: ['D']);
  t.put(0, 0, 1);
  if (n >= 1) t.put(0, 1, 0);
  t.snap('D₀ = 1 and D₁ = 0. No object may stay in its original position.');
  for (var k = 2; k <= n; k++) {
    final a = t.cells[0][k - 1], b = t.cells[0][k - 2];
    t.put(0, k, (k - 1) * (a + b));
    t.snap(
      'D$k = (${k - 1}) × (D${k - 1} + D${k - 2}) = ${k - 1} × ($a + $b) = ${t.cells[0][k]}.',
      r: 0,
      c: k,
      refs: {t.key(0, k - 1), t.key(0, k - 2)},
    );
  }
  t.snap(
    '${t.cells[0][n]} permutations of $n objects have no fixed point.',
    r: 0,
    c: n,
  );
  return t.frames;
}

/// Count unordered sums of positive integers, limiting the largest allowed part.
List<TableFrame> integerPartitions([int n = 6]) {
  _nonnegative(n, 'n');
  final t = _Table(
    n + 1,
    n + 1,
    rowHeader: ['none', for (var k = 1; k <= n; k++) '≤$k'],
  );
  for (var s = 0; s <= n; s++) {
    t.put(0, s, s == 0 ? 1 : 0);
  }
  t.snap(
    'Partition a total into unordered positive parts. The empty partition makes 0 once.',
  );
  for (var k = 1; k <= n; k++) {
    for (var s = 0; s <= n; s++) {
      final without = t.cells[k - 1][s];
      final withPart = s >= k ? t.cells[k][s - k] : 0;
      t.put(k, s, without + withPart);
      t.snap(
        'Parts ≤$k, total $s: omit $k ($without) + include $k ($withPart) = ${without + withPart}.',
        r: k,
        c: s,
        refs: {t.key(k - 1, s), if (s >= k) t.key(k, s - k)},
      );
    }
  }
  t.snap('p($n) = ${t.cells[n][n]} unordered integer partitions.', r: n, c: n);
  return t.frames;
}

/// Solve a 4×4 Sudoku using row/column/2×2-block constraints and backtracking.
/// Zero denotes an empty cell; inconsistent clues are rejected before search.
List<TableFrame> sudoku4x4([
  List<List<int>> puzzle = const [
    [0, 0, 0, 0],
    [0, 0, 1, 0],
    [0, 1, 0, 4],
    [0, 4, 2, 1],
  ],
]) {
  if (puzzle.length != 4 ||
      puzzle.any((r) => r.length != 4 || r.any((v) => v < 0 || v > 4))) {
    throw ArgumentError('Sudoku needs a 4×4 grid with values 0 through 4.');
  }
  final t = _Table(4, 4);
  Set<int> peers(int r, int c) => {
    for (var k = 0; k < 4; k++)
      if (k != c) t.key(r, k),
    for (var k = 0; k < 4; k++)
      if (k != r) t.key(k, c),
    for (var br = r ~/ 2 * 2; br < r ~/ 2 * 2 + 2; br++)
      for (var bc = c ~/ 2 * 2; bc < c ~/ 2 * 2 + 2; bc++)
        if (br != r || bc != c) t.key(br, bc),
  };
  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < 4; c++) {
      if (puzzle[r][c] != 0) t.put(r, c, puzzle[r][c]);
    }
  }
  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < 4; c++) {
      if (t.cells[r][c] != 0 &&
          peers(r, c).any((k) => t.cells[k ~/ 4][k % 4] == t.cells[r][c])) {
        throw ArgumentError('The Sudoku clues conflict.');
      }
    }
  }
  t.snap(
    'Fill 1–4 so every row, column, and outlined 2×2 block contains each digit once.',
  );
  bool solve(int at) {
    while (at < 16 && t.cells[at ~/ 4][at % 4] != 0) {
      at++;
    }
    if (at == 16) return true;
    final r = at ~/ 4, c = at % 4;
    for (var value = 1; value <= 4; value++) {
      final neighbours = peers(r, c);
      final conflicts = neighbours
          .where((k) => t.cells[k ~/ 4][k % 4] == value)
          .toSet();
      if (conflicts.isNotEmpty) {
        t.snap(
          'Reject $value at ($r,$c): it already occurs in a highlighted peer.',
          r: r,
          c: c,
          refs: conflicts,
        );
        continue;
      }
      t.put(r, c, value);
      t.snap(
        'Place $value at ($r,$c); check the next empty cell.',
        r: r,
        c: c,
        refs: neighbours.intersection(t.filled),
      );
      if (solve(at + 1)) return true;
      t.cells[r][c] = 0;
      t.filled.remove(at);
      t.snap(
        'Dead end: remove $value at ($r,$c) and try another digit.',
        r: r,
        c: c,
      );
    }
    return false;
  }

  final solved = solve(0);
  t.snap(
    solved
        ? 'Solved: every row, column, and 2×2 block contains 1–4.'
        : 'No solution: every legal choice has been exhausted.',
  );
  return t.frames;
}

/// Enumerate unique permutations by choosing, exploring, and undoing a prefix.
List<TableFrame> permutationBacktracking([List<int> values = const [1, 2, 3]]) {
  if (values.length > 6) {
    throw ArgumentError(
      'Use at most six values for this exhaustive visualization.',
    );
  }
  final n = values.length;
  final t = _Table(
    1,
    max(1, n),
    rowHeader: ['prefix'],
    colHeader: [for (var i = 0; i < max(1, n); i++) 'slot $i'],
  );
  final used = List<bool>.filled(n, false);
  var count = 0;
  List<int> last = [];
  t.snap(
    'Build each ordering from left to right. Undo a choice before exploring its sibling.',
  );
  void visit(int depth) {
    if (depth == n) {
      count++;
      last = t.cells[0].take(n).toList();
      t.snap('Permutation #$count: [${last.join(', ')}].');
      return;
    }
    final tried = <int>{};
    for (var i = 0; i < n; i++) {
      if (used[i] || !tried.add(values[i])) continue;
      used[i] = true;
      t.put(0, depth, values[i]);
      t.snap(
        'Choose ${values[i]} for slot $depth.',
        r: 0,
        c: depth,
        refs: {for (var k = 0; k < depth; k++) t.key(0, k)},
      );
      visit(depth + 1);
      used[i] = false;
      t.filled.remove(depth);
      t.cells[0][depth] = 0;
      t.snap(
        'Backtrack: clear slot $depth to explore the next choice.',
        r: 0,
        c: depth,
      );
    }
  }

  visit(0);
  for (var i = 0; i < n; i++) {
    t.put(0, i, last[i]);
  }
  t.snap('Generated $count distinct permutations; the last ordering is shown.');
  return t.frames;
}
