import '../models/frames.dart';

/// Kadane's algorithm — finds the contiguous subarray with the largest sum in
/// one pass, extending the current run or restarting it at each element.
List<ArrayFrame> kadane(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[
    ArrayFrame(values: [...a], caption: 'Find the contiguous subarray with the largest sum.'),
  ];
  var best = a[0], cur = a[0];
  var bestLo = 0, bestHi = 0, curLo = 0;
  frames.add(ArrayFrame(
    values: [...a],
    comparing: {0},
    windowLo: 0,
    windowHi: 0,
    done: {0},
    caption: 'Start: best sum = ${a[0]}.',
  ));
  for (var i = 1; i < a.length; i++) {
    if (cur + a[i] < a[i]) {
      cur = a[i];
      curLo = i;
    } else {
      cur += a[i];
    }
    if (cur > best) {
      best = cur;
      bestLo = curLo;
      bestHi = i;
    }
    frames.add(ArrayFrame(
      values: [...a],
      comparing: {i},
      windowLo: curLo,
      windowHi: i,
      done: {for (var k = bestLo; k <= bestHi; k++) k},
      caption: 'At ${a[i]}: current run = $cur, best so far = $best.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = bestLo; k <= bestHi; k++) k},
    caption: 'Largest subarray sum = $best (indices $bestLo–$bestHi).',
  ));
  return frames;
}

const _inf = 1 << 29;

/// Floyd–Warshall — all-pairs shortest paths. Relaxes every pair (i, j) through
/// each intermediate vertex k, filling a distance matrix.
List<TableFrame> floydWarshall() {
  const labels = ['A', 'B', 'C', 'D'];
  final n = labels.length;
  final dist = [
    [0, 3, _inf, 7],
    [8, 0, 2, _inf],
    [5, _inf, 0, 1],
    [2, _inf, _inf, 0],
  ];
  final allFilled = {for (var i = 0; i < n * n; i++) i};
  List<List<int>> snap() => [for (final r in dist) [...r]];

  final frames = <TableFrame>[
    TableFrame(
      rows: n,
      cols: n,
      cells: snap(),
      rowHeader: labels,
      colHeader: labels,
      filled: allFilled,
      caption: 'Start from the direct edge weights (∞ means no edge).',
    ),
  ];
  for (var k = 0; k < n; k++) {
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if (dist[i][k] != _inf && dist[k][j] != _inf && dist[i][k] + dist[k][j] < dist[i][j]) {
          dist[i][j] = dist[i][k] + dist[k][j];
          frames.add(TableFrame(
            rows: n,
            cols: n,
            cells: snap(),
            rowHeader: labels,
            colHeader: labels,
            activeR: i,
            activeC: j,
            refs: {i * n + k, k * n + j},
            filled: allFilled,
            caption: 'Through ${labels[k]}: ${labels[i]}→${labels[j]} drops to ${dist[i][j]}.',
          ));
        }
      }
    }
  }
  frames.add(TableFrame(
    rows: n,
    cols: n,
    cells: snap(),
    rowHeader: labels,
    colHeader: labels,
    filled: allFilled,
    caption: 'All-pairs shortest distances computed.',
  ));
  return frames;
}

/// Fractional Knapsack — the greedy solution: sort items by value-to-weight
/// ratio and take as much of each as fits, splitting the last one.
List<ArrayFrame> fractionalKnapsack() {
  final items = <({int w, int v})>[
    (w: 4, v: 40),
    (w: 3, v: 18),
    (w: 5, v: 35),
    (w: 2, v: 20),
    (w: 6, v: 30),
  ];
  items.sort((a, b) => (b.v / b.w).compareTo(a.v / a.w));
  final weights = [for (final it in items) it.w];
  final frames = <ArrayFrame>[
    ArrayFrame(values: [...weights], caption: 'Items sorted by value/weight ratio (bars = weight).'),
  ];
  var cap = 10;
  var total = 0.0;
  final done = <int>{};
  for (var i = 0; i < items.length; i++) {
    if (cap <= 0) break;
    final it = items[i];
    if (it.w <= cap) {
      cap -= it.w;
      total += it.v;
      done.add(i);
      frames.add(ArrayFrame(
        values: [...weights],
        active: {i},
        done: {...done},
        caption: 'Take all of item ${i + 1} (w${it.w}, v${it.v}); capacity left $cap.',
      ));
    } else {
      final frac = cap / it.w;
      total += it.v * frac;
      done.add(i);
      frames.add(ArrayFrame(
        values: [...weights],
        comparing: {i},
        done: {...done},
        caption: 'Take ${(frac * 100).round()}% of item ${i + 1}; knapsack full.',
      ));
      cap = 0;
    }
  }
  frames.add(ArrayFrame(
    values: [...weights],
    done: {...done},
    caption: 'Greedy total value: ${total.round()}.',
  ));
  return frames;
}

