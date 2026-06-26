import '../models/frames.dart';

/// Builds a binary-search tree by inserting [values] one at a time, then runs
/// an in-order traversal. Emits a [TreeFrame] per comparison, insertion, and
/// visit.
List<TreeFrame> bstDemo(List<int> values) {
  final frames = <TreeFrame>[];
  final value = <int, int>{};
  final left = <int, int?>{};
  final right = <int, int?>{};
  int? rootId;
  var nextId = 0;

  List<BstNode> snap() => [
        for (final id in value.keys)
          BstNode(id: id, value: value[id]!, left: left[id], right: right[id]),
      ];

  int newNode(int v) {
    final id = nextId++;
    value[id] = v;
    left[id] = null;
    right[id] = null;
    return id;
  }

  for (final v in values) {
    if (rootId == null) {
      rootId = newNode(v);
      frames.add(TreeFrame(nodes: snap(), rootId: rootId, highlight: {rootId}, caption: 'Insert $v as the root.'));
      continue;
    }
    var cur = rootId;
    while (true) {
      frames.add(TreeFrame(nodes: snap(), rootId: rootId, highlight: {cur}, caption: 'Compare $v with ${value[cur]}.'));
      if (v < value[cur]!) {
        if (left[cur] == null) {
          final id = newNode(v);
          left[cur] = id;
          frames.add(TreeFrame(nodes: snap(), rootId: rootId, highlight: {id}, caption: '$v < ${value[cur]} — add as left child.'));
          break;
        }
        cur = left[cur]!;
      } else {
        if (right[cur] == null) {
          final id = newNode(v);
          right[cur] = id;
          frames.add(TreeFrame(nodes: snap(), rootId: rootId, highlight: {id}, caption: '$v ≥ ${value[cur]} — add as right child.'));
          break;
        }
        cur = right[cur]!;
      }
    }
  }

  frames.add(TreeFrame(nodes: snap(), rootId: rootId, caption: 'Tree built. In-order traversal visits values in sorted order.'));

  final out = <int>[];
  void inorder(int? id) {
    if (id == null) return;
    inorder(left[id]);
    out.add(value[id]!);
    frames.add(TreeFrame(nodes: snap(), rootId: rootId, highlight: {id}, output: [...out], caption: 'Visit ${value[id]}.'));
    inorder(right[id]);
  }

  inorder(rootId);
  frames.add(TreeFrame(nodes: snap(), rootId: rootId, output: [...out], caption: 'In-order result: ${out.join(', ')}.'));
  return frames;
}

/// Builds a BST from [values], then animates a traversal in the given [order]:
/// 'pre', 'post', or 'level'. (In-order is covered by [bstDemo].)
List<TreeFrame> treeTraversal(List<int> values, String order) {
  final value = <int, int>{};
  final left = <int, int?>{};
  final right = <int, int?>{};
  int? rootId;
  var nextId = 0;

  List<BstNode> snap() => [
        for (final id in value.keys)
          BstNode(id: id, value: value[id]!, left: left[id], right: right[id]),
      ];

  int newNode(int v) {
    final id = nextId++;
    value[id] = v;
    left[id] = null;
    right[id] = null;
    return id;
  }

  void insert(int v) {
    if (rootId == null) {
      rootId = newNode(v);
      return;
    }
    var cur = rootId!;
    while (true) {
      if (v < value[cur]!) {
        if (left[cur] == null) {
          left[cur] = newNode(v);
          return;
        }
        cur = left[cur]!;
      } else {
        if (right[cur] == null) {
          right[cur] = newNode(v);
          return;
        }
        cur = right[cur]!;
      }
    }
  }

  for (final v in values) {
    insert(v);
  }

  final label = const {
    'pre': 'pre-order',
    'in': 'in-order',
    'post': 'post-order',
    'level': 'level-order',
  }[order]!;

  final frames = <TreeFrame>[
    TreeFrame(nodes: snap(), rootId: rootId, caption: 'Built a BST — traverse it in $label.'),
  ];
  final out = <int>[];

  void emit(int id, String how) {
    out.add(value[id]!);
    frames.add(TreeFrame(nodes: snap(), rootId: rootId, highlight: {id}, output: [...out], caption: how));
  }

  if (order == 'level') {
    final queue = <int>[if (rootId != null) rootId!];
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      emit(id, 'Visit ${value[id]} and enqueue its children.');
      if (left[id] != null) queue.add(left[id]!);
      if (right[id] != null) queue.add(right[id]!);
    }
  } else {
    void visit(int? id) {
      if (id == null) return;
      if (order == 'pre') emit(id, 'Visit ${value[id]} before its subtrees.');
      visit(left[id]);
      if (order == 'in') emit(id, 'Visit ${value[id]} between its subtrees.');
      visit(right[id]);
      if (order == 'post') emit(id, 'Visit ${value[id]} after its subtrees.');
    }

    visit(rootId);
  }

  frames.add(TreeFrame(nodes: snap(), rootId: rootId, output: [...out], caption: '$label result: ${out.join(', ')}.'));
  return frames;
}

