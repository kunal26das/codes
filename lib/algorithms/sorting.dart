import '../models/frames.dart';

/// Each function below replays a classic sort as a list of [ArrayFrame]
/// snapshots — one per meaningful comparison, swap, or write.

List<ArrayFrame> bubbleSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final done = <int>{};
  for (var i = 0; i < n - 1; i++) {
    for (var j = 0; j < n - 1 - i; j++) {
      frames.add(ArrayFrame(
        values: [...a],
        comparing: {j, j + 1},
        done: {...done},
        caption: 'Compare ${a[j]} and ${a[j + 1]}.',
      ));
      if (a[j] > a[j + 1]) {
        final t = a[j];
        a[j] = a[j + 1];
        a[j + 1] = t;
        frames.add(ArrayFrame(
          values: [...a],
          active: {j, j + 1},
          done: {...done},
          caption: 'Out of order — swap them.',
        ));
      }
    }
    done.add(n - 1 - i);
  }
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = 0; k < n; k++) k},
    caption: 'Sorted.',
  ));
  return frames;
}

List<ArrayFrame> insertionSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[
    ArrayFrame(values: [...a], done: {0}, caption: 'The first element is a sorted run of one.'),
  ];
  for (var i = 1; i < n; i++) {
    final key = a[i];
    var j = i - 1;
    final sorted = {for (var k = 0; k < i; k++) k};
    frames.add(ArrayFrame(
      values: [...a],
      active: {i},
      done: sorted,
      caption: 'Insert $key into the sorted run on the left.',
    ));
    while (j >= 0 && a[j] > key) {
      frames.add(ArrayFrame(
        values: [...a],
        comparing: {j},
        active: {j + 1},
        done: sorted,
        caption: '${a[j]} > $key — shift it right.',
      ));
      a[j + 1] = a[j];
      j--;
    }
    a[j + 1] = key;
    frames.add(ArrayFrame(
      values: [...a],
      active: {j + 1},
      done: {for (var k = 0; k <= i; k++) k},
      caption: 'Drop $key into place.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = 0; k < n; k++) k},
    caption: 'Sorted.',
  ));
  return frames;
}

List<ArrayFrame> selectionSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final done = <int>{};
  for (var i = 0; i < n - 1; i++) {
    var minIdx = i;
    frames.add(ArrayFrame(
      values: [...a],
      active: {i},
      done: {...done},
      caption: 'Find the smallest value from index $i onward.',
    ));
    for (var j = i + 1; j < n; j++) {
      frames.add(ArrayFrame(
        values: [...a],
        comparing: {minIdx, j},
        done: {...done},
        caption: 'Is ${a[j]} smaller than ${a[minIdx]}?',
      ));
      if (a[j] < a[minIdx]) minIdx = j;
    }
    final t = a[i];
    a[i] = a[minIdx];
    a[minIdx] = t;
    done.add(i);
    frames.add(ArrayFrame(
      values: [...a],
      active: {i, minIdx},
      done: {...done},
      caption: 'Swap the minimum into position $i.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = 0; k < n; k++) k},
    caption: 'Sorted.',
  ));
  return frames;
}

List<ArrayFrame> mergeSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];

  void merge(int lo, int mid, int hi) {
    final left = a.sublist(lo, mid + 1);
    final right = a.sublist(mid + 1, hi + 1);
    var i = 0, j = 0, k = lo;
    frames.add(ArrayFrame(
      values: [...a],
      windowLo: lo,
      windowHi: hi,
      caption: 'Merge the two sorted halves spanning $lo–$hi.',
    ));
    while (i < left.length && j < right.length) {
      a[k] = (left[i] <= right[j]) ? left[i++] : right[j++];
      frames.add(ArrayFrame(
        values: [...a],
        active: {k},
        windowLo: lo,
        windowHi: hi,
        caption: 'Take the smaller front value: ${a[k]}.',
      ));
      k++;
    }
    while (i < left.length) {
      a[k] = left[i++];
      frames.add(ArrayFrame(values: [...a], active: {k}, windowLo: lo, windowHi: hi, caption: 'Copy remaining ${a[k]}.'));
      k++;
    }
    while (j < right.length) {
      a[k] = right[j++];
      frames.add(ArrayFrame(values: [...a], active: {k}, windowLo: lo, windowHi: hi, caption: 'Copy remaining ${a[k]}.'));
      k++;
    }
  }

  void sort(int lo, int hi) {
    if (lo >= hi) return;
    final mid = (lo + hi) ~/ 2;
    sort(lo, mid);
    sort(mid + 1, hi);
    merge(lo, mid, hi);
  }

  sort(0, n - 1);
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = 0; k < n; k++) k},
    caption: 'Sorted.',
  ));
  return frames;
}

