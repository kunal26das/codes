import 'dart:math';

import '../algorithms/dp_extensions.dart';
import '../models/algorithm.dart';
import '../models/frames.dart';
import '../models/viz_run.dart';
import '../theme/app_colors.dart';
import '../visualizers/sudoku_mini_view.dart';
import '../visualizers/table_view.dart';

final _rng = Random();
String _word(int length) => String.fromCharCodes([
  for (var i = 0; i < length; i++) 65 + _rng.nextInt(4),
]);
List<int> _numbers(int length, {int minimum = 1, int spread = 9}) => [
  for (var i = 0; i < length; i++) minimum + _rng.nextInt(spread),
];

VizRun _tableRun(List<TableFrame> frames) => VizRun(
  legend: const [
    (AppColors.active, 'Computing / traceback'),
    (AppColors.compare, 'Dependencies'),
  ],
  frameCount: frames.length,
  captionAt: (i) => frames[i].caption,
  builder: (context, i) => TableView(frame: frames[i]),
);

AlgorithmInfo _entry(
  String id,
  String name,
  String blurb,
  String description,
  String time,
  String space,
  List<TableFrame> Function() create, {
  AlgoCategory category = AlgoCategory.dynamicProgramming,
}) => AlgorithmInfo(
  id: id,
  name: name,
  category: category,
  blurb: blurb,
  description: description,
  timeComplexity: time,
  spaceComplexity: space,
  originalSources: const ['Dart'],
  create: () => _tableRun(create()),
);

