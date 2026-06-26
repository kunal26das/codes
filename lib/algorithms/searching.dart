import 'dart:math';

import '../models/frames.dart';

/// Linear scan over an (unsorted) array.
List<ArrayFrame> linearSearch(List<int> a, int target) {
  final frames = <ArrayFrame>[
    ArrayFrame(values: a, target: target, caption: 'Scan left to right for $target.'),
  ];
  for (var i = 0; i < a.length; i++) {
    frames.add(ArrayFrame(
      values: a,
      comparing: {i},
      target: target,
      caption: 'Index $i holds ${a[i]}.',
    ));
    if (a[i] == target) {
      frames.add(ArrayFrame(
        values: a,
        done: {i},
        target: target,
        caption: 'Match — found $target at index $i.',
      ));
      return frames;
    }
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}

/// Binary search over a sorted array.
List<ArrayFrame> binarySearch(List<int> a, int target) {
  var lo = 0, hi = a.length - 1;
  final frames = <ArrayFrame>[
    ArrayFrame(
      values: a,
      windowLo: lo,
      windowHi: hi,
      target: target,
      caption: 'The whole sorted array is the search window.',
    ),
  ];
  while (lo <= hi) {
    final mid = (lo + hi) ~/ 2;
    frames.add(ArrayFrame(
      values: a,
      windowLo: lo,
      windowHi: hi,
      comparing: {mid},
      target: target,
      caption: 'Midpoint index $mid holds ${a[mid]}.',
    ));
    if (a[mid] == target) {
      frames.add(ArrayFrame(values: a, done: {mid}, target: target, caption: 'Found $target at index $mid.'));
      return frames;
    }
    if (a[mid] < target) {
      lo = mid + 1;
      frames.add(ArrayFrame(
        values: a,
        windowLo: lo,
        windowHi: hi,
        target: target,
        caption: '${a[mid]} < $target — discard the left half.',
      ));
    } else {
      hi = mid - 1;
      frames.add(ArrayFrame(
        values: a,
        windowLo: lo,
        windowHi: hi,
        target: target,
        caption: '${a[mid]} > $target — discard the right half.',
      ));
    }
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}

/// Interpolation search over a sorted array — probes a position estimated from
/// the target's value relative to the window's endpoints.
List<ArrayFrame> interpolationSearch(List<int> a, int target) {
  var lo = 0, hi = a.length - 1;
  final frames = <ArrayFrame>[
    ArrayFrame(
      values: a,
      windowLo: lo,
      windowHi: hi,
      target: target,
      caption: 'Estimate where $target should sit by interpolating across the window.',
    ),
  ];
  while (lo <= hi && target >= a[lo] && target <= a[hi]) {
    final pos = (a[hi] == a[lo])
        ? lo
        : lo + ((target - a[lo]) * (hi - lo) ~/ (a[hi] - a[lo]));
    frames.add(ArrayFrame(
      values: a,
      windowLo: lo,
      windowHi: hi,
      comparing: {pos},
      target: target,
      caption: 'Probe index $pos (holds ${a[pos]}).',
    ));
    if (a[pos] == target) {
      frames.add(ArrayFrame(values: a, done: {pos}, target: target, caption: 'Found $target at index $pos.'));
      return frames;
    }
    if (a[pos] < target) {
      lo = pos + 1;
      frames.add(ArrayFrame(
        values: a,
        windowLo: lo,
        windowHi: hi,
        target: target,
        caption: '${a[pos]} < $target — search to the right.',
      ));
    } else {
      hi = pos - 1;
      frames.add(ArrayFrame(
        values: a,
        windowLo: lo,
        windowHi: hi,
        target: target,
        caption: '${a[pos]} > $target — search to the left.',
      ));
    }
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}

String _ordinal(int k) {
  if (k % 100 >= 11 && k % 100 <= 13) return '${k}th';
  switch (k % 10) {
    case 1:
      return '${k}st';
    case 2:
      return '${k}nd';
    case 3:
      return '${k}rd';
    default:
      return '${k}th';
  }
}

/// Quickselect — finds the [k]-th smallest value (1-based) using Lomuto
/// partitioning, recursing into only the side that contains the target rank.
List<ArrayFrame> quickSelect(List<int> input, int k) {
  final a = [...input];
  final target = k - 1; // 0-based index in the sorted order
  final done = <int>{};
  final frames = <ArrayFrame>[
    ArrayFrame(values: [...a], caption: 'Find the ${_ordinal(k)} smallest value.'),
  ];
  var lo = 0, hi = a.length - 1;
  while (lo <= hi) {
    final pivot = a[hi];
    var i = lo;
    frames.add(ArrayFrame(
      values: [...a],
      pivot: hi,
      windowLo: lo,
      windowHi: hi,
      done: {...done},
      caption: 'Partition indices $lo–$hi around pivot $pivot.',
    ));
    for (var j = lo; j < hi; j++) {
      frames.add(ArrayFrame(
        values: [...a],
        comparing: {j},
        pivot: hi,
        windowLo: lo,
        windowHi: hi,
        done: {...done},
        caption: 'Is ${a[j]} < pivot $pivot?',
      ));
      if (a[j] < pivot) {
        final t = a[i];
        a[i] = a[j];
        a[j] = t;
        if (i != j) {
          frames.add(ArrayFrame(
            values: [...a],
            active: {i, j},
            pivot: hi,
            windowLo: lo,
            windowHi: hi,
            done: {...done},
            caption: 'Yes — swap it into the smaller side.',
          ));
        }
        i++;
      }
    }
    final t = a[i];
    a[i] = a[hi];
    a[hi] = t;
    frames.add(ArrayFrame(
      values: [...a],
      active: {i},
      windowLo: lo,
      windowHi: hi,
      done: {...done},
      caption: 'The pivot lands at its sorted index, $i.',
    ));
    if (i == target) {
      done.add(i);
      frames.add(ArrayFrame(
        values: [...a],
        done: {...done},
        caption: 'Index $i is the answer: ${a[i]} is the ${_ordinal(k)} smallest.',
      ));
      return frames;
    } else if (i < target) {
      lo = i + 1;
      frames.add(ArrayFrame(
        values: [...a],
        windowLo: lo,
        windowHi: hi,
        done: {...done},
        caption: 'Rank $k is to the right — recurse on indices $lo–$hi.',
      ));
    } else {
      hi = i - 1;
      frames.add(ArrayFrame(
        values: [...a],
        windowLo: lo,
        windowHi: hi,
        done: {...done},
        caption: 'Rank $k is to the left — recurse on indices $lo–$hi.',
      ));
    }
  }
  return frames;
}

/// Jump search over a sorted array — leap forward in fixed-size blocks, then
/// scan the block that must contain the target.
List<ArrayFrame> jumpSearch(List<int> a, int target) {
  final n = a.length;
  final step = max(1, sqrt(n).floor());
  final frames = <ArrayFrame>[
    ArrayFrame(values: a, target: target, windowLo: 0, windowHi: n - 1, caption: 'Jump ahead in blocks of $step to bracket $target.'),
  ];
  var prev = 0;
  var idx = step - 1;
  while (idx < n && a[idx] < target) {
    frames.add(ArrayFrame(values: a, comparing: {idx}, target: target, caption: '${a[idx]} < $target — jump to the next block.'));
    prev = idx + 1;
    idx += step;
  }
  final hi = min(idx, n - 1);
  frames.add(ArrayFrame(values: a, windowLo: prev, windowHi: hi, target: target, caption: 'Target must be in block [$prev, $hi] — scan it.'));
  for (var i = prev; i <= hi; i++) {
    frames.add(ArrayFrame(values: a, comparing: {i}, windowLo: prev, windowHi: hi, target: target, caption: 'Check ${a[i]}.'));
    if (a[i] == target) {
      frames.add(ArrayFrame(values: a, done: {i}, target: target, caption: 'Found $target at index $i.'));
      return frames;
    }
    if (a[i] > target) break;
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}

/// Ternary search over a sorted array — split the range into thirds each step.
List<ArrayFrame> ternarySearch(List<int> a, int target) {
  var lo = 0, hi = a.length - 1;
  final frames = <ArrayFrame>[
    ArrayFrame(values: a, windowLo: lo, windowHi: hi, target: target, caption: 'Split the range into thirds each step.'),
  ];
  while (lo <= hi) {
    final third = (hi - lo) ~/ 3;
    final m1 = lo + third;
    final m2 = hi - third;
    frames.add(ArrayFrame(values: a, windowLo: lo, windowHi: hi, comparing: {m1, m2}, target: target, caption: 'Probe ${a[m1]} and ${a[m2]}.'));
    if (a[m1] == target) {
      frames.add(ArrayFrame(values: a, done: {m1}, target: target, caption: 'Found $target at index $m1.'));
      return frames;
    }
    if (a[m2] == target) {
      frames.add(ArrayFrame(values: a, done: {m2}, target: target, caption: 'Found $target at index $m2.'));
      return frames;
    }
    if (target < a[m1]) {
      hi = m1 - 1;
      frames.add(ArrayFrame(values: a, windowLo: lo, windowHi: hi, target: target, caption: '$target < ${a[m1]} — keep the first third.'));
    } else if (target > a[m2]) {
      lo = m2 + 1;
      frames.add(ArrayFrame(values: a, windowLo: lo, windowHi: hi, target: target, caption: '$target > ${a[m2]} — keep the last third.'));
    } else {
      lo = m1 + 1;
      hi = m2 - 1;
      frames.add(ArrayFrame(values: a, windowLo: lo, windowHi: hi, target: target, caption: '$target is in the middle third.'));
    }
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}

/// Exponential search over a sorted array — double a bound until it passes the
/// target, then binary search within the last interval.
List<ArrayFrame> exponentialSearch(List<int> a, int target) {
  final n = a.length;
  final frames = <ArrayFrame>[
    ArrayFrame(values: a, target: target, caption: 'Double a bound until it passes $target.'),
  ];
  if (a[0] == target) {
    frames.add(ArrayFrame(values: a, done: {0}, target: target, caption: 'Found $target at index 0.'));
    return frames;
  }
  var bound = 1;
  while (bound < n && a[bound] < target) {
    frames.add(ArrayFrame(values: a, comparing: {bound}, target: target, caption: '${a[bound]} < $target — double the bound to ${bound * 2}.'));
    bound *= 2;
  }
  var l = bound ~/ 2;
  var h = min(bound, n - 1);
  frames.add(ArrayFrame(values: a, windowLo: l, windowHi: h, target: target, caption: 'Binary search within [$l, $h].'));
  while (l <= h) {
    final mid = (l + h) ~/ 2;
    frames.add(ArrayFrame(values: a, windowLo: l, windowHi: h, comparing: {mid}, target: target, caption: 'Midpoint ${a[mid]}.'));
    if (a[mid] == target) {
      frames.add(ArrayFrame(values: a, done: {mid}, target: target, caption: 'Found $target at index $mid.'));
      return frames;
    }
    if (a[mid] < target) {
      l = mid + 1;
    } else {
      h = mid - 1;
    }
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}

/// Fibonacci search over a sorted array — uses Fibonacci numbers to split the
/// range into unequal parts, avoiding division.
List<ArrayFrame> fibonacciSearch(List<int> a, int target) {
  final n = a.length;
  var fbMM2 = 0, fbMM1 = 1, fbM = fbMM2 + fbMM1;
  while (fbM < n) {
    fbMM2 = fbMM1;
    fbMM1 = fbM;
    fbM = fbMM2 + fbMM1;
  }
  var offset = -1;
  final frames = <ArrayFrame>[
    ArrayFrame(values: a, target: target, windowLo: 0, windowHi: n - 1, caption: 'Use Fibonacci numbers to choose probe points.'),
  ];
  while (fbM > 1) {
    final i = (offset + fbMM2).clamp(0, n - 1);
    frames.add(ArrayFrame(values: a, comparing: {i}, windowLo: (offset + 1).clamp(0, n - 1), windowHi: n - 1, target: target, caption: 'Probe index $i (holds ${a[i]}).'));
    if (a[i] < target) {
      fbM = fbMM1;
      fbMM1 = fbMM2;
      fbMM2 = fbM - fbMM1;
      offset = i;
    } else if (a[i] > target) {
      fbM = fbMM2;
      fbMM1 = fbMM1 - fbMM2;
      fbMM2 = fbM - fbMM1;
    } else {
      frames.add(ArrayFrame(values: a, done: {i}, target: target, caption: 'Found $target at index $i.'));
      return frames;
    }
  }
  if (fbMM1 == 1 && offset + 1 < n && a[offset + 1] == target) {
    frames.add(ArrayFrame(values: a, done: {offset + 1}, target: target, caption: 'Found $target at index ${offset + 1}.'));
    return frames;
  }
  frames.add(ArrayFrame(values: a, target: target, caption: '$target is not in the array.'));
  return frames;
}