/// Builds a binary max-heap by inserting [values] one at a time and sifting each
/// new value up. The complete tree is rendered via [TreeFrame].
List<TreeFrame> binaryHeapDemo(List<int> values) {
  final heap = <int>[];
  List<BstNode> snap() => [
        for (var i = 0; i < heap.length; i++)
          BstNode(
            id: i,
            value: heap[i],
            left: 2 * i + 1 < heap.length ? 2 * i + 1 : null,
            right: 2 * i + 2 < heap.length ? 2 * i + 2 : null,
          ),
      ];
  final frames = <TreeFrame>[];
  for (final v in values) {
    heap.add(v);
    var i = heap.length - 1;
    frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {i}, caption: 'Insert $v at the next open slot.'));
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {i, parent}, caption: 'Compare $v with its parent ${heap[parent]}.'));
      if (heap[parent] >= heap[i]) break;
      final t = heap[parent];
      heap[parent] = heap[i];
      heap[i] = t;
      frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {parent}, caption: 'Parent is smaller — swap $v upward.'));
      i = parent;
    }
  }
  frames.add(TreeFrame(nodes: snap(), rootId: heap.isEmpty ? null : 0, caption: 'Max-heap built — the root holds the maximum, ${heap.isEmpty ? 0 : heap[0]}.'));
  return frames;
}

/// A tiny BST builder shared by the operation demos below.
class _BstBuild {
  final value = <int, int>{};
  final left = <int, int?>{};
  final right = <int, int?>{};
  int? root;
  int _next = 0;

  int _new(int v) {
    final id = _next++;
    value[id] = v;
    left[id] = null;
    right[id] = null;
    return id;
  }

  void insert(int v) {
    if (root == null) {
      root = _new(v);
      return;
    }
    var cur = root!;
    while (true) {
      if (v < value[cur]!) {
        if (left[cur] == null) {
          left[cur] = _new(v);
          return;
        }
        cur = left[cur]!;
      } else {
        if (right[cur] == null) {
          right[cur] = _new(v);
          return;
        }
        cur = right[cur]!;
      }
    }
  }

  List<BstNode> snap() => [
        for (final id in value.keys) BstNode(id: id, value: value[id]!, left: left[id], right: right[id]),
      ];
}

/// Search a binary search tree for a value, following the comparison path.
List<TreeFrame> bstSearch(List<int> values, int target) {
  final t = _BstBuild();
  for (final v in values) {
    t.insert(v);
  }
  final frames = <TreeFrame>[TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'Search for $target down the tree.')];
  int? cur = t.root;
  while (cur != null) {
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Compare $target with ${t.value[cur]}.'));
    if (t.value[cur] == target) {
      frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Found $target!'));
      return frames;
    }
    cur = target < t.value[cur]! ? t.left[cur] : t.right[cur];
  }
  frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, caption: '$target is not in the tree.'));
  return frames;
}

