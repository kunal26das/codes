import 'dart:math' as math;

import '../models/sequence_trace.dart';

SequenceTraceRow _row(
  String name,
  Iterable<Object> input, {
  Map<String, int> pointers = const {},
  Set<int> active = const {},
  Set<int> done = const {},
  int? lo,
  int? hi,
}) {
  final values = input.toList();
  bool valid(int i) => i >= 0 && i < values.length;
  return SequenceTraceRow(
    label: name,
    values: values,
    pointers: Map.fromEntries(pointers.entries.where((e) => valid(e.value))),
    active: active.where(valid).toSet(),
    done: done.where(valid).toSet(),
    rangeStart: lo != null && hi != null && valid(lo) && valid(hi) && lo <= hi
        ? lo
        : null,
    rangeEnd: lo != null && hi != null && valid(lo) && valid(hi) && lo <= hi
        ? hi
        : null,
  );
}

void _sorted(List<int> values) {
  for (var i = 1; i < values.length; i++) {
    if (values[i] < values[i - 1]) throw ArgumentError('Input must be sorted.');
  }
}

List<SequenceTrace> twoPointerPairSum(List<int> input, int target) {
  _sorted(input);
  var left = 0, right = input.length - 1;
  final frames = <SequenceTrace>[];
  void snap(String caption, {List<int> answer = const [], String result = ''}) {
    frames.add(
      SequenceTrace(
        caption: caption,
        rows: [
          _row(
            'Sorted input',
            input,
            pointers: {'left': left, 'right': right},
            lo: left,
            hi: right,
          ),
        ],
        variables: {'target': target, 'left': left, 'right': right},
        output: answer,
        result: result,
      ),
    );
  }

  snap('Start at the smallest and largest values.');
  while (left < right) {
    final sum = input[left] + input[right];
    snap('${input[left]} + ${input[right]} = $sum. Compare with $target.');
    if (sum == target) {
      snap(
        'Both pointers identify a matching pair.',
        answer: [input[left], input[right]],
        result: 'Pair: ${input[left]} + ${input[right]} = $target',
      );
      return frames;
    }
    if (sum < target) {
      left++;
      snap('The sum is too small: advance left to increase it.');
    } else {
      right--;
      snap('The sum is too large: move right inward to decrease it.');
    }
  }
  snap(
    'The pointers met without finding a pair.',
    result: 'No pair sums to $target.',
  );
  return frames;
}

List<SequenceTrace> maxWindowSum(List<int> input, int width) {
  if (width < 1 || width > input.length) {
    throw ArgumentError('Window width must be between 1 and input length.');
  }
  var sum = 0, bestStart = 0;
  int? best;
  final frames = <SequenceTrace>[];
  void snap(int right, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Window',
          input,
          pointers: {'left': math.max(0, right - width + 1), 'right': right},
          lo: math.max(0, right - width + 1),
          hi: right,
        ),
      ],
      variables: {
        'width': width,
        'sum': sum,
        'best': best ?? '—',
        'best start': bestStart,
      },
      output: complete ? [best!] : [],
      result: complete
          ? 'Maximum sum $best, starting at index $bestStart.'
          : '',
    ),
  );
  snap(-1, 'Grow the first window, then slide one cell at a time.');
  for (var right = 0; right < input.length; right++) {
    sum += input[right];
    if (right >= width) sum -= input[right - width];
    if (right >= width - 1 && (best == null || sum > best)) {
      best = sum;
      bestStart = right - width + 1;
    }
    snap(
      right,
      right < width
          ? 'Add ${input[right]} to the first window.'
          : 'Add ${input[right]} and remove ${input[right - width]}; reuse the previous sum.',
    );
  }
  snap(input.length - 1, 'Every window has been checked.', complete: true);
  return frames;
}