/// 0/1 Knapsack via dynamic programming. Fills a (items+1) × (capacity+1) table
/// where dp[i][w] is the best value using the first i items within weight w,
/// emitting a [TableFrame] for each cell as it is computed.
List<TableFrame> knapsack({List<int>? weights, List<int>? values, int? capacity}) {
  final w = weights ?? const [2, 3, 4, 5];
  final v = values ?? const [3, 4, 5, 6];
  final cap = capacity ?? 8;
  final n = w.length;
  final rows = n + 1;
  final cols = cap + 1;

  final dp = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  final filled = <int>{};
  final colHeader = [for (var c = 0; c < cols; c++) '$c'];
  final rowHeader = ['∅', for (var i = 0; i < n; i++) 'w${w[i]} v${v[i]}'];

  List<List<int>> snap() => [for (final row in dp) [...row]];

  final frames = <TableFrame>[];
  for (var c = 0; c < cols; c++) {
    filled.add(c);
  }
  frames.add(TableFrame(
    rows: rows,
    cols: cols,
    cells: snap(),
    rowHeader: rowHeader,
    colHeader: colHeader,
    filled: {...filled},
    caption: 'Row 0: with no items the best value is 0 for every capacity.',
  ));

  for (var i = 1; i <= n; i++) {
    for (var c = 0; c < cols; c++) {
      final refs = <int>{};
      String caption;
      if (w[i - 1] > c) {
        dp[i][c] = dp[i - 1][c];
        refs.add((i - 1) * cols + c);
        caption = 'Item $i (weight ${w[i - 1]}) doesn’t fit in $c — copy ${dp[i - 1][c]} from above.';
      } else {
        final skip = dp[i - 1][c];
        final take = v[i - 1] + dp[i - 1][c - w[i - 1]];
        dp[i][c] = skip > take ? skip : take;
        refs
          ..add((i - 1) * cols + c)
          ..add((i - 1) * cols + (c - w[i - 1]));
        caption = 'max(skip $skip, take ${v[i - 1]}+${dp[i - 1][c - w[i - 1]]}=$take) = ${dp[i][c]}.';
      }
      filled.add(i * cols + c);
      frames.add(TableFrame(
        rows: rows,
        cols: cols,
        cells: snap(),
        rowHeader: rowHeader,
        colHeader: colHeader,
        activeR: i,
        activeC: c,
        refs: refs,
        filled: {...filled},
        caption: caption,
      ));
    }
  }

  frames.add(TableFrame(
    rows: rows,
    cols: cols,
    cells: snap(),
    rowHeader: rowHeader,
    colHeader: colHeader,
    activeR: n,
    activeC: cap,
    filled: {...filled},
    caption: 'Best value for capacity $cap using all items: ${dp[n][cap]}.',
  ));
  return frames;
}

/// Longest Common Subsequence via DP. dp[i][j] is the LCS length of the first i
/// characters of s1 and the first j of s2.
List<TableFrame> lcs([String s1 = 'AGCAT', String s2 = 'GAC']) {
  final m = s1.length, n = s2.length;
  final rows = m + 1, cols = n + 1;
  final dp = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  final rowHeader = ['∅', for (var i = 0; i < m; i++) s1[i]];
  final colHeader = ['∅', for (var j = 0; j < n; j++) s2[j]];
  final filled = <int>{};
  for (var c = 0; c < cols; c++) {
    filled.add(c);
  }
  for (var r = 0; r < rows; r++) {
    filled.add(r * cols);
  }
  List<List<int>> snap() => [for (final r in dp) [...r]];
  final frames = <TableFrame>[
    TableFrame(rows: rows, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, filled: {...filled}, caption: 'Empty prefixes share a subsequence of length 0.'),
  ];
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      final match = s1[i - 1] == s2[j - 1];
      final refs = <int>{};
      if (match) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
        refs.add((i - 1) * cols + (j - 1));
      } else {
        dp[i][j] = dp[i - 1][j] >= dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        refs
          ..add((i - 1) * cols + j)
          ..add(i * cols + (j - 1));
      }
      filled.add(i * cols + j);
      frames.add(TableFrame(
        rows: rows,
        cols: cols,
        cells: snap(),
        rowHeader: rowHeader,
        colHeader: colHeader,
        activeR: i,
        activeC: j,
        refs: refs,
        filled: {...filled},
        caption: match ? '${s1[i - 1]} = ${s2[j - 1]} → diagonal + 1 = ${dp[i][j]}.' : 'No match → max(up, left) = ${dp[i][j]}.',
      ));
    }
  }
  frames.add(TableFrame(rows: rows, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, activeR: m, activeC: n, filled: {...filled}, caption: 'LCS length of "$s1" and "$s2" = ${dp[m][n]}.'));
  return frames;
}

