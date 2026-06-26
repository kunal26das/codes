import '../models/frames.dart';

LinkedNode _n(int v, {bool highlight = false, bool fading = false}) =>
    LinkedNode(value: v, highlight: highlight, fading: fading);

LinkedFrame _frame(List<int> list, String caption, {int? hot, int? fade, bool circular = false}) =>
    LinkedFrame(
      nodes: [for (var i = 0; i < list.length; i++) _n(list[i], highlight: i == hot, fading: i == fade)],
      circular: circular,
      caption: caption,
    );

/// Traverse a singly linked list, following next pointers to the end.
List<LinkedFrame> listTraversal() {
  const list = [10, 20, 30, 40];
  final frames = <LinkedFrame>[_frame(list, 'Follow next pointers from the head.')];
  for (var i = 0; i < list.length; i++) {
    frames.add(_frame(list, 'At node ${list[i]}; advance to next.', hot: i));
  }
  frames.add(_frame(list, 'Reached null — traversal done.'));
  return frames;
}

/// Insert into a sorted singly linked list, keeping the order.
List<LinkedFrame> listSortedInsert({int value = 25}) {
  final list = [10, 20, 30, 40];
  final frames = <LinkedFrame>[_frame(list, 'Insert $value, keeping the list sorted.')];
  var pos = 0;
  while (pos < list.length && list[pos] < value) {
    frames.add(_frame(list, '$value > ${list[pos]} — keep scanning.', hot: pos));
    pos++;
  }
  list.insert(pos, value);
  frames.add(_frame(list, 'Splice $value in at position $pos.', hot: pos));
  frames.add(_frame(list, 'Sorted order preserved: ${list.join(' → ')}.'));
  return frames;
}

/// Search a singly linked list for a value.
List<LinkedFrame> listSearch({int target = 30}) {
  const list = [10, 20, 30, 40];
  final frames = <LinkedFrame>[_frame(list, 'Search for $target node by node.')];
  for (var i = 0; i < list.length; i++) {
    if (list[i] == target) {
      frames.add(_frame(list, 'Found $target at position $i!', hot: i));
      return frames;
    }
    frames.add(_frame(list, '${list[i]} ≠ $target — keep going.', hot: i));
  }
  frames.add(_frame(list, '$target not in the list.'));
  return frames;
}

/// Insert a node at a given position in a singly linked list.
List<LinkedFrame> listInsert({int at = 2, int value = 99}) {
  final list = [10, 20, 30, 40];
  final frames = <LinkedFrame>[_frame(list, 'Insert $value at position $at.')];
  for (var i = 0; i < at; i++) {
    frames.add(_frame(list, 'Walk to position $i.', hot: i));
  }
  list.insert(at, value);
  frames.add(_frame(list, 'Re-link the new node into the chain.', hot: at));
  frames.add(_frame(list, 'Inserted: ${list.join(' → ')}.'));
  return frames;
}

/// Delete a node by value from a singly linked list.
List<LinkedFrame> listDelete({int value = 30}) {
  final list = [10, 20, 30, 40];
  final frames = <LinkedFrame>[_frame(list, 'Delete the node holding $value.')];
  final idx = list.indexOf(value);
  frames.add(_frame(list, 'Find $value, remember its predecessor.', fade: idx));
  list.removeAt(idx);
  frames.add(_frame(list, 'Predecessor now points past it.', hot: idx - 1 < 0 ? 0 : idx - 1));
  frames.add(_frame(list, 'Deleted: ${list.join(' → ')}.'));
  return frames;
}

/// Merge two sorted singly linked lists into one sorted list.
List<LinkedFrame> listMerge() {
  const a = [10, 30, 50];
  const b = [20, 40, 60];
  final merged = <int>[];
  final frames = <LinkedFrame>[_frame(merged, 'Merge [${a.join(', ')}] and [${b.join(', ')}].')];
  var i = 0, j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] <= b[j]) {
      merged.add(a[i++]);
    } else {
      merged.add(b[j++]);
    }
    frames.add(_frame(merged, 'Take the smaller head → ${merged.last}.', hot: merged.length - 1));
  }
  while (i < a.length) {
    merged.add(a[i++]);
    frames.add(_frame(merged, 'Append remaining ${merged.last}.', hot: merged.length - 1));
  }
  while (j < b.length) {
    merged.add(b[j++]);
    frames.add(_frame(merged, 'Append remaining ${merged.last}.', hot: merged.length - 1));
  }
  frames.add(_frame(merged, 'Merged: ${merged.join(' → ')}.'));
  return frames;
}