List<SequenceTrace> longestUniqueWindow(String input) {
  final chars = input.runes.map(String.fromCharCode).toList();
  final seen = <String, int>{};
  var left = 0, bestStart = 0, bestLength = 0;
  final frames = <SequenceTrace>[];
  void snap(int right, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Characters',
          chars,
          pointers: {'left': left, 'right': right},
          lo: left,
          hi: right,
        ),
        _row('Last seen', seen.entries.map((e) => '${e.key}:${e.value}')),
      ],
      variables: {
        'left': left,
        'best length': bestLength,
        'best start': bestStart,
      },
      output: complete ? [chars.skip(bestStart).take(bestLength).join()] : [],
      result: complete
          ? 'Longest unique substring: “${chars.skip(bestStart).take(bestLength).join()}” ($bestLength characters).'
          : '',
    ),
  );
  snap(-1, 'Keep a window with no repeated characters.');
  for (var right = 0; right < chars.length; right++) {
    final previous = seen[chars[right]];
    if (previous != null && previous >= left) {
      left = previous + 1;
      snap(
        right,
        '${chars[right]} repeats inside the window; move left past its previous occurrence.',
      );
    }
    seen[chars[right]] = right;
    if (right - left + 1 > bestLength) {
      bestLength = right - left + 1;
      bestStart = left;
    }
    snap(
      right,
      'Record ${chars[right]} at $right and measure the unique window.',
    );
  }
  snap(
    chars.length - 1,
    'The longest valid window is complete.',
    complete: true,
  );
  return frames;
}

List<SequenceTrace> dutchFlag(List<int> input) {
  if (input.any((v) => v < 0 || v > 2)) {
    throw ArgumentError('Values must be 0, 1 or 2.');
  }
  final a = [...input];
  var low = 0, mid = 0, high = a.length - 1;
  final frames = <SequenceTrace>[];
  void snap(String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Three colors',
          a,
          pointers: {'low': low, 'scan': mid, 'high': high},
          lo: mid,
          hi: high,
          done: {
            for (var i = 0; i < low; i++) i,
            for (var i = high + 1; i < a.length; i++) i,
          },
        ),
      ],
      variables: {
        'zeros before': low,
        'unknown starts': mid,
        'unknown ends': high,
      },
      output: complete ? a : [],
      result: complete ? 'Partitioned: ${a.join(', ')}' : '',
    ),
  );
  snap('Maintain zeros, ones, an unknown region, and twos.');
  while (mid <= high) {
    if (a[mid] == 0) {
      final t = a[low];
      a[low] = a[mid];
      a[mid] = t;
      low++;
      mid++;
      snap('Move zero to the left region; advance both pointers.');
    } else if (a[mid] == 1) {
      mid++;
      snap('One belongs in the middle; advance scan.');
    } else {
      final t = a[high];
      a[high] = a[mid];
      a[mid] = t;
      high--;
      snap('Move two to the right region; inspect the swapped-in value next.');
    }
  }
  snap('No unknown cells remain.', complete: true);
  return frames;
}

List<SequenceTrace> prefixRangeSum(List<int> input, int left, int right) {
  if (left < 0 || right < left || right >= input.length) {
    throw ArgumentError(
      'Expected a nonempty inclusive range inside the input.',
    );
  }
  final prefix = List<int>.filled(input.length + 1, 0);
  final frames = <SequenceTrace>[];
  void snap(int at, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Input', input, lo: left, hi: right),
        _row(
          'Prefix sums',
          prefix,
          pointers: complete
              ? {'subtract': left, 'total': right + 1}
              : {'write': at},
          done: {for (var i = 0; i <= at; i++) i},
        ),
      ],
      variables: {
        'range left': left,
        'range right': right,
        'sum': complete ? prefix[right + 1] - prefix[left] : '—',
      },
      output: complete ? [prefix[right + 1] - prefix[left]] : [],
      result: complete
          ? 'Range sum = ${prefix[right + 1]} − ${prefix[left]} = ${prefix[right + 1] - prefix[left]}.'
          : '',
    ),
  );
  snap(0, 'Prefix[0] = 0: a sum before any element.');
  for (var i = 0; i < input.length; i++) {
    prefix[i + 1] = prefix[i] + input[i];
    snap(i + 1, 'Prefix[${i + 1}] = ${prefix[i]} + ${input[i]}.');
  }
  snap(
    input.length,
    'Subtract the prefix before the range from the prefix after it.',
    complete: true,
  );
  return frames;
}

