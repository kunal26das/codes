import 'dart:math';

import '../algorithms/sequence_extensions.dart';
import '../models/algorithm.dart';
import '../models/sequence_trace.dart';
import '../models/viz_run.dart';
import '../theme/app_colors.dart';
import '../visualizers/sequence_trace_view.dart';

final _random = Random();
List<int> _numbers([int count = 8]) =>
    List.generate(count, (_) => _random.nextInt(19) - 5);
T _pick<T>(List<T> choices) => choices[_random.nextInt(choices.length)];

AlgorithmInfo _entry(
  String id,
  String name,
  AlgoCategory category,
  String blurb,
  String description,
  String time,
  String space,
  List<SequenceTrace> Function() generate,
) => AlgorithmInfo(
  id: id,
  name: name,
  category: category,
  blurb: blurb,
  description: description,
  timeComplexity: time,
  spaceComplexity: space,
  originalSources: const ['Dart'],
  create: () {
    final frames = generate();
    return VizRun(
      legend: const [
        (AppColors.compare, 'Current / comparing'),
        (AppColors.highlight, 'Active range'),
        (AppColors.done, 'Processed / result'),
      ],
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => SequenceTraceView(frame: frames[i]),
    );
  },
);

/// Additional algorithms built around observable cursors and working state.
final List<AlgorithmInfo> sequenceExtensions = [
  _entry(
    'two-pointer-pair-sum',
    'Two-Pointer Pair Sum',
    AlgoCategory.arrays,
    'Move inward from both ends to find a target sum.',
    'For sorted input, a sum below the target allows the left pointer to advance; '
        'a sum above it allows the right pointer to retreat. Each decision discards '
        'pairs that cannot work. The highlighted interval shows the remaining search.',
    'O(n)',
    'O(1)',
    () {
      final values = _numbers()..sort();
      return twoPointerPairSum(values, values[1] + values[6]);
    },
  ),
  _entry(
    'sliding-window-sum',
    'Sliding Window Maximum Sum',
    AlgoCategory.arrays,
    'Reuse a running sum as a fixed window moves.',
    'The first window is accumulated once. Sliding adds the incoming element and '
        'subtracts the outgoing element. Compare each complete window with the best '
        'sum; negative inputs are handled without assuming the answer is zero.',
    'O(n)',
    'O(1)',
    () => maxWindowSum(_numbers(), 3 + _random.nextInt(2)),
  ),
  _entry(
    'longest-unique-window',
    'Longest Unique Substring',
    AlgoCategory.strings,
    'Shrink a window past repeated characters.',
    'Track the latest position of every Unicode code point. A duplicate inside '
        'the current window moves its left boundary past the earlier occurrence. '
        'The last-seen row explains each jump, and the best window is retained.',
    'O(n)',
    'O(k)',
    () => longestUniqueWindow(
      _pick(['abcabcbb', 'pwwkew', 'abcaefbg', 'dvdfac']),
    ),
  ),
  _entry(
    'dutch-national-flag',
    'Dutch National Flag',
    AlgoCategory.arrays,
    'Partition three values with low, scan and high cursors.',
    'Maintain a region of zeros, a region of ones, an unknown region, and a '
        'region of twos. A two swaps with the unknown right edge without advancing '
        'scan, because the incoming value must still be classified.',
    'O(n)',
    'O(1)',
    () => dutchFlag(List.generate(10, (_) => _random.nextInt(3))),
  ),
  _entry(
    'prefix-range-sum',
    'Prefix Sums and Range Queries',
    AlgoCategory.arrays,
    'Build cumulative sums for constant-time range queries.',
    'Prefix[i] is the sum of elements strictly before i. An inclusive range '
        '[left, right] is answered by Prefix[right + 1] − Prefix[left]. The two '
        'prefix cursors show exactly which totals are subtracted.',
    'O(n) build; O(1) query',
    'O(n)',
    () => prefixRangeSum(_numbers(), 2, 5),
  ),
  _entry(
    'product-except-self',
    'Product Except Self',
    AlgoCategory.arrays,
    'Combine left and right products without division.',
    'The first pass writes the product of preceding values. A reverse pass '
        'multiplies each slot by the product of following values. Zeroes and negative '
        'values work naturally. The output array doubles as the prefix workspace.',
    'O(n)',
    'O(1) extra, excluding output',
    () => productExceptSelf(List.generate(6, (_) => _random.nextInt(6) - 1)),
  ),
  _entry(
    'trapping-rainwater',
    'Trapping Rainwater',
    AlgoCategory.arrays,
    'Use boundary maxima to fill each cell’s water level.',
    'Two cursors maintain the tallest left and right boundaries. Process the '
        'side with the smaller known maximum: the opposite side already supports '
        'that water level. The water row accumulates each cell’s contribution.',
    'O(n)',
    'O(1) algorithm space',
    () => trappedRainwater(
      _pick([
        [0, 2, 0, 1, 0, 3, 1, 2],
        [3, 0, 2, 0, 4, 1, 2, 3],
        [2, 0, 1, 0, 3, 0, 2, 1],
      ]),
    ),
  ),
  _entry(
    'majority-vote',
    'Boyer–Moore Majority Vote',
    AlgoCategory.arrays,
    'Cancel different votes, then verify the candidate.',
    'A zero balance selects a new candidate. Equal values increase the balance; '
        'different values decrease it. A second pass counts the candidate, preventing '
        'a false answer when no value occurs strictly more than half the time.',
    'O(n)',
    'O(1)',
    () => majorityVote(
      _pick([
        [2, 2, 1, 1, 2, 2, 2],
        [3, 1, 3, 2, 3, 3, 4],
        [1, 2, 3, 2, 1, 3, 4],
      ]),
    ),
  ),
  _entry(
    'next-greater-element',
    'Next Greater Element',
    AlgoCategory.stacksQueues,
    'Resolve pending positions with a monotonic stack.',
    'The stack stores unresolved indices in decreasing value order. A larger '
        'incoming value resolves and pops every smaller top. Each index is pushed '
        'and popped at most once; equal values are not considered greater.',
    'O(n)',
    'O(n)',
    () => nextGreaterElements(_numbers()),
  ),
  _entry(
    'balanced-brackets',
    'Balanced Brackets',
    AlgoCategory.stacksQueues,
    'Match nested delimiters against a stack.',
    'Opening brackets push onto a stack. A closing bracket must match the most '
        'recent opening bracket, which is then popped. A mismatch, an unmatched '
        'closing bracket, or a nonempty final stack makes the expression invalid.',
    'O(n)',
    'O(n)',
    () => balancedBrackets(_pick(['{[()]}()', '([{}])', '([)]', '(()[]'])),
  ),
  _entry(
    'shunting-yard',
    'Shunting-Yard Postfix Conversion',
    AlgoCategory.stacksQueues,
    'Use precedence and associativity to reorder operators.',
    'Operands go directly to the postfix output. Operators wait on a stack '
        'until precedence, associativity or closing parentheses require them to be '
        'emitted. This example supports binary +, −, ×, ÷ and right-associative ^.',
    'O(n)',
    'O(n)',
    () => shuntingYard(_pick(['3+4*2', '(8-3)*(2+1)', '2^3^2', '9/(3-1)+4'])),
  ),
  _entry(
    'postfix-evaluation',
    'Postfix Evaluation',
    AlgoCategory.stacksQueues,
    'Evaluate operators using a stack of intermediate values.',
    'Read the postfix tokens from left to right. Push operands. For an operator, '
        'pop the right operand and then the left operand, evaluate, and push the '
        'result. Exactly one value must remain after the final token.',
    'O(n)',
    'O(n)',
    () => evaluatePostfix(
      _pick([
        ['3', '4', '2', '*', '+'],
        ['8', '3', '-', '2', '1', '+', '*'],
        ['2', '3', '2', '^', '^'],
      ]),
    ),
  ),
  _entry(
    'run-length-encoding',
    'Run-Length Encoding',
    AlgoCategory.strings,
    'Compress repeated character runs into character:count pairs.',
    'Keep the start and length of the current run. A different character flushes '
        'that run and begins the next. Explicit character:count cells avoid ambiguity '
        'when the input itself contains digits. Unicode code points are preserved.',
    'O(n)',
    'O(r) output',
    () => runLengthEncode(
      _pick(['aaabbccccd', 'wwwwaaadex', '111223333', 'aabbbccaa']),
    ),
  ),
  _entry(
    'manacher-palindrome',
    'Manacher’s Longest Palindrome',
    AlgoCategory.strings,
    'Reuse mirrored palindrome radii to avoid repeated work.',
    'Interleaved separators give odd and even palindromes a common representation. '
        'Inside the rightmost known palindrome, reuse a mirrored radius capped by its '
        'boundary, then expand outward. The radii row exposes the reused work.',
    'O(n)',
    'O(n)',
    () => manacherPalindrome(_pick(['abacaba', 'cabbad', 'babad', 'banana'])),
  ),
  _entry(
    'equal-range-search',
    'Equal Range: Lower and Upper Bounds',
    AlgoCategory.searching,
    'Find both insertion boundaries around repeated values.',
    'First validate sorted input in O(n). Two binary searches then find the first element at least equal to the target '
        'and the first strictly greater element. Their half-open interval contains '
        'all matches. Equal boundaries also represent an absent target safely.',
    'O(n) check; O(log n) search',
    'O(1)',
    () {
      final values = List.generate(10, (_) => _random.nextInt(5))..sort();
      return equalRangeSearch(values, _random.nextInt(6));
    },
  ),
  _entry(
    'natural-merge-sort',
    'Natural Merge Sort',
    AlgoCategory.sorting,
    'Detect existing sorted runs and merge adjacent pairs.',
    'Scan for naturally ascending runs, then merge neighboring runs with a '
        'stable two-way merge. Repeat until a single run covers the input. Already '
        'sorted input needs only the initial scan; a merge buffer holds each result.',
    'O(n log n), O(n) best',
    'O(n)',
    () => naturalMergeSort(_numbers()),
  ),
  _entry(
    'binary-insertion-sort',
    'Binary Insertion Sort',
    AlgoCategory.sorting,
    'Find an insertion slot by binary search, then shift.',
    'For each new value, binary search its upper insertion bound in the sorted '
        'prefix. Shift intervening elements right and insert the held value. This '
        'reduces comparisons to O(n log n), but shifting still costs O(n²).',
    'O(n²) moves',
    'O(1)',
    () => binaryInsertionSort(_numbers()),
  ),
  _entry(
    'tournament-sort',
    'Tournament Sort',
    AlgoCategory.sorting,
    'Repeatedly select a winner and replay its tournament path.',
    'Input positions occupy leaves of a winner tree. Each internal match '
        'promotes its smaller value. Emit the root winner, retire that leaf, and '
        'replay only its ancestor matches. The tournament row uses value@index '
        'labels so duplicate values remain distinct competitors.',
    'O(n log n)',
    'O(n)',
    () => tournamentSort(_numbers(6)),
  ),
];