/// Bubble-sort a singly linked list by swapping adjacent node values.
List<LinkedFrame> listBubbleSort() {
  final list = [40, 10, 30, 20];
  final frames = <LinkedFrame>[_frame(list, 'Bubble-sort by swapping adjacent out-of-order nodes.')];
  for (var pass = 0; pass < list.length - 1; pass++) {
    for (var i = 0; i < list.length - 1 - pass; i++) {
      frames.add(_frame(list, 'Compare ${list[i]} and ${list[i + 1]}.', hot: i));
      if (list[i] > list[i + 1]) {
        final t = list[i];
        list[i] = list[i + 1];
        list[i + 1] = t;
        frames.add(_frame(list, 'Out of order — swap node values.', hot: i + 1));
      }
    }
  }
  frames.add(_frame(list, 'Sorted: ${list.join(' → ')}.'));
  return frames;
}

/// Reverse a singly linked list by flipping each next pointer.
List<LinkedFrame> listReverse() {
  final list = [10, 20, 30, 40];
  final frames = <LinkedFrame>[_frame(list, 'Reverse the list by flipping each pointer.')];
  for (var i = 0; i < list.length; i++) {
    frames.add(_frame(list, 'Re-point node ${list[i]} to its predecessor.', hot: i));
  }
  final rev = list.reversed.toList();
  frames.add(_frame(rev, 'Reversed: ${rev.join(' → ')}.'));
  return frames;
}

/// A "multi-list" (list of lists) shown as one flattened ring of all rows'
/// heads — a simple model of multiple chained lists sharing a structure.
List<LinkedFrame> multiList() {
  const rows = [
    [1, 2, 3],
    [4, 5],
    [6, 7, 8, 9],
  ];
  final frames = <LinkedFrame>[];
  final flat = <int>[];
  for (var r = 0; r < rows.length; r++) {
    for (final v in rows[r]) {
      flat.add(v);
      frames.add(_frame(flat, 'Row $r contributes node $v.', hot: flat.length - 1));
    }
  }
  frames.add(_frame(flat, 'A multi-list chains ${rows.length} sub-lists together.'));
  return frames;
}

/// A jagged linked list — a list of sub-lists of differing lengths. Demonstrates
/// traversal across the ragged rows, then element-wise addition of two rows.
List<LinkedFrame> jaggedLinkedList() {
  const rows = [
    [1, 2, 3],
    [4],
    [5, 6, 7, 8],
  ];
  final frames = <LinkedFrame>[
    _frame(rows[0], 'A jagged list holds rows of different lengths.'),
  ];
  for (var r = 0; r < rows.length; r++) {
    final row = rows[r];
    for (var i = 0; i < row.length; i++) {
      frames.add(LinkedFrame(
        nodes: [for (var k = 0; k < row.length; k++) _n(row[k], highlight: k == i)],
        caption: 'Traverse row $r (length ${row.length}) — visit ${row[i]}.',
      ));
    }
  }
  // Element-wise addition of two equal-length rows.
  const x = [2, 5, 1];
  const y = [3, 1, 6];
  final sum = <int>[];
  for (var i = 0; i < x.length; i++) {
    sum.add(x[i] + y[i]);
    frames.add(_frame(sum, 'Add rows: ${x[i]} + ${y[i]} = ${sum[i]}.', hot: sum.length - 1));
  }
  frames.add(_frame(sum, 'Row addition → ${sum.join(' → ')}.'));
  return frames;
}

/// Find the middle of a linked list with the slow/fast (tortoise & hare) pointer
/// technique: the fast pointer moves twice as fast, so when it reaches the end
/// the slow pointer is at the middle.
List<LinkedFrame> listMiddle() {
  const list = [10, 20, 30, 40, 50, 60, 70];
  final frames = <LinkedFrame>[_frame(list, 'Find the middle with slow/fast pointers.')];
  var slow = 0, fast = 0;
  while (fast < list.length && fast + 1 < list.length) {
    slow++;
    fast += 2;
    frames.add(_frame(list, 'slow → ${list[slow]}, fast → ${fast < list.length ? list[fast] : 'end'}.', hot: slow));
  }
  frames.add(_frame(list, 'Fast reached the end — middle is ${list[slow]}.', hot: slow));
  return frames;
}