List<SequenceTrace> productExceptSelf(List<int> input) {
  final out = List<int>.filled(input.length, 1);
  var product = 1;
  final frames = <SequenceTrace>[];
  void snap(int at, String pass, String caption, {bool complete = false}) =>
      frames.add(
        SequenceTrace(
          caption: caption,
          rows: [
            _row('Input', input, pointers: {'scan': at}),
            _row('Products', out, active: {at}),
          ],
          variables: {'pass': pass, 'running product': product},
          output: complete ? out : [],
          result: complete
              ? 'Products excluding each position: ${out.join(', ')}'
              : '',
        ),
      );
  snap(
    -1,
    'prefix',
    'Multiply prefixes and suffixes; division is unnecessary.',
  );
  for (var i = 0; i < input.length; i++) {
    out[i] = product;
    product *= input[i];
    snap(i, 'prefix', 'Save the product strictly to the left of index $i.');
  }
  product = 1;
  for (var i = input.length - 1; i >= 0; i--) {
    out[i] *= product;
    product *= input[i];
    snap(
      i,
      'suffix',
      'Multiply by the product strictly to the right of index $i.',
    );
  }
  snap(
    -1,
    'complete',
    'Each output excludes exactly its own input element.',
    complete: true,
  );
  return frames;
}

List<SequenceTrace> trappedRainwater(List<int> input) {
  if (input.any((v) => v < 0)) {
    throw ArgumentError('Heights must be nonnegative.');
  }
  final water = List<int>.filled(input.length, 0);
  var left = 0, right = input.length - 1, leftMax = 0, rightMax = 0, total = 0;
  final frames = <SequenceTrace>[];
  void snap(String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Heights',
          input,
          pointers: {'left': left, 'right': right},
          lo: left,
          hi: right,
        ),
        _row('Water', water),
      ],
      variables: {
        'left max': leftMax,
        'right max': rightMax,
        'total water': total,
      },
      output: complete ? [total] : [],
      result: complete ? 'Trapped water: $total units.' : '',
    ),
  );
  snap('The lower boundary determines the water level on its side.');
  while (left <= right) {
    if (leftMax <= rightMax) {
      leftMax = math.max(leftMax, input[left]);
      water[left] = leftMax - input[left];
      total += water[left];
      snap(
        'At index $left, left boundary $leftMax traps ${water[left]} units.',
      );
      left++;
    } else {
      rightMax = math.max(rightMax, input[right]);
      water[right] = rightMax - input[right];
      total += water[right];
      snap(
        'At index $right, right boundary $rightMax traps ${water[right]} units.',
      );
      right--;
    }
  }
  snap('Every cell has a determined water level.', complete: true);
  return frames;
}

List<SequenceTrace> majorityVote(List<int> input) {
  int? candidate;
  var balance = 0, count = 0;
  final frames = <SequenceTrace>[];
  void snap(int at, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Votes', input, pointers: {'scan': at}, active: {at}),
      ],
      variables: {
        'candidate': candidate ?? '—',
        'balance': balance,
        'verified count': count,
      },
      output: complete && count > input.length ~/ 2 ? [candidate!] : [],
      result: complete
          ? count > input.length ~/ 2
                ? 'Majority: $candidate ($count of ${input.length}).'
                : 'No strict majority exists.'
          : '',
    ),
  );
  snap(-1, 'Cancel pairs of different values to find a candidate.');
  for (var i = 0; i < input.length; i++) {
    if (balance == 0) candidate = input[i];
    balance += input[i] == candidate ? 1 : -1;
    snap(
      i,
      input[i] == candidate
          ? 'Support the candidate; increase balance.'
          : 'Cancel one candidate vote against a different value.',
    );
  }
  for (var i = 0; i < input.length; i++) {
    if (input[i] == candidate) count++;
    snap(i, 'Verify the candidate: it must occur more than half the time.');
  }
  snap(-1, 'Verification prevents a false majority result.', complete: true);
  return frames;
}

List<SequenceTrace> nextGreaterElements(List<int> input) {
  final stack = <int>[];
  final out = List<String>.filled(input.length, '—');
  final frames = <SequenceTrace>[];
  void snap(int at, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Input', input, pointers: {'scan': at}),
        _row('Index stack', stack, pointers: {'top': stack.length - 1}),
        _row('Next greater', out),
      ],
      variables: {'pending': stack.length},
      output: complete ? out : [],
      result: complete
          ? 'Next greater values: ${out.join(', ')} (— means none).'
          : '',
    ),
  );
  snap(-1, 'Keep unresolved indices in a decreasing-value stack.');
  for (var i = 0; i < input.length; i++) {
    while (stack.isNotEmpty && input[stack.last] < input[i]) {
      final at = stack.removeLast();
      out[at] = '${input[i]}';
      snap(
        i,
        '${input[i]} is the first greater value to the right of index $at; pop it.',
      );
    }
    stack.add(i);
    snap(i, 'Push index $i; it still needs a greater value.');
  }
  snap(
    -1,
    'Indices left in the stack have no greater value on their right.',
    complete: true,
  );
  return frames;
}