/// Recurrence-driven additions, with deliberately small examples for teaching.
final List<AlgorithmInfo> dpExtensions = [
  _entry(
    'matrix-chain-multiplication',
    'Matrix Chain Multiplication',
    'Find the cheapest order of matrix products.',
    'An interval table tries every split of a compatible matrix chain. Each trial combines the optimal left and right costs with the scalar cost of joining them; the final caption reconstructs the parenthesization.',
    'O(n³)',
    'O(n²)',
    () => matrixChainMultiplication(_numbers(5, minimum: 2, spread: 6)),
  ),
  _entry(
    'longest-palindromic-subsequence',
    'Longest Palindromic Subsequence',
    'Pair matching ends or discard an endpoint.',
    'Grow character intervals from short to long. Equal ends extend an inner palindrome; different ends choose the better remaining interval. The highlighted traceback reconstructs one longest palindromic subsequence.',
    'O(n²)',
    'O(n²)',
    () => longestPalindromicSubsequence(_word(6)),
  ),
  _entry(
    'longest-common-substring',
    'Longest Common Substring',
    'Grow matching diagonals; reset at mismatches.',
    'Each table cell counts a common suffix ending at the current pair of characters. A mismatch resets the value to zero, so the result is contiguous in both strings. The maximum can occur anywhere in the table.',
    'O(mn)',
    'O(mn)',
    () {
      final common = _word(3);
      return longestCommonSubstring('${_word(2)}$common', '$common${_word(2)}');
    },
  ),
  _entry(
    'shortest-common-supersequence',
    'Shortest Common Supersequence',
    'Merge two sequences with the fewest characters.',
    'A shared end character appears once; otherwise append one end to the shorter neighboring solution. Trace the table backward to construct a shortest string containing both inputs as subsequences.',
    'O(mn)',
    'O(mn)',
    () => shortestCommonSupersequence(_word(4), _word(3)),
  ),
  _entry(
    'unbounded-knapsack',
    'Unbounded Knapsack',
    'Choose any number of copies of each item.',
    'Compare skipping an item with taking its value plus the best result at the remaining capacity in the same row. That same-row dependency permits reuse. The final caption gives the number of copies selected.',
    'O(nW)',
    'O(nW)',
    () => unboundedKnapsack(
      weights: const [2, 3, 4],
      values: _numbers(3, minimum: 3, spread: 7),
      capacity: 7,
    ),
  ),
  _entry(
    'coin-change-ways',
    'Coin Change Combinations',
    'Count combinations without counting their order.',
    'For each denomination and amount, add ways that omit the coin to ways that use it at least once. Processing denominations by rows counts unordered combinations, rather than sequences of coins.',
    'O(nA)',
    'O(nA)',
    () => coinChangeWays([1, 2, 3 + _rng.nextInt(3)], 6 + _rng.nextInt(2)),
  ),
  _entry(
    'unique-grid-paths',
    'Unique Grid Paths',
    'Count right-and-down routes around obstacles.',
    'A cell receives the sum of routes arriving from above and from the left. Blocked cells contribute zero. The bottom-right cell counts all legal monotone routes, including the possibility that no route exists.',
    'O(RC)',
    'O(RC)',
    () => uniqueGridPaths(blocked: {4 + _rng.nextInt(4)}),
  ),
  _entry(
    'minimum-grid-path-sum',
    'Minimum Grid Path Sum',
    'Choose the cheaper predecessor at each cell.',
    'Moving only right or down creates an acyclic dependency graph. Add each cell’s cost to the cheaper reachable predecessor. The final highlighted cells reconstruct a minimum-cost route.',
    'O(RC)',
    'O(RC)',
    () => minimumGridPathSum([
      for (var r = 0; r < 3; r++) _numbers(4, spread: 5),
    ]),
  ),
  _entry(
    'house-robber',
    'House Robber',
    'Maximize the total without choosing neighbors.',
    'For every prefix, either skip its last house or take it and combine with the prefix ending two houses earlier. Trace the better choices backward to recover a nonadjacent selection.',
    'O(n)',
    'O(n)',
    () => houseRobber(_numbers(6, spread: 12)),
  ),
  _entry(
    'egg-dropping',
    'Egg Dropping',
    'Minimize the worst-case number of experiments.',
    'Try each possible drop floor. A break leaves one fewer egg and the floors below; survival leaves the floors above. Minimize one plus the worse of those outcomes to guarantee finding the threshold.',
    'O(EF²)',
    'O(EF)',
    () => eggDropping(eggs: 2 + _rng.nextInt(2), floors: 5 + _rng.nextInt(2)),
  ),
  _entry(
    'boolean-parenthesization',
    'Boolean Parenthesization',
    'Count bracketings that make an expression true.',
    'Track true and false counts for every operand interval. At each operator, combine the four truth-value pairs from the left and right intervals according to its truth table. Both outcomes matter for later splits.',
    'O(n³)',
    'O(n²)',
    () {
      const operators = ['&', '|', '^'];
      return booleanParenthesization(
        [
          for (var i = 0; i < 4; i++)
            '${i == 0 ? '' : operators[_rng.nextInt(3)]}${_rng.nextBool() ? 'T' : 'F'}',
        ].join(),
      );
    },
  ),
  _entry(
    'weighted-interval-scheduling',
    'Weighted Interval Scheduling',
    'Pick the most valuable compatible jobs.',
    'Sort jobs by finish time and binary-search each job’s last compatible predecessor. Compare skipping a job with taking its value plus that predecessor’s optimum. Highlight the selected jobs after traceback.',
    'O(n log n)',
    'O(n)',
    () => weightedIntervalScheduling([
      (start: 1, end: 3, value: 3 + _rng.nextInt(6)),
      (start: 2, end: 5, value: 3 + _rng.nextInt(6)),
      (start: 4, end: 6, value: 3 + _rng.nextInt(6)),
      (start: 6, end: 7, value: 2 + _rng.nextInt(5)),
      (start: 5, end: 8, value: 7 + _rng.nextInt(7)),
      (start: 7, end: 9, value: 2 + _rng.nextInt(5)),
    ]),
  ),
  _entry(
    'catalan-numbers',
    'Catalan Numbers',
    'Count structures by splitting left and right.',
    'With C₀ = 1, sum Cᵢ times Cₙ₋₁₋ᵢ over every left/right split. The same sequence counts balanced parentheses, binary tree shapes, and many other recursively divided structures.',
    'O(n²)',
    'O(n)',
    () => catalanNumbers(5 + _rng.nextInt(3)),
    category: AlgoCategory.mathematics,
  ),
  _entry(
    'derangements',
    'Derangements',
    'Count permutations with no fixed positions.',
    'After moving the first object into one of n−1 positions, either its partner swaps back or joins a longer cycle. These cases give Dₙ = (n−1)(Dₙ₋₁ + Dₙ₋₂), starting from D₀ = 1 and D₁ = 0.',
    'O(n)',
    'O(n)',
    () => derangements(5 + _rng.nextInt(3)),
    category: AlgoCategory.mathematics,
  ),
  _entry(
    'integer-partitions',
    'Integer Partitions',
    'Count unordered sums of positive integers.',
    'Limit the largest allowed part. A partition either omits that part or removes one copy and partitions the remainder with the same limit. This counts 3+1 and 1+3 as a single partition.',
    'O(n²)',
    'O(n²)',
    () => integerPartitions(5 + _rng.nextInt(2)),
    category: AlgoCategory.mathematics,
  ),
  AlgorithmInfo(
    id: 'sudoku-4x4',
    name: 'Sudoku 4×4',
    category: AlgoCategory.backtracking,
    blurb: 'Place a legal digit, explore, and undo dead ends.',
    description:
        'Solve a compact Sudoku using row, column, and 2×2-block constraints. Highlight conflicts before rejecting a digit; if a legal choice leads to a dead end, erase it and explore another choice. Dark digits are original clues.',
    timeComplexity: 'O(4^empty)',
    spaceComplexity: 'O(empty)',
    originalSources: const ['Dart'],
    create: () {
      final digits = [1, 2, 3, 4]..shuffle(_rng);
      const puzzle = [
        [0, 0, 0, 0],
        [0, 0, 1, 0],
        [0, 1, 0, 4],
        [0, 4, 2, 1],
      ];
      final frames = sudoku4x4([
        for (final row in puzzle)
          [for (final v in row) v == 0 ? 0 : digits[v - 1]],
      ]);
      return VizRun(
        legend: const [
          (AppColors.active, 'Current cell'),
          (AppColors.compare, 'Conflicting cell'),
          (AppColors.done, 'Placed digit'),
        ],
        frameCount: frames.length,
        captionAt: (i) => frames[i].caption,
        builder: (context, i) =>
            SudokuMiniView(frame: frames[i], clues: frames.first.filled),
      );
    },
  ),
  _entry(
    'permutation-backtracking',
    'Permutation Backtracking',
    'Choose a prefix, recurse, then undo the choice.',
    'Try each unused value in the next slot, recursively finish the ordering, then clear the slot. A set of choices tried at each depth prevents duplicate permutations when values repeat. Every completed ordering receives its own frame.',
    'O(n · n!)',
    'O(n)',
    () {
      final values = [1, 2, 3, 4, 5, 6]..shuffle(_rng);
      return permutationBacktracking(values.take(3).toList());
    },
    category: AlgoCategory.backtracking,
  ),
];
