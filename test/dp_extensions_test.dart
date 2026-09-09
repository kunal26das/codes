import 'dart:math';

import 'package:algoscope/algorithms/dp_extensions.dart';
import 'package:algoscope/data/dp_catalog.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/visualizers/sudoku_mini_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void _validFrames(List<TableFrame> frames) {
  expect(frames, isNotEmpty);
  TableFrame? previous;
  for (final frame in frames) {
    expect(frame.rows, greaterThan(0));
    expect(frame.cols, greaterThan(0));
    expect(frame.cells.length, frame.rows);
    expect(frame.rowHeader.length, frame.rows);
    expect(frame.colHeader.length, frame.cols);
    expect(frame.caption, isNotEmpty);
    for (final row in frame.cells) {
      expect(row.length, frame.cols);
    }
    for (final key in {...frame.filled, ...frame.refs}) {
      expect(key, inInclusiveRange(0, frame.rows * frame.cols - 1));
    }
    expect(frame.filled.containsAll(frame.refs), isTrue, reason: frame.caption);
    if (frame.activeR != null) {
      expect(frame.activeR, inInclusiveRange(0, frame.rows - 1));
    }
    if (frame.activeC != null) {
      expect(frame.activeC, inInclusiveRange(0, frame.cols - 1));
    }
    if (previous != null) {
      expect(identical(previous.cells, frame.cells), isFalse);
      expect(identical(previous.filled, frame.filled), isFalse);
      for (var r = 0; r < min(previous.rows, frame.rows); r++) {
        expect(identical(previous.cells[r], frame.cells[r]), isFalse);
      }
    }
    previous = frame;
  }
}

bool _subsequence(String part, String whole) {
  var i = 0;
  for (var j = 0; j < whole.length && i < part.length; j++) {
    if (part[i] == whole[j]) i++;
  }
  return i == part.length;
}

Iterable<String> _subsequences(String s) sync* {
  for (var mask = 0; mask < (1 << s.length); mask++) {
    yield [
      for (var i = 0; i < s.length; i++)
        if (mask & (1 << i) != 0) s[i],
    ].join();
  }
}

List<bool> _booleanResults(String expr) {
  if (expr.length == 1) return [expr == 'T'];
  final results = <bool>[];
  for (var i = 1; i < expr.length; i += 2) {
    for (final a in _booleanResults(expr.substring(0, i))) {
      for (final b in _booleanResults(expr.substring(i + 1))) {
        results.add(
          expr[i] == '&'
              ? a && b
              : expr[i] == '|'
              ? a || b
              : a != b,
        );
      }
    }
  }
  return results;
}

void _checkSudoku(List<List<int>> cells, {bool complete = false}) {
  void unique(List<int> values) {
    final placed = values.where((v) => v != 0).toList();
    expect(placed.toSet().length, placed.length);
    if (complete) expect(placed.toSet(), {1, 2, 3, 4});
  }

  for (var i = 0; i < 4; i++) {
    unique(cells[i]);
    unique([for (var r = 0; r < 4; r++) cells[r][i]]);
  }
  for (var r = 0; r < 4; r += 2) {
    for (var c = 0; c < 4; c += 2) {
      unique([
        cells[r][c],
        cells[r][c + 1],
        cells[r + 1][c],
        cells[r + 1][c + 1],
      ]);
    }
  }
}