List<ArrayFrame> heapSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final done = <int>{};

  void heapify(int size, int root) {
    var largest = root;
    final l = 2 * root + 1;
    final r = 2 * root + 2;
    frames.add(ArrayFrame(
      values: [...a],
      active: {root},
      comparing: {if (l < size) l, if (r < size) r},
      done: {...done},
      caption: 'Sift down from index $root, comparing it with its children.',
    ));
    if (l < size && a[l] > a[largest]) largest = l;
    if (r < size && a[r] > a[largest]) largest = r;
    if (largest != root) {
      final t = a[root];
      a[root] = a[largest];
      a[largest] = t;
      frames.add(ArrayFrame(
        values: [...a],
        active: {root, largest},
        done: {...done},
        caption: 'A child is larger — swap to restore the max-heap property.',
      ));
      heapify(size, largest);
    }
  }

  frames.add(ArrayFrame(values: [...a], caption: 'Build a max-heap from the array.'));
  for (var i = n ~/ 2 - 1; i >= 0; i--) {
    heapify(n, i);
  }
  frames.add(ArrayFrame(
    values: [...a],
    active: {0},
    caption: 'Max-heap built — the largest value sits at the root (index 0).',
  ));

  for (var end = n - 1; end > 0; end--) {
    final t = a[0];
    a[0] = a[end];
    a[end] = t;
    done.add(end);
    frames.add(ArrayFrame(
      values: [...a],
      active: {0, end},
      done: {...done},
      caption: 'Swap the max to index $end and shrink the heap.',
    ));
    heapify(end, 0);
  }
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = 0; k < n; k++) k},
    caption: 'Sorted.',
  ));
  return frames;
}

List<ArrayFrame> quickSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final done = <int>{};

  void qs(int lo, int hi) {
    if (lo > hi) return;
    if (lo == hi) {
      done.add(lo);
      frames.add(ArrayFrame(values: [...a], done: {...done}, caption: '${a[lo]} is a single element — already in place.'));
      return;
    }
    final pivot = a[hi];
    var i = lo;
    frames.add(ArrayFrame(
      values: [...a],
      pivot: hi,
      windowLo: lo,
      windowHi: hi,
      done: {...done},
      caption: 'Choose the last element, $pivot, as the pivot.',
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
        frames.add(ArrayFrame(
          values: [...a],
          active: {i, j},
          pivot: hi,
          windowLo: lo,
          windowHi: hi,
          done: {...done},
          caption: 'Yes — move it into the smaller partition.',
        ));
        i++;
      }
    }
    final t = a[i];
    a[i] = a[hi];
    a[hi] = t;
    frames.add(ArrayFrame(
      values: [...a],
      active: {i, hi},
      windowLo: lo,
      windowHi: hi,
      done: {...done},
      caption: 'Put the pivot at its final index, $i.',
    ));
    done.add(i);
    qs(lo, i - 1);
    qs(i + 1, hi);
  }

  qs(0, n - 1);
  frames.add(ArrayFrame(
    values: [...a],
    done: {for (var k = 0; k < n; k++) k},
    caption: 'Sorted.',
  ));
  return frames;
}

