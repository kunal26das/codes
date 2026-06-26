import '../models/frames.dart';

/// Array traversal — visit each element from left to right.
List<ArrayFrame> arrayTraversal(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Walk the array from the first index to the last.')];
  final seen = <int>{};
  for (var i = 0; i < a.length; i++) {
    frames.add(ArrayFrame(values: [...a], comparing: {i}, done: {...seen}, caption: 'Visit a[$i] = ${a[i]}.'));
    seen.add(i);
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < a.length; k++) k}, caption: 'Traversal complete — every element read once.'));
  return frames;
}

/// Array insertion — insert a value at an index by shifting the tail right.
List<ArrayFrame> arrayInsertion(List<int> input, {int at = 2, int value = 42}) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Insert $value at index $at by shifting elements right.')];
  a.add(a.last); // grow by one (placeholder)
  for (var i = a.length - 1; i > at; i--) {
    a[i] = a[i - 1];
    frames.add(ArrayFrame(values: [...a], active: {i}, caption: 'Shift a[${i - 1}] → a[$i].'));
  }
  a[at] = value;
  frames.add(ArrayFrame(values: [...a], active: {at}, caption: 'Place $value at index $at.'));
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < a.length; k++) k}, caption: 'Inserted — array grew by one.'));
  return frames;
}

/// Array deletion — remove the element at an index by shifting the tail left.
List<ArrayFrame> arrayDeletion(List<int> input, {int at = 2}) {
  final a = [...input];
  final removed = a[at];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], active: {at}, caption: 'Delete a[$at] = $removed by shifting elements left.')];
  for (var i = at; i < a.length - 1; i++) {
    a[i] = a[i + 1];
    frames.add(ArrayFrame(values: [...a], active: {i}, caption: 'Shift a[${i + 1}] → a[$i].'));
  }
  a.removeLast();
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < a.length; k++) k}, caption: 'Deleted — array shrank by one.'));
  return frames;
}

/// Maximum contiguous sub-array (Kadane) — track the best running sum and the
/// window that produced it.
List<ArrayFrame> contiguousSubarray(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Find the contiguous block with the largest sum.')];
  var best = a[0], cur = a[0], start = 0, bestLo = 0, bestHi = 0;
  for (var i = 1; i < a.length; i++) {
    if (cur < 0) {
      cur = a[i];
      start = i;
    } else {
      cur += a[i];
    }
    if (cur > best) {
      best = cur;
      bestLo = start;
      bestHi = i;
    }
    frames.add(ArrayFrame(
      values: [...a],
      active: {i},
      windowLo: bestLo,
      windowHi: bestHi,
      caption: 'a[$i]=${a[i]}: running sum $cur, best $best.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = bestLo; k <= bestHi; k++) k},
    windowLo: bestLo,
    windowHi: bestHi,
    caption: 'Largest contiguous sum is $best over a[$bestLo..$bestHi].',
  ));
  return frames;
}

/// Maximum non-contiguous sub-sequence sum — pick every positive element
/// (order need not be contiguous).
List<ArrayFrame> nonContiguousSubarray(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Pick any elements (not necessarily adjacent) for the largest sum.')];
  final chosen = <int>{};
  var sum = 0;
  for (var i = 0; i < a.length; i++) {
    if (a[i] > 0) {
      chosen.add(i);
      sum += a[i];
      frames.add(ArrayFrame(values: [...a], active: {i}, done: {...chosen}, caption: 'a[$i]=${a[i]} > 0 — take it; sum = $sum.'));
    } else {
      frames.add(ArrayFrame(values: [...a], comparing: {i}, done: {...chosen}, caption: 'a[$i]=${a[i]} ≤ 0 — skip it.'));
    }
  }
  if (chosen.isEmpty) {
    final mi = _argmax(a);
    chosen.add(mi);
    sum = a[mi];
  }
  frames.add(ArrayFrame(values: [...a], done: {...chosen}, caption: 'Best non-contiguous sum is $sum.'));
  return frames;
}

int _argmax(List<int> a) {
  var best = 0;
  for (var i = 1; i < a.length; i++) {
    if (a[i] > a[best]) best = i;
  }
  return best;
}

/// Array reversal — swap elements from both ends moving inward.
List<ArrayFrame> arrayReversal(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Reverse the array by swapping the two ends inward.')];
  var lo = 0, hi = a.length - 1;
  while (lo < hi) {
    frames.add(ArrayFrame(values: [...a], comparing: {lo, hi}, caption: 'Swap a[$lo]=${a[lo]} and a[$hi]=${a[hi]}.'));
    final t = a[lo];
    a[lo] = a[hi];
    a[hi] = t;
    frames.add(ArrayFrame(values: [...a], active: {lo, hi}, caption: 'Swapped.'));
    lo++;
    hi--;
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < a.length; k++) k}, caption: 'Reversed.'));
  return frames;
}