void main() {
  test('all 17 additions produce valid, independent visual snapshots', () {
    final generators = <List<TableFrame> Function()>[
      matrixChainMultiplication,
      longestPalindromicSubsequence,
      longestCommonSubstring,
      shortestCommonSupersequence,
      unboundedKnapsack,
      coinChangeWays,
      uniqueGridPaths,
      minimumGridPathSum,
      houseRobber,
      eggDropping,
      booleanParenthesization,
      weightedIntervalScheduling,
      catalanNumbers,
      derangements,
      integerPartitions,
      sudoku4x4,
      permutationBacktracking,
    ];
    for (final create in generators) {
      _validFrames(create());
    }
    expect(dpExtensions.length, generators.length);
    expect(
      dpExtensions.map((info) => info.id).toSet().length,
      generators.length,
    );
    for (final info in dpExtensions) {
      final run = info.create();
      expect(run.frameCount, greaterThan(0), reason: info.name);
      expect(run.captionAt(0), isNotEmpty);
      expect(run.captionAt(run.frameCount - 1), isNotEmpty);
    }
  });

  test('matrix-chain costs match exhaustive parenthesizations', () {
    int brute(List<int> d, int i, int j) {
      if (i == j) return 0;
      return [
        for (var k = i; k < j; k++)
          brute(d, i, k) + brute(d, k + 1, j) + d[i] * d[k + 1] * d[j + 1],
      ].reduce(min);
    }

    for (final d in [
      [5, 3, 6, 2, 4],
      [10, 20],
      [10, 30, 5, 60],
      [3, 2, 4, 1, 5],
    ]) {
      final frames = matrixChainMultiplication(d);
      _validFrames(frames);
      expect(frames.last.cells[0].last, brute(d, 0, d.length - 2));
      expect(
        frames.first.cells.every((row) => row.every((value) => value == 0)),
        isTrue,
      );
    }
    expect(matrixChainMultiplication([10, 30, 5, 60]).last.cells[0].last, 4500);
  });

  test('palindromic subsequences match exhaustive subsequence enumeration', () {
    for (final text in ['', 'A', 'BBABC', 'BANANA', 'ABC', 'AAAA', 'ABCA']) {
      final expected = _subsequences(text)
          .where((s) => s == s.split('').reversed.join())
          .map((s) => s.length)
          .reduce(max);
      final frames = longestPalindromicSubsequence(text);
      _validFrames(frames);
      expect(frames.last.cells.first.last, expected);
      if (text.isNotEmpty) {
        final reconstructed = RegExp(
          r'"([^"]*)"',
        ).firstMatch(frames.last.caption)!.group(1)!;
        expect(reconstructed.length, expected);
        expect(reconstructed, reconstructed.split('').reversed.join());
        expect(_subsequence(reconstructed, text), isTrue);
      }
    }
  });

  test(
    'common substring remains contiguous and can end before the last cell',
    () {
      for (final (a, b) in [
        ('', 'ABC'),
        ('ABC', ''),
        ('ABABC', 'BABCA'),
        ('XYZ', 'AB'),
        ('CABD', 'ZABQ'),
      ]) {
        var expected = 0;
        for (var i = 0; i <= a.length; i++) {
          for (var j = i; j <= a.length; j++) {
            if (b.contains(a.substring(i, j))) expected = max(expected, j - i);
          }
        }
        final frames = longestCommonSubstring(a, b);
        _validFrames(frames);
        final last = frames.last;
        expect(last.cells[last.activeR!][last.activeC!], expected);
        final substring = RegExp(
          r'"([^"]*)"',
        ).firstMatch(last.caption)!.group(1)!;
        expect(substring.length, expected);
        expect(a.contains(substring) && b.contains(substring), isTrue);
      }
    },
  );

  test('supersequence traceback contains both inputs at minimum length', () {
    for (final (a, b) in [
      ('', ''),
      ('', 'ABC'),
      ('ABC', ''),
      ('ABAC', 'CAB'),
      ('AB', 'CD'),
      ('AAAA', 'AA'),
    ]) {
      final lcs = _subsequences(
        a,
      ).where((s) => _subsequence(s, b)).map((s) => s.length).reduce(max);
      final frames = shortestCommonSupersequence(a, b);
      _validFrames(frames);
      final sequence = RegExp(
        r'"([^"]*)"',
      ).firstMatch(frames.last.caption)!.group(1)!;
      expect(sequence.length, a.length + b.length - lcs);
      expect(_subsequence(a, sequence) && _subsequence(b, sequence), isTrue);
      expect(frames.last.cells.last.last, sequence.length);
    }
  });

  test(
    'unbounded knapsack matches exhaustive counts and reconstructs copies',
    () {
      int brute(List<int> weights, List<int> values, int capacity, int item) {
        if (item == weights.length) return 0;
        var best = 0;
        for (var count = 0; count * weights[item] <= capacity; count++) {
          best = max(
            best,
            count * values[item] +
                brute(
                  weights,
                  values,
                  capacity - count * weights[item],
                  item + 1,
                ),
          );
        }
        return best;
      }

      for (final (weights, values) in <(List<int>, List<int>)>[
        ([2, 3, 4], [4, 5, 7]),
        ([3], [5]),
        ([1, 2], [-1, 3]),
        ([], []),
      ]) {
        for (var capacity = 0; capacity <= 8; capacity++) {
          final frames = unboundedKnapsack(
            weights: weights,
            values: values,
            capacity: capacity,
          );
          _validFrames(frames);
          expect(
            frames.last.cells.last.last,
            brute(weights, values, capacity, 0),
          );
          final list = RegExp(
            r'\[([^\]]*)\]',
          ).firstMatch(frames.last.caption)!.group(1)!;
          final counts = list.isEmpty
              ? <int>[]
              : list.split(',').map((s) => int.parse(s.trim())).toList();
          expect(counts.length, weights.length);
          expect(
            [
              for (var i = 0; i < counts.length; i++) counts[i] * weights[i],
            ].fold<int>(0, (a, b) => a + b),
            lessThanOrEqualTo(capacity),
          );
          expect(
            [
              for (var i = 0; i < counts.length; i++) counts[i] * values[i],
            ].fold<int>(0, (a, b) => a + b),
            frames.last.cells.last.last,
          );
        }
      }
    },
  );

  test(
    'coin combinations count denominations once regardless of input order',
    () {
      int brute(List<int> coins, int amount, int at) {
        if (at == coins.length) return amount == 0 ? 1 : 0;
        var ways = 0;
        for (var remaining = amount; remaining >= 0; remaining -= coins[at]) {
          ways += brute(coins, remaining, at + 1);
        }
        return ways;
      }

      for (final coins in <List<int>>[
        [],
        [1],
        [2],
        [1, 2, 3],
        [3, 1, 2],
      ]) {
        for (var amount = 0; amount <= 7; amount++) {
          final frames = coinChangeWays(coins, amount);
          _validFrames(frames);
          expect(frames.last.cells.last.last, brute(coins, amount, 0));
        }
      }
      expect(coinChangeWays([1, 2, 3], 6).last.cells.last.last, 7);
    },
  );

  test(
    'grid path counts match route enumeration including unreachable goals',
    () {
      int brute(int r, int c, int rows, int cols, Set<int> blocked) {
        if (r == rows || c == cols || blocked.contains(r * cols + c)) return 0;
        if (r == rows - 1 && c == cols - 1) return 1;
        return brute(r + 1, c, rows, cols, blocked) +
            brute(r, c + 1, rows, cols, blocked);
      }

      for (final blocked in <Set<int>>[
        {},
        {5},
        {0},
        {11},
        {4, 5, 6, 7},
      ]) {
        final frames = uniqueGridPaths(rows: 3, cols: 4, blocked: blocked);
        _validFrames(frames);
        expect(frames.last.cells.last.last, brute(0, 0, 3, 4, blocked));
      }
      expect(
        uniqueGridPaths(rows: 1, cols: 1, blocked: {}).last.cells[0][0],
        1,
      );
    },
  );

  test(
    'minimum grid sum reconstructs an adjacent path with the claimed cost',
    () {
      int brute(List<List<int>> a, int r, int c) {
        if (r == a.length - 1 && c == a.first.length - 1) return a[r][c];
        return a[r][c] +
            [
              if (r + 1 < a.length) brute(a, r + 1, c),
              if (c + 1 < a.first.length) brute(a, r, c + 1),
            ].reduce(min);
      }

      for (final costs in <List<List<int>>>[
        [
          [4],
        ],
        [
          [1, 2, 3],
        ],
        [
          [1],
          [2],
          [3],
        ],
        [
          [1, 3, 1],
          [1, 5, 1],
          [4, 2, 1],
        ],
        [
          [2, -4],
          [1, 3],
        ],
      ]) {
        final frames = minimumGridPathSum(costs);
        _validFrames(frames);
        final last = frames.last;
        expect(last.cells.last.last, brute(costs, 0, 0));
        final path = last.refs.toList()..sort();
        expect(path.first, 0);
        expect(path.last, last.rows * last.cols - 1);
        expect(path.length, last.rows + last.cols - 1);
        var total = 0;
        for (var i = 0; i < path.length; i++) {
          total += costs[path[i] ~/ last.cols][path[i] % last.cols];
          if (i > 0) {
            expect(
              (path[i] ~/ last.cols - path[i - 1] ~/ last.cols).abs() +
                  (path[i] % last.cols - path[i - 1] % last.cols).abs(),
              1,
            );
          }
        }
        expect(total, last.cells.last.last);
      }
    },
  );

  test('house robber agrees with all nonadjacent subsets', () {
    final rng = Random(13);
    for (var trial = 0; trial < 30; trial++) {
      final values = [for (var i = 0; i < trial % 8; i++) rng.nextInt(12) - 3];
      var expected = 0;
      for (var mask = 0; mask < (1 << values.length); mask++) {
        if (mask & (mask << 1) != 0) continue;
        final sum = [
          for (var i = 0; i < values.length; i++)
            if (mask & (1 << i) != 0) values[i],
        ].fold<int>(0, (a, b) => a + b);
        expected = max(expected, sum);
      }
      final frames = houseRobber(values);
      _validFrames(frames);
      expect(frames.last.cells[1].last, expected);
      final chosen = frames.last.refs.map((k) => k - 1).toSet();
      expect(chosen.every((i) => !chosen.contains(i + 1)), isTrue);
      expect(chosen.fold<int>(0, (sum, i) => sum + values[i]), expected);
    }
  });

  test(
    'egg-dropping minimax matches the independent binomial coverage bound',
    () {
      int coverage(int moves, int eggs) {
        var choose = 1, total = 0;
        for (var k = 1; k <= min(moves, eggs); k++) {
          choose = choose * (moves - k + 1) ~/ k;
          total += choose;
        }
        return total;
      }

      for (var eggs = 1; eggs <= 3; eggs++) {
        for (var floors = 0; floors <= 8; floors++) {
          final frames = eggDropping(eggs: eggs, floors: floors);
          _validFrames(frames);
          final moves = frames.last.cells.last.last;
          expect(coverage(moves, eggs), greaterThanOrEqualTo(floors));
          if (moves > 0) expect(coverage(moves - 1, eggs), lessThan(floors));
        }
      }
    },
  );

  test(
    'boolean counts equal explicit evaluation of every parenthesization',
    () {
      for (final expression in [
        'T',
        'F',
        'T|F&T^T',
        'T^T^T',
        'F|F&F',
        'T&T|F^T',
      ]) {
        final evaluated = _booleanResults(expression);
        final frames = booleanParenthesization(expression);
        _validFrames(frames);
        final n = (expression.length + 1) ~/ 2;
        expect(frames.last.cells[0].last, evaluated.where((v) => v).length);
        expect(frames.last.cells[n].last, evaluated.where((v) => !v).length);
      }
    },
  );

  test('weighted scheduling matches exhaustive compatible subsets', () {
    final rng = Random(7);
    for (var trial = 0; trial < 30; trial++) {
      final jobs = <WeightedJob>[];
      for (var i = 0; i < trial % 7; i++) {
        final start = rng.nextInt(7);
        jobs.add((
          start: start,
          end: start + 1 + rng.nextInt(4),
          value: rng.nextInt(12) - 2,
        ));
      }
      var expected = 0;
      for (var mask = 0; mask < (1 << jobs.length); mask++) {
        final chosen = [
          for (var i = 0; i < jobs.length; i++)
            if (mask & (1 << i) != 0) jobs[i],
        ]..sort((a, b) => a.start.compareTo(b.start));
        if ([
          for (var i = 1; i < chosen.length; i++)
            chosen[i - 1].end <= chosen[i].start,
        ].every((ok) => ok)) {
          expected = max(
            expected,
            chosen.fold<int>(0, (sum, job) => sum + job.value),
          );
        }
      }
      final frames = weightedIntervalScheduling(jobs);
      _validFrames(frames);
      expect(frames.last.cells[3].last, expected);
      final last = frames.last;
      final columns = last.refs.map((key) => key % last.cols).toList()..sort();
      expect(
        columns.fold<int>(0, (sum, col) => sum + last.cells[2][col]),
        expected,
      );
      for (var i = 1; i < columns.length; i++) {
        expect(
          last.cells[1][columns[i - 1]],
          lessThanOrEqualTo(last.cells[0][columns[i]]),
        );
      }
    }
  });

  test(
    'Catalan, derangement, and partition sequences include their zero cases',
    () {
      const catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1430];
      const deranged = [1, 0, 1, 2, 9, 44, 265, 1854, 14833];
      const partition = [1, 1, 2, 3, 5, 7, 11, 15, 22];
      for (var n = 0; n <= 8; n++) {
        for (final (frames, value) in [
          (catalanNumbers(n), catalan[n]),
          (derangements(n), deranged[n]),
          (integerPartitions(n), partition[n]),
        ]) {
          _validFrames(frames);
          expect(frames.last.cells.last.last, value);
        }
      }
    },
  );

  test(
    'Sudoku preserves clues, maintains constraints, and reports unsolvable puzzles',
    () {
      final frames = sudoku4x4();
      _validFrames(frames);
      expect(frames.any((f) => f.caption.startsWith('Dead end:')), isTrue);
      final clues = frames.first;
      for (final frame in frames) {
        _checkSudoku(frame.cells);
        for (final key in clues.filled) {
          expect(
            frame.cells[key ~/ 4][key % 4],
            clues.cells[key ~/ 4][key % 4],
          );
        }
      }
      _checkSudoku(frames.last.cells, complete: true);
      final impossible = sudoku4x4([
        [1, 2, 3, 0],
        [0, 0, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      _validFrames(impossible);
      expect(impossible.last.caption, startsWith('No solution'));
      expect(impossible.last.cells, impossible.first.cells);
    },
  );

  test(
    'permutation search enumerates every unique ordering and undoes prefixes',
    () {
      for (final (values, expected) in <(List<int>, int)>[
        ([], 1),
        ([1], 1),
        ([1, 2, 3], 6),
        ([1, 1, 2], 3),
        ([1, 2, 3, 4], 24),
      ]) {
        final frames = permutationBacktracking(values);
        _validFrames(frames);
        final solutions = frames
            .where((f) => f.caption.startsWith('Permutation #'))
            .toList();
        expect(solutions.length, expected);
        expect(
          solutions
              .map((f) => f.cells.first.take(values.length).join(','))
              .toSet()
              .length,
          expected,
        );
        for (final solution in solutions) {
          final sorted = solution.cells.first.take(values.length).toList()
            ..sort();
          expect(sorted, [...values]..sort());
        }
        for (final frame in frames) {
          expect(frame.filled, {
            for (var i = 0; i < frame.filled.length; i++) i,
          });
        }
      }
    },
  );

  test(
    'invalid domains fail clearly instead of creating invalid recurrences',
    () {
      expect(() => matrixChainMultiplication([4]), throwsArgumentError);
      expect(
        () => unboundedKnapsack(weights: [0], values: [2]),
        throwsArgumentError,
      );
      expect(
        () => unboundedKnapsack(weights: [1], values: []),
        throwsArgumentError,
      );
      expect(() => coinChangeWays([1, 1], 4), throwsArgumentError);
      expect(() => coinChangeWays([0], 4), throwsArgumentError);
      expect(() => uniqueGridPaths(rows: 0), throwsArgumentError);
      expect(
        () => minimumGridPathSum([
          [1],
          [2, 3],
        ]),
        throwsArgumentError,
      );
      expect(() => eggDropping(eggs: 0), throwsRangeError);
      expect(() => booleanParenthesization('T&&F'), throwsArgumentError);
      expect(
        () => weightedIntervalScheduling([(start: 2, end: 1, value: 4)]),
        throwsArgumentError,
      );
      expect(() => catalanNumbers(-1), throwsRangeError);
      expect(() => derangements(-1), throwsRangeError);
      expect(() => integerPartitions(-1), throwsRangeError);
      expect(
        () => sudoku4x4([
          [1, 1, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]),
        throwsArgumentError,
      );
      expect(
        () => permutationBacktracking([1, 2, 3, 4, 5, 6, 7]),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'Sudoku draws clues, choices, and block boundaries at phone size',
    (tester) async {
      final frames = sudoku4x4();
      for (final side in [160.0, 320.0]) {
        for (final frame in [
          frames.first,
          frames[frames.length ~/ 2],
          frames.last,
        ]) {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox.square(
                  dimension: side,
                  child: SudokuMiniView(
                    frame: frame,
                    clues: frames.first.filled,
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
}