/// Edit (Levenshtein) distance via DP — the fewest single-character inserts,
/// deletes, or replacements turning s1 into s2.
List<TableFrame> editDistance([String s1 = 'kitten', String s2 = 'sitting']) {
  final m = s1.length, n = s2.length;
  final rows = m + 1, cols = n + 1;
  final dp = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  for (var i = 0; i < rows; i++) {
    dp[i][0] = i;
  }
  for (var j = 0; j < cols; j++) {
    dp[0][j] = j;
  }
  final rowHeader = ['∅', for (var i = 0; i < m; i++) s1[i]];
  final colHeader = ['∅', for (var j = 0; j < n; j++) s2[j]];
  final filled = <int>{};
  for (var c = 0; c < cols; c++) {
    filled.add(c);
  }
  for (var r = 0; r < rows; r++) {
    filled.add(r * cols);
  }
  List<List<int>> snap() => [for (final r in dp) [...r]];
  final frames = <TableFrame>[
    TableFrame(rows: rows, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, filled: {...filled}, caption: 'Base case: turning a prefix into ∅ costs its length.'),
  ];
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      final match = s1[i - 1] == s2[j - 1];
      if (match) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        final a = dp[i - 1][j], b = dp[i][j - 1], c = dp[i - 1][j - 1];
        final mn = [a, b, c].reduce((x, y) => x < y ? x : y);
        dp[i][j] = mn + 1;
      }
      filled.add(i * cols + j);
      frames.add(TableFrame(
        rows: rows,
        cols: cols,
        cells: snap(),
        rowHeader: rowHeader,
        colHeader: colHeader,
        activeR: i,
        activeC: j,
        refs: {(i - 1) * cols + (j - 1), (i - 1) * cols + j, i * cols + (j - 1)},
        filled: {...filled},
        caption: match ? '${s1[i - 1]} matches → copy the diagonal (${dp[i][j]}).' : 'min(insert, delete, replace) + 1 = ${dp[i][j]}.',
      ));
    }
  }
  frames.add(TableFrame(rows: rows, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, activeR: m, activeC: n, filled: {...filled}, caption: 'Edit distance "$s1" → "$s2" = ${dp[m][n]}.'));
  return frames;
}

/// Coin Change (fewest coins) via DP — dp[a] is the minimum number of coins that
/// sum to a, shown as a single row that fills left to right.
List<TableFrame> coinChange([List<int> coins = const [1, 3, 4], int amount = 8]) {
  final cols = amount + 1;
  final dp = List<int>.filled(cols, _inf);
  dp[0] = 0;
  final rowHeader = ['min coins'];
  final colHeader = [for (var a = 0; a < cols; a++) '$a'];
  final filled = <int>{0};
  List<List<int>> snap() => [
        [...dp]
      ];
  final frames = <TableFrame>[
    TableFrame(rows: 1, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, filled: {0}, caption: '0 coins make amount 0; the rest start at ∞.'),
  ];
  for (var a = 1; a <= amount; a++) {
    for (final c in coins) {
      if (c <= a && dp[a - c] + 1 < dp[a]) dp[a] = dp[a - c] + 1;
    }
    filled.add(a);
    frames.add(TableFrame(
      rows: 1,
      cols: cols,
      cells: snap(),
      rowHeader: rowHeader,
      colHeader: colHeader,
      activeR: 0,
      activeC: a,
      filled: {...filled},
      caption: 'Fewest coins for $a from {${coins.join(', ')}}: ${dp[a] >= _inf ? '∞' : dp[a]}.',
    ));
  }
  frames.add(TableFrame(rows: 1, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, activeR: 0, activeC: amount, filled: {...filled}, caption: 'Minimum coins for $amount = ${dp[amount]}.'));
  return frames;
}