List<SequenceTrace> balancedBrackets(String input) {
  const pairs = {')': '(', ']': '[', '}': '{'};
  final chars = input.split(''), stack = <String>[];
  final frames = <SequenceTrace>[];
  void snap(int at, String caption, {bool? answer}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Expression', chars, pointers: {'read': at}),
        _row('Open stack', stack, pointers: {'top': stack.length - 1}),
      ],
      variables: {'unclosed': stack.length},
      output: answer == null ? [] : [answer],
      result: answer == null
          ? ''
          : answer
          ? 'Brackets are balanced.'
          : 'Brackets are not balanced.',
    ),
  );
  snap(-1, 'An opening bracket pushes; a closing bracket must match the top.');
  for (var i = 0; i < chars.length; i++) {
    final c = chars[i];
    if (pairs.values.contains(c)) {
      stack.add(c);
      snap(i, 'Push opening bracket $c.');
    } else if (pairs.containsKey(c)) {
      if (stack.isEmpty || stack.last != pairs[c]) {
        snap(
          i,
          '$c does not match the most recent opening bracket.',
          answer: false,
        );
        return frames;
      }
      stack.removeLast();
      snap(i, 'Match $c with ${pairs[c]} and pop the opening bracket.');
    } else {
      snap(i, 'Ignore the non-bracket character $c.');
    }
  }
  snap(
    -1,
    stack.isEmpty
        ? 'The stack is empty after reading the expression.'
        : 'Some opening brackets were never closed.',
    answer: stack.isEmpty,
  );
  return frames;
}

List<String> _tokens(String expression) {
  final tokens = <String>[];
  var end = 0;
  for (final match in RegExp(
    r'\d+|[A-Za-z]+|[()+*/^\-]',
  ).allMatches(expression)) {
    if (expression.substring(end, match.start).trim().isNotEmpty) {
      throw ArgumentError('Unsupported expression token.');
    }
    tokens.add(match.group(0)!);
    end = match.end;
  }
  if (expression.substring(end).trim().isNotEmpty) {
    throw ArgumentError('Unsupported expression token.');
  }
  return tokens;
}

List<SequenceTrace> shuntingYard(String expression) {
  final tokens = _tokens(expression), stack = <String>[], out = <String>[];
  const precedence = {'+': 1, '-': 1, '*': 2, '/': 2, '^': 3};
  final frames = <SequenceTrace>[];
  var needsOperand = true;
  void snap(int at, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Infix', tokens, pointers: {'read': at}),
        _row('Operators', stack, pointers: {'top': stack.length - 1}),
        _row('Postfix', out),
      ],
      variables: {'rule': 'precedence + associativity'},
      output: complete ? out : [],
      result: complete ? 'Postfix: ${out.join(' ')}' : '',
    ),
  );
  snap(-1, 'Send operands to output; defer operators on a stack.');
  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (RegExp(r'^[A-Za-z0-9]+$').hasMatch(token)) {
      if (!needsOperand) throw ArgumentError('An operator is missing.');
      out.add(token);
      needsOperand = false;
      snap(i, 'Append operand $token directly to output.');
    } else if (token == '(') {
      if (!needsOperand) {
        throw ArgumentError('An operator is missing before (.');
      }
      stack.add(token);
      snap(i, 'Push a parenthesis barrier.');
    } else if (token == ')') {
      if (needsOperand) throw ArgumentError('Expected an operand before ).');
      while (stack.isNotEmpty && stack.last != '(') {
        out.add(stack.removeLast());
        snap(i, 'Pop an operator inside the parentheses.');
      }
      if (stack.isEmpty) throw ArgumentError('Unmatched closing parenthesis.');
      stack.removeLast();
      snap(i, 'Discard the matched parentheses.');
    } else {
      if (needsOperand) {
        throw ArgumentError('Only binary operators are supported.');
      }
      while (stack.isNotEmpty &&
          stack.last != '(' &&
          (precedence[stack.last]! > precedence[token]! ||
              (precedence[stack.last] == precedence[token] && token != '^'))) {
        out.add(stack.removeLast());
        snap(i, 'Pop an operator that must execute before $token.');
      }
      stack.add(token);
      needsOperand = true;
      snap(i, 'Push $token; exponentiation associates to the right.');
    }
  }
  if (needsOperand && tokens.isNotEmpty) {
    throw ArgumentError('Expression ends before an operand.');
  }
  while (stack.isNotEmpty) {
    if (stack.last == '(') {
      throw ArgumentError('Unmatched opening parenthesis.');
    }
    out.add(stack.removeLast());
    snap(-1, 'Drain the remaining operators in stack order.');
  }
  snap(-1, 'Conversion is complete.', complete: true);
  return frames;
}