/// Find the smallest value in a BST by walking left until there is no child.
List<TreeFrame> bstSmallest(List<int> values) {
  final t = _BstBuild();
  for (final v in values) {
    t.insert(v);
  }
  final frames = <TreeFrame>[TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'The smallest value sits at the leftmost node.')];
  var cur = t.root!;
  while (t.left[cur] != null) {
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Go left from ${t.value[cur]}.'));
    cur = t.left[cur]!;
  }
  frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Smallest value is ${t.value[cur]}.'));
  return frames;
}

/// Compute the height of a BST, highlighting one of its longest root-to-leaf
/// paths.
List<TreeFrame> bstHeight(List<int> values) {
  final t = _BstBuild();
  for (final v in values) {
    t.insert(v);
  }
  int height(int? id) {
    if (id == null) return 0;
    final l = height(t.left[id]);
    final r = height(t.right[id]);
    return 1 + (l > r ? l : r);
  }

  final path = <int>{};
  int? cur = t.root;
  while (cur != null) {
    path.add(cur);
    final l = height(t.left[cur]);
    final r = height(t.right[cur]);
    cur = l >= r ? t.left[cur] : t.right[cur];
  }
  final h = height(t.root);
  final frames = <TreeFrame>[
    TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'Height is the longest root-to-leaf edge count + 1.'),
    TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {...path}, caption: 'A longest path has ${path.length} nodes — height $h.'),
  ];
  return frames;
}

/// Delete a value from a BST, handling the leaf, one-child, and two-child cases.
List<TreeFrame> bstDelete(List<int> values, int target) {
  final t = _BstBuild();
  for (final v in values) {
    t.insert(v);
  }
  final frames = <TreeFrame>[TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'Delete $target from the BST.')];

  // Find node and parent.
  int? parent;
  var cur = t.root;
  while (cur != null && t.value[cur] != target) {
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Search for $target…'));
    parent = cur;
    cur = target < t.value[cur]! ? t.left[cur] : t.right[cur];
  }
  if (cur == null) {
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, caption: '$target not found — nothing to delete.'));
    return frames;
  }
  frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Found $target.'));

  void replaceChild(int? p, int oldId, int? newId) {
    if (p == null) {
      t.root = newId;
    } else if (t.left[p] == oldId) {
      t.left[p] = newId;
    } else {
      t.right[p] = newId;
    }
  }

  final l = t.left[cur], r = t.right[cur];
  if (l == null || r == null) {
    // 0 or 1 child.
    final child = l ?? r;
    replaceChild(parent, cur, child);
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'Splice it out, promoting its ${child == null ? 'absent' : 'single'} child.'));
  } else {
    // 2 children: replace value with in-order successor, then delete that.
    var succParent = cur;
    var succ = r;
    while (t.left[succ] != null) {
      succParent = succ;
      succ = t.left[succ]!;
    }
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {succ}, caption: 'In-order successor is ${t.value[succ]}.'));
    t.value[cur] = t.value[succ]!;
    replaceChild(succParent, succ, t.right[succ]);
    frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, highlight: {cur}, caption: 'Copy ${t.value[cur]} up and remove the successor.'));
  }
  frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'Deleted — BST property preserved.'));
  return frames;
}

/// Enumerate every root-to-leaf path of a BST.
List<TreeFrame> rootToLeaf(List<int> values) {
  final t = _BstBuild();
  for (final v in values) {
    t.insert(v);
  }
  final frames = <TreeFrame>[TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'List every path from the root to a leaf.')];
  final path = <int>[];
  void dfs(int? id) {
    if (id == null) return;
    path.add(id);
    if (t.left[id] == null && t.right[id] == null) {
      frames.add(TreeFrame(
        nodes: t.snap(),
        rootId: t.root,
        highlight: {...path},
        output: [for (final p in path) t.value[p]!],
        caption: 'Path: ${[for (final p in path) t.value[p]].join(' → ')}.',
      ));
    } else {
      dfs(t.left[id]);
      dfs(t.right[id]);
    }
    path.removeLast();
  }

  dfs(t.root);
  frames.add(TreeFrame(nodes: t.snap(), rootId: t.root, caption: 'All root-to-leaf paths enumerated.'));
  return frames;
}