/// Longest Increasing Subsequence — dp[i] is the length of the longest strictly
/// increasing subsequence ending at i; the answer is highlighted at the end.
List<ArrayFrame> longestIncreasingSubsequence(List<int> input) {
  final a = [...input];
  final n = a.length;
  final dp = List<int>.filled(n, 1);
  final prev = List<int>.filled(n, -1);
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Find the longest strictly increasing subsequence.')];
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < i; j++) {
      frames.add(ArrayFrame(values: [...a], comparing: {j}, active: {i}, caption: 'Can ${a[i]} extend the run ending at ${a[j]}?'));
      if (a[j] < a[i] && dp[j] + 1 > dp[i]) {
        dp[i] = dp[j] + 1;
        prev[i] = j;
      }
    }
  }
  var best = 0;
  for (var i = 1; i < n; i++) {
    if (dp[i] > dp[best]) best = i;
  }
  final lis = <int>{};
  var k = best;
  while (k != -1) {
    lis.add(k);
    k = prev[k];
  }
  frames.add(ArrayFrame(values: [...a], done: lis, caption: 'Longest increasing subsequence has length ${dp[best]}.'));
  return frames;
}

/// Subset Sum — dp[i][s] is 1 if some subset of the first i numbers sums to s.
List<TableFrame> subsetSum([List<int> nums = const [3, 4, 5, 2], int target = 9]) {
  final n = nums.length;
  final rows = n + 1, cols = target + 1;
  final dp = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  for (var i = 0; i < rows; i++) {
    dp[i][0] = 1;
  }
  final rowHeader = ['∅', for (final x in nums) '$x'];
  final colHeader = [for (var c = 0; c < cols; c++) '$c'];
  final filled = <int>{};
  for (var c = 0; c < cols; c++) {
    filled.add(c);
  }
  List<List<int>> snap() => [for (final r in dp) [...r]];
  final frames = <TableFrame>[
    TableFrame(rows: rows, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, filled: {...filled}, caption: 'The empty set reaches sum 0 only.'),
  ];
  for (var i = 1; i <= n; i++) {
    for (var c = 0; c < cols; c++) {
      final refs = <int>{(i - 1) * cols + c};
      dp[i][c] = dp[i - 1][c];
      if (nums[i - 1] <= c && dp[i - 1][c - nums[i - 1]] == 1) {
        dp[i][c] = 1;
        refs.add((i - 1) * cols + (c - nums[i - 1]));
      }
      filled.add(i * cols + c);
      frames.add(TableFrame(
        rows: rows,
        cols: cols,
        cells: snap(),
        rowHeader: rowHeader,
        colHeader: colHeader,
        activeR: i,
        activeC: c,
        refs: refs,
        filled: {...filled},
        caption: dp[i][c] == 1 ? 'Sum $c is reachable using the first $i numbers.' : 'Sum $c not reachable with the first $i numbers.',
      ));
    }
  }
  frames.add(TableFrame(rows: rows, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, activeR: n, activeC: target, filled: {...filled}, caption: dp[n][target] == 1 ? 'A subset sums to $target ✓' : 'No subset sums to $target.'));
  return frames;
}

/// Rod Cutting — dp[l] is the maximum revenue obtainable from a rod of length l.
List<TableFrame> rodCutting([List<int> price = const [1, 5, 8, 9, 10, 17, 17, 20], int len = 8]) {
  final cols = len + 1;
  final dp = List<int>.filled(cols, 0);
  final rowHeader = ['max value'];
  final colHeader = [for (var l = 0; l < cols; l++) '$l'];
  final filled = <int>{0};
  List<List<int>> snap() => [
        [...dp]
      ];
  final frames = <TableFrame>[
    TableFrame(rows: 1, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, filled: {0}, caption: 'Best revenue per rod length. Length 0 earns 0.'),
  ];
  for (var l = 1; l <= len; l++) {
    var best = 0;
    for (var c = 1; c <= l; c++) {
      if (c - 1 < price.length) {
        final val = price[c - 1] + dp[l - c];
        if (val > best) best = val;
      }
    }
    dp[l] = best;
    filled.add(l);
    frames.add(TableFrame(rows: 1, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, activeR: 0, activeC: l, filled: {...filled}, caption: 'Best revenue for length $l is $best.'));
  }
  frames.add(TableFrame(rows: 1, cols: cols, cells: snap(), rowHeader: rowHeader, colHeader: colHeader, activeR: 0, activeC: len, filled: {...filled}, caption: 'Maximum revenue for length $len = ${dp[len]}.'));
  return frames;
}