List<SequenceTrace> evaluatePostfix(List<String> tokens) {
  final stack = <double>[];
  final frames = <SequenceTrace>[];
  String number(double value) =>
      value == value.truncateToDouble() ? value.toStringAsFixed(0) : '$value';
  void snap(int at, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Postfix', tokens, pointers: {'read': at}),
        _row(
          'Value stack',
          stack.map(number),
          pointers: {'top': stack.length - 1},
        ),
      ],
      variables: {'stack size': stack.length},
      output: complete ? [number(stack.single)] : [],
      result: complete ? 'Expression value: ${number(stack.single)}' : '',
    ),
  );
  snap(-1, 'Push numbers; each binary operator pops right, then left.');
  for (var i = 0; i < tokens.length; i++) {
    final operand = double.tryParse(tokens[i]);
    if (operand != null && operand.isFinite) {
      stack.add(operand);
      snap(i, 'Push ${tokens[i]}.');
      continue;
    }
    if (!['+', '-', '*', '/', '^'].contains(tokens[i]) || stack.length < 2) {
      throw ArgumentError('Malformed postfix expression.');
    }
    final right = stack.removeLast(), left = stack.removeLast();
    if (tokens[i] == '/' && right == 0) {
      throw ArgumentError('Division by zero.');
    }
    final value = switch (tokens[i]) {
      '+' => left + right,
      '-' => left - right,
      '*' => left * right,
      '/' => left / right,
      _ => math.pow(left, right).toDouble(),
    };
    if (!value.isFinite) throw ArgumentError('Result is not finite.');
    stack.add(value);
    snap(
      i,
      '${number(left)} ${tokens[i]} ${number(right)} = ${number(value)}; push the result.',
    );
  }
  if (stack.length != 1) {
    throw ArgumentError('Postfix evaluation must end with one value.');
  }
  snap(-1, 'The remaining stack value is the answer.', complete: true);
  return frames;
}

List<SequenceTrace> runLengthEncode(String input) {
  final chars = input.runes.map(String.fromCharCode).toList(), out = <String>[];
  final frames = <SequenceTrace>[];
  var start = 0, count = 0;
  void snap(int at, String caption, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Input',
          chars,
          pointers: {'start': start, 'scan': at},
          lo: start,
          hi: at,
        ),
        _row('Runs', out),
      ],
      variables: {'run count': count},
      output: complete ? out : [],
      result: complete ? 'Character:count runs: ${out.join('  ')}' : '',
    ),
  );
  snap(-1, 'Count consecutive equal characters; emit each run once.');
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && chars[i] != chars[i - 1]) {
      out.add('${chars[i - 1]}:$count');
      start = i;
      count = 0;
      snap(i, 'A new character ends the previous run.');
    }
    count++;
    snap(i, 'Extend the run of ${chars[i]} to $count.');
  }
  if (chars.isNotEmpty) out.add('${chars.last}:$count');
  snap(chars.length - 1, 'Flush the final run.', complete: true);
  return frames;
}