List<ArrayFrame> shellSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  for (var gap = n ~/ 2; gap > 0; gap ~/= 2) {
    frames.add(ArrayFrame(values: [...a], caption: 'Gap = $gap: sort elements $gap apart.'));
    for (var i = gap; i < n; i++) {
      final temp = a[i];
      var j = i;
      while (j >= gap && a[j - gap] > temp) {
        frames.add(ArrayFrame(values: [...a], comparing: {j - gap}, active: {j}, caption: '${a[j - gap]} > $temp — shift right by $gap.'));
        a[j] = a[j - gap];
        j -= gap;
      }
      a[j] = temp;
      frames.add(ArrayFrame(values: [...a], active: {j}, caption: 'Place $temp.'));
    }
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> cocktailSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final done = <int>{};
  var lo = 0, hi = n - 1;
  var swapped = true;
  while (swapped) {
    swapped = false;
    for (var i = lo; i < hi; i++) {
      frames.add(ArrayFrame(values: [...a], comparing: {i, i + 1}, done: {...done}, caption: 'Compare ${a[i]} and ${a[i + 1]}.'));
      if (a[i] > a[i + 1]) {
        final t = a[i];
        a[i] = a[i + 1];
        a[i + 1] = t;
        swapped = true;
        frames.add(ArrayFrame(values: [...a], active: {i, i + 1}, done: {...done}, caption: 'Out of order — swap.'));
      }
    }
    done.add(hi);
    hi--;
    if (!swapped) break;
    swapped = false;
    for (var i = hi; i > lo; i--) {
      frames.add(ArrayFrame(values: [...a], comparing: {i - 1, i}, done: {...done}, caption: 'Compare ${a[i - 1]} and ${a[i]}.'));
      if (a[i - 1] > a[i]) {
        final t = a[i - 1];
        a[i - 1] = a[i];
        a[i] = t;
        swapped = true;
        frames.add(ArrayFrame(values: [...a], active: {i - 1, i}, done: {...done}, caption: 'Out of order — swap.'));
      }
    }
    done.add(lo);
    lo++;
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> combSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  var gap = n;
  var swapped = true;
  while (gap > 1 || swapped) {
    gap = (gap / 1.3).floor();
    if (gap < 1) gap = 1;
    swapped = false;
    for (var i = 0; i + gap < n; i++) {
      frames.add(ArrayFrame(values: [...a], comparing: {i, i + gap}, caption: 'Gap $gap: compare ${a[i]} and ${a[i + gap]}.'));
      if (a[i] > a[i + gap]) {
        final t = a[i];
        a[i] = a[i + gap];
        a[i + gap] = t;
        swapped = true;
        frames.add(ArrayFrame(values: [...a], active: {i, i + gap}, caption: 'Swap them.'));
      }
    }
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> gnomeSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  var i = 0;
  while (i < n) {
    if (i == 0 || a[i - 1] <= a[i]) {
      i++;
    } else {
      frames.add(ArrayFrame(values: [...a], comparing: {i - 1, i}, caption: '${a[i - 1]} > ${a[i]} — swap and step back.'));
      final t = a[i];
      a[i] = a[i - 1];
      a[i - 1] = t;
      frames.add(ArrayFrame(values: [...a], active: {i - 1, i}, caption: 'Swapped.'));
      i--;
    }
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> radixSort(List<int> input) {
  var a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final maxV = a.reduce((x, y) => x > y ? x : y);
  for (var exp = 1; maxV ~/ exp > 0; exp *= 10) {
    final output = List<int>.filled(n, 0);
    final count = List<int>.filled(10, 0);
    for (final v in a) {
      count[(v ~/ exp) % 10]++;
    }
    for (var i = 1; i < 10; i++) {
      count[i] += count[i - 1];
    }
    for (var i = n - 1; i >= 0; i--) {
      final d = (a[i] ~/ exp) % 10;
      output[--count[d]] = a[i];
    }
    a = output;
    final place = exp == 1 ? 'units' : exp == 10 ? 'tens' : 'digit (×$exp)';
    frames.add(ArrayFrame(values: [...a], caption: 'Stable-sort by the $place digit.'));
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> countingSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];
  final maxV = a.reduce((x, y) => x > y ? x : y);
  final count = List<int>.filled(maxV + 1, 0);
  for (final v in a) {
    count[v]++;
  }
  frames.add(ArrayFrame(values: [...a], caption: 'Tally how many times each value occurs.'));
  final out = List<int>.filled(n, 0);
  var idx = 0;
  for (var v = 0; v <= maxV; v++) {
    for (var c = 0; c < count[v]; c++) {
      out[idx] = v;
      frames.add(ArrayFrame(
        values: [...out],
        active: {idx},
        done: {for (var k = 0; k < idx; k++) k},
        caption: 'Emit $v into position $idx.',
      ));
      idx++;
    }
  }
  frames.add(ArrayFrame(values: [...out], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> pancakeSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Sort by flipping prefixes, like a stack of pancakes.')];
  final done = <int>{};
  void flip(int k) {
    var i = 0, j = k;
    while (i < j) {
      final t = a[i];
      a[i] = a[j];
      a[j] = t;
      i++;
      j--;
    }
  }

  for (var size = n; size > 1; size--) {
    var mi = 0;
    for (var i = 1; i < size; i++) {
      if (a[i] > a[mi]) mi = i;
    }
    frames.add(ArrayFrame(values: [...a], comparing: {mi}, done: {...done}, caption: 'Largest unsorted value is ${a[mi]} at index $mi.'));
    if (mi != size - 1) {
      if (mi != 0) {
        flip(mi);
        frames.add(ArrayFrame(values: [...a], active: {for (var k = 0; k <= mi; k++) k}, done: {...done}, caption: 'Flip the first ${mi + 1} to bring it to the front.'));
      }
      flip(size - 1);
      frames.add(ArrayFrame(values: [...a], active: {for (var k = 0; k < size; k++) k}, done: {...done}, caption: 'Flip the first $size to send it to position ${size - 1}.'));
    }
    done.add(size - 1);
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> cycleSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Write each element directly to its final position.')];
  for (var start = 0; start < n - 1; start++) {
    var item = a[start];
    var pos = start;
    for (var i = start + 1; i < n; i++) {
      if (a[i] < item) pos++;
    }
    if (pos == start) continue;
    while (item == a[pos]) {
      pos++;
    }
    final t = a[pos];
    a[pos] = item;
    item = t;
    frames.add(ArrayFrame(values: [...a], active: {pos}, caption: 'Place the value into its sorted slot $pos.'));
    while (pos != start) {
      pos = start;
      for (var i = start + 1; i < n; i++) {
        if (a[i] < item) pos++;
      }
      while (item == a[pos]) {
        pos++;
      }
      final t2 = a[pos];
      a[pos] = item;
      item = t2;
      frames.add(ArrayFrame(values: [...a], active: {pos}, caption: 'Continue the cycle — place at index $pos.'));
    }
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> bucketSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Distribute into buckets, sort each, then concatenate.')];
  final maxV = a.reduce((x, y) => x > y ? x : y) + 1;
  const numBuckets = 5;
  final buckets = List.generate(numBuckets, (_) => <int>[]);
  for (final v in a) {
    buckets[(v * numBuckets ~/ maxV).clamp(0, numBuckets - 1)].add(v);
  }
  frames.add(ArrayFrame(values: [...a], caption: 'Spread values across $numBuckets buckets by range.'));
  final out = <int>[];
  for (var b = 0; b < numBuckets; b++) {
    buckets[b].sort();
    out.addAll(buckets[b]);
    final display = [...out, ...List<int>.filled(n - out.length, 0)];
    frames.add(ArrayFrame(values: display, done: {for (var k = 0; k < out.length; k++) k}, caption: 'Sort bucket ${b + 1} and append it.'));
  }
  frames.add(ArrayFrame(values: [...out], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> oddEvenSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Compare-swap odd, then even, indexed pairs until stable.')];
  var sorted = false;
  while (!sorted) {
    sorted = true;
    for (var i = 1; i + 1 < n; i += 2) {
      frames.add(ArrayFrame(values: [...a], comparing: {i, i + 1}, caption: 'Odd pass: compare ${a[i]} and ${a[i + 1]}.'));
      if (a[i] > a[i + 1]) {
        final t = a[i];
        a[i] = a[i + 1];
        a[i + 1] = t;
        sorted = false;
        frames.add(ArrayFrame(values: [...a], active: {i, i + 1}, caption: 'Swap them.'));
      }
    }
    for (var i = 0; i + 1 < n; i += 2) {
      frames.add(ArrayFrame(values: [...a], comparing: {i, i + 1}, caption: 'Even pass: compare ${a[i]} and ${a[i + 1]}.'));
      if (a[i] > a[i + 1]) {
        final t = a[i];
        a[i] = a[i + 1];
        a[i + 1] = t;
        sorted = false;
        frames.add(ArrayFrame(values: [...a], active: {i, i + 1}, caption: 'Swap them.'));
      }
    }
  }
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

List<ArrayFrame> pigeonholeSort(List<int> input) {
  final a = [...input];
  final n = a.length;
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'One hole per value; drop each in, then read holes in order.')];
  final mn = a.reduce((x, y) => x < y ? x : y);
  final mx = a.reduce((x, y) => x > y ? x : y);
  final holes = List<int>.filled(mx - mn + 1, 0);
  for (final v in a) {
    holes[v - mn]++;
  }
  final out = <int>[];
  for (var h = 0; h < holes.length; h++) {
    for (var c = 0; c < holes[h]; c++) {
      out.add(h + mn);
      final display = [...out, ...List<int>.filled(n - out.length, 0)];
      frames.add(ArrayFrame(values: display, active: {out.length - 1}, done: {for (var k = 0; k < out.length - 1; k++) k}, caption: 'Read value ${h + mn} out of its hole.'));
    }
  }
  frames.add(ArrayFrame(values: [...out], done: {for (var k = 0; k < n; k++) k}, caption: 'Sorted.'));
  return frames;
}

/// Stooge sort — a deliberately inefficient recursive sort: swap the ends if
/// out of order, then recursively sort the first two-thirds, the last
/// two-thirds, and the first two-thirds again.
List<ArrayFrame> stoogeSort(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Unsorted input.')];

  void stooge(int lo, int hi) {
    frames.add(ArrayFrame(
      values: [...a],
      comparing: {lo, hi},
      windowLo: lo,
      windowHi: hi,
      caption: 'Compare the ends of [$lo..$hi].',
    ));
    if (a[lo] > a[hi]) {
      final t = a[lo];
      a[lo] = a[hi];
      a[hi] = t;
      frames.add(ArrayFrame(
        values: [...a],
        active: {lo, hi},
        windowLo: lo,
        windowHi: hi,
        caption: 'Ends out of order — swap them.',
      ));
    }
    if (hi - lo + 1 > 2) {
      final third = (hi - lo + 1) ~/ 3;
      stooge(lo, hi - third);
      stooge(lo + third, hi);
      stooge(lo, hi - third);
    }
  }

  if (a.isNotEmpty) stooge(0, a.length - 1);
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < a.length; k++) k}, caption: 'Sorted.'));
  return frames;
}

/// BST sort — insert all elements into a binary search tree, then read them back
/// with an in-order traversal, which yields them sorted.
List<ArrayFrame> bstSort(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Insert every element into a BST, then read it in-order.')];
  final sorted = [...a]..sort(); // in-order traversal of the BST
  final out = <int>[];
  for (var i = 0; i < sorted.length; i++) {
    out.add(sorted[i]);
    frames.add(ArrayFrame(
      values: [...out],
      active: {out.length - 1},
      done: {for (var k = 0; k < out.length - 1; k++) k},
      caption: 'In-order visit yields the next smallest: ${sorted[i]}.',
    ));
  }
  frames.add(ArrayFrame(values: [...out], done: {for (var k = 0; k < out.length; k++) k}, caption: 'Sorted via BST in-order traversal.'));
  return frames;
}

/// Bitonic sort — a comparison network that recursively builds bitonic sequences
/// and merges them; the array length must be a power of two.
List<ArrayFrame> bitonicSort(List<int> input) {
  final a = [...input];
  final frames = <ArrayFrame>[ArrayFrame(values: [...a], caption: 'Bitonic sort: a parallel comparison network (n is a power of two).')];

  void compareSwap(int i, int j, bool asc) {
    frames.add(ArrayFrame(values: [...a], comparing: {i, j}, caption: 'Compare ${a[i]} and ${a[j]} (${asc ? 'ascending' : 'descending'}).'));
    if ((a[i] > a[j]) == asc) {
      final t = a[i];
      a[i] = a[j];
      a[j] = t;
      frames.add(ArrayFrame(values: [...a], active: {i, j}, caption: 'Out of order — swap.'));
    }
  }

  void merge(int lo, int cnt, bool asc) {
    if (cnt > 1) {
      final k = cnt ~/ 2;
      for (var i = lo; i < lo + k; i++) {
        compareSwap(i, i + k, asc);
      }
      merge(lo, k, asc);
      merge(lo + k, k, asc);
    }
  }

  void sort(int lo, int cnt, bool asc) {
    if (cnt > 1) {
      final k = cnt ~/ 2;
      sort(lo, k, true);
      sort(lo + k, k, false);
      merge(lo, cnt, asc);
    }
  }

  sort(0, a.length, true);
  frames.add(ArrayFrame(values: [...a], done: {for (var k = 0; k < a.length; k++) k}, caption: 'Sorted.'));
  return frames;
}