List<SequenceTrace> manacherPalindrome(String input) {
  final chars = input.runes.toList();
  // Negative separator cannot collide with any Unicode scalar value.
  final transformed = <int>[-1];
  for (final c in chars) {
    transformed.addAll([c, -1]);
  }
  final radius = List<int>.filled(transformed.length, 0);
  var center = 0, right = 0, bestCenter = 0, bestRadius = 0;
  final frames = <SequenceTrace>[];
  void snap(int at, String caption, {bool complete = false}) {
    final answer = String.fromCharCodes(
      chars.skip((bestCenter - bestRadius) ~/ 2).take(bestRadius),
    );
    frames.add(
      SequenceTrace(
        caption: caption,
        rows: [
          _row(
            'Separated',
            transformed.map((c) => c == -1 ? '·' : String.fromCharCode(c)),
            pointers: {'scan': at, 'center': center, 'right': right},
            lo: at < 0 ? null : at - radius[at],
            hi: at < 0 ? null : at + radius[at],
          ),
          _row('Radii', radius, active: {at}),
        ],
        variables: {
          'center': center,
          'right reach': right,
          'best length': bestRadius,
        },
        output: complete ? [answer] : [],
        result: complete
            ? 'Longest palindrome: “$answer” ($bestRadius characters).'
            : '',
      ),
    );
  }

  snap(-1, 'Separators let odd and even palindromes use the same radius rule.');
  for (var i = 0; i < transformed.length; i++) {
    if (i < right) {
      radius[i] = math.min(right - i, radius[2 * center - i]);
      snap(i, 'Reuse the mirrored radius, capped by the known right boundary.');
    }
    while (i - radius[i] - 1 >= 0 &&
        i + radius[i] + 1 < transformed.length &&
        transformed[i - radius[i] - 1] == transformed[i + radius[i] + 1]) {
      radius[i]++;
      snap(i, 'Matching outer characters expand this palindrome.');
    }
    if (i + radius[i] > right) {
      center = i;
      right = i + radius[i];
    }
    if (radius[i] > bestRadius) {
      bestRadius = radius[i];
      bestCenter = i;
    }
    snap(i, 'Update the rightmost palindrome and the best radius.');
  }
  snap(
    -1,
    'Recover the longest palindrome from its center and radius.',
    complete: true,
  );
  return frames;
}

List<SequenceTrace> equalRangeSearch(List<int> input, int target) {
  _sorted(input);
  final frames = <SequenceTrace>[];
  var lower = 0, upper = 0;
  void snap(
    int lo,
    int hi,
    int mid,
    String pass,
    String caption, {
    bool complete = false,
  }) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Sorted input',
          input,
          pointers: {'lo': lo, 'hi−1': hi - 1, 'mid': mid},
          lo: lo,
          hi: hi - 1,
        ),
      ],
      variables: {
        'target': target,
        'pass': pass,
        'lo': lo,
        'hi (exclusive)': hi,
      },
      output: complete ? [lower, upper] : [],
      result: complete
          ? 'Equal range [$lower, $upper): ${upper - lower} matches.'
          : '',
    ),
  );
  snap(
    0,
    input.length,
    -1,
    'lower bound',
    'Find the first position ≥ target, then the first position > target.',
  );
  for (final isUpper in [false, true]) {
    var lo = 0, hi = input.length;
    while (lo < hi) {
      final mid = lo + (hi - lo) ~/ 2;
      snap(
        lo,
        hi,
        mid,
        isUpper ? 'upper bound' : 'lower bound',
        'Inspect index $mid inside the half-open search interval.',
      );
      if (input[mid] < target || (isUpper && input[mid] == target)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (isUpper) {
      upper = lo;
    } else {
      lower = lo;
    }
    snap(
      lo,
      hi,
      -1,
      isUpper ? 'upper bound' : 'lower bound',
      'The insertion boundary is $lo.',
    );
  }
  snap(
    lower,
    upper,
    -1,
    'complete',
    'The two boundaries delimit every occurrence.',
    complete: true,
  );
  return frames;
}

List<SequenceTrace> naturalMergeSort(List<int> input) {
  final a = [...input];
  final frames = <SequenceTrace>[];
  var pass = 0;
  void snap(
    String caption, {
    List<int> aux = const [],
    List<int> boundaries = const [],
    int? lo,
    int? hi,
    bool complete = false,
  }) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Array', a, lo: lo, hi: hi),
        _row('Run starts', boundaries),
        _row('Merge buffer', aux),
      ],
      variables: {'pass': pass},
      output: complete ? a : [],
      result: complete
          ? 'Sorted by merging existing runs: ${a.join(', ')}'
          : '',
    ),
  );
  snap('Discover ascending runs already present in the input.');
  while (a.length > 1) {
    final boundaries = [0];
    for (var i = 1; i < a.length; i++) {
      if (a[i] < a[i - 1]) boundaries.add(i);
    }
    snap(
      'Found ${boundaries.length} naturally sorted runs.',
      boundaries: boundaries,
    );
    if (boundaries.length == 1) break;
    boundaries.add(a.length);
    pass++;
    for (var run = 0; run + 2 < boundaries.length; run += 2) {
      final start = boundaries[run],
          middle = boundaries[run + 1],
          end = boundaries[run + 2];
      var left = start, right = middle;
      final merged = <int>[];
      while (left < middle || right < end) {
        if (right == end || (left < middle && a[left] <= a[right])) {
          merged.add(a[left++]);
        } else {
          merged.add(a[right++]);
        }
        snap(
          'Take the smaller front value from the two adjacent runs.',
          aux: merged,
          boundaries: boundaries,
          lo: start,
          hi: end - 1,
        );
      }
      a.setRange(start, end, merged);
      snap(
        'Write the merged run back.',
        aux: merged,
        boundaries: boundaries,
        lo: start,
        hi: end - 1,
      );
    }
  }
  snap('One ascending run remains.', complete: true);
  return frames;
}

List<SequenceTrace> binaryInsertionSort(List<int> input) {
  final a = [...input];
  final frames = <SequenceTrace>[];
  void snap(
    String caption,
    int at,
    int lo,
    int hi,
    int? key, {
    bool complete = false,
  }) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row(
          'Array',
          a,
          pointers: {'insert': lo, 'source': at},
          lo: lo,
          hi: hi - 1,
          done: {for (var i = 0; i < at; i++) i},
        ),
      ],
      variables: {'held value': key ?? '—', 'lo': lo, 'hi (exclusive)': hi},
      output: complete ? a : [],
      result: complete ? 'Sorted: ${a.join(', ')}' : '',
    ),
  );
  snap(
    'Use binary search to locate each insertion in the sorted prefix.',
    0,
    0,
    0,
    null,
  );
  for (var i = 1; i < a.length; i++) {
    final key = a[i];
    var lo = 0, hi = i;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      snap(
        'Compare held $key with ${a[mid]} at midpoint $mid.',
        i,
        lo,
        hi,
        key,
      );
      if (a[mid] <= key) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    for (var j = i; j > lo; j--) {
      a[j] = a[j - 1];
      snap('Shift ${a[j]} right to open the insertion slot.', i, lo, lo, key);
    }
    a[lo] = key;
    snap(
      'Insert $key after any equal values, preserving stability.',
      i + 1,
      lo,
      lo,
      key,
    );
  }
  snap(
    'The sorted prefix covers the array.',
    a.length,
    0,
    0,
    null,
    complete: true,
  );
  return frames;
}

List<SequenceTrace> tournamentSort(List<int> input) {
  var leafCount = 1;
  while (leafCount < input.length) {
    leafCount *= 2;
  }
  final winners = List<int?>.filled(leafCount * 2, null), out = <int>[];
  final frames = <SequenceTrace>[];
  int? winner(int? a, int? b) => a == null
      ? b
      : b == null
      ? a
      : input[a] <= input[b]
      ? a
      : b;
  void snap(String caption, int at, {bool complete = false}) => frames.add(
    SequenceTrace(
      caption: caption,
      rows: [
        _row('Original', input, pointers: {'winner': winners[1] ?? -1}),
        _row(
          'Tournament',
          winners
              .skip(1)
              .map((index) => index == null ? '—' : '${input[index]}@$index'),
          active: {at - 1},
        ),
        _row('Output', out),
      ],
      variables: {
        'emitted': out.length,
        'root winner': winners[1] == null ? '—' : input[winners[1]!],
      },
      output: complete ? out : [],
      result: complete ? 'Sorted tournament winners: ${out.join(', ')}' : '',
    ),
  );
  snap(
    'Leaves hold input positions; each match promotes the smaller value.',
    0,
  );
  for (var i = 0; i < input.length; i++) {
    winners[leafCount + i] = i;
  }
  for (var node = leafCount - 1; node >= 1; node--) {
    winners[node] = winner(winners[node * 2], winners[node * 2 + 1]);
    snap('Promote the winner of match $node.', node);
  }
  while (winners[1] != null) {
    final index = winners[1]!;
    out.add(input[index]);
    var node = leafCount + index;
    winners[node] = null;
    snap(
      'Emit ${input[index]} and retire its leaf; duplicates remain independent.',
      node,
    );
    while (node > 1) {
      node ~/= 2;
      winners[node] = winner(winners[node * 2], winners[node * 2 + 1]);
      snap('Replay only the affected path to the root.', node);
    }
  }
  snap('Every input position has won exactly once.', 0, complete: true);
  return frames;
}
