import '../models/frames.dart';

/// Hash table with open addressing (linear probing): each key hashes to a slot,
/// and on a collision we step forward until an empty slot is found.
List<HashFrame> hashLinearProbing({List<int>? keys, int size = 11}) {
  final k = keys ?? const [27, 18, 29, 28, 39, 13, 16];
  final slots = List<int>.filled(size, -1);
  final frames = <HashFrame>[
    HashFrame(size: size, slots: [...slots], caption: 'Insert keys with h(k) = k mod $size, probing forward on collisions.'),
  ];
  for (final key in k) {
    var idx = key % size;
    var steps = 0;
    while (slots[idx] != -1 && steps < size) {
      frames.add(HashFrame(size: size, slots: [...slots], probe: idx, inserting: key, caption: 'Slot $idx is occupied — probe the next slot.'));
      idx = (idx + 1) % size;
      steps++;
    }
    if (slots[idx] == -1) {
      slots[idx] = key;
      frames.add(HashFrame(size: size, slots: [...slots], probe: idx, inserting: key, placed: idx, caption: 'Place $key at slot $idx (hash was ${key % size}).'));
    }
  }
  frames.add(HashFrame(size: size, slots: [...slots], caption: 'All keys inserted.'));
  return frames;
}

/// A stack (LIFO): pushes add to the top and pops remove from the top.
List<SequenceFrame> stackDemo() {
  const ops = [
    ['push', 3],
    ['push', 7],
    ['push', 1],
    ['pop', 0],
    ['push', 9],
    ['push', 4],
    ['pop', 0],
  ];
  final stack = <int>[];
  final frames = <SequenceFrame>[
    const SequenceFrame(values: [], vertical: true, caption: 'A stack is last-in, first-out (LIFO).'),
  ];
  for (final op in ops) {
    if (op[0] == 'push') {
      stack.add(op[1] as int);
      frames.add(SequenceFrame(values: [...stack], vertical: true, highlight: stack.length - 1, caption: 'push(${op[1]}) — add it on top.'));
    } else {
      final v = stack.removeLast();
      frames.add(SequenceFrame(values: [...stack, v], vertical: true, highlight: stack.length, removed: true, caption: 'pop() → $v from the top.'));
    }
  }
  frames.add(SequenceFrame(values: [...stack], vertical: true, caption: 'Final stack (top is highest).'));
  return frames;
}

/// A queue (FIFO): enqueues add to the back and dequeues remove from the front.
List<SequenceFrame> queueDemo() {
  const ops = [
    ['enq', 3],
    ['enq', 7],
    ['enq', 1],
    ['deq', 0],
    ['enq', 9],
    ['deq', 0],
    ['enq', 4],
  ];
  final queue = <int>[];
  final frames = <SequenceFrame>[
    const SequenceFrame(values: [], vertical: false, caption: 'A queue is first-in, first-out (FIFO).'),
  ];
  for (final op in ops) {
    if (op[0] == 'enq') {
      queue.add(op[1] as int);
      frames.add(SequenceFrame(values: [...queue], vertical: false, highlight: queue.length - 1, caption: 'enqueue(${op[1]}) — add it at the back.'));
    } else {
      final v = queue.removeAt(0);
      frames.add(SequenceFrame(values: [v, ...queue], vertical: false, highlight: 0, removed: true, caption: 'dequeue() → $v from the front.'));
    }
  }
  frames.add(SequenceFrame(values: [...queue], vertical: false, caption: 'Final queue (front is leftmost).'));
  return frames;
}

LinkedNode _ln(int v, {bool highlight = false, bool fading = false}) =>
    LinkedNode(value: v, highlight: highlight, fading: fading);

/// A singly linked list: nodes hold a value and a single "next" pointer. Demos
/// appending to the tail, inserting at the head, and deleting a node by value.
List<LinkedFrame> singlyLinkedList() {
  final list = <int>[];
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], caption: 'An empty singly linked list — each node points to the next.'),
  ];

  void snap(String caption, {int? hot, int? fade}) {
    frames.add(LinkedFrame(
      nodes: [for (var i = 0; i < list.length; i++) _ln(list[i], highlight: i == hot, fading: i == fade)],
      caption: caption,
    ));
  }

  for (final v in [10, 20, 30]) {
    list.add(v);
    snap('append($v) — link it after the tail.', hot: list.length - 1);
  }
  list.insert(0, 5);
  snap('insertHead(5) — point the new node at the old head.', hot: 0);
  final idx = list.indexOf(20);
  snap('delete(20) — find the node to unlink.', fade: idx);
  list.removeAt(idx);
  snap('delete(20) — bypass it so its predecessor points past it.', hot: idx - 1);
  frames.add(LinkedFrame(nodes: [for (final v in list) _ln(v)], caption: 'Final list: ${list.join(' → ')}.'));
  return frames;
}

/// A doubly linked list: each node keeps both "next" and "prev" pointers, so it
/// can be traversed in either direction and a node deletes in O(1) given a
/// reference.
List<LinkedFrame> doublyLinkedList() {
  final list = <int>[];
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], doubly: true, caption: 'A doubly linked list — every node links both ways.'),
  ];

  void snap(String caption, {int? hot, int? fade}) {
    frames.add(LinkedFrame(
      nodes: [for (var i = 0; i < list.length; i++) _ln(list[i], highlight: i == hot, fading: i == fade)],
      doubly: true,
      caption: caption,
    ));
  }

  for (final v in [10, 20, 30]) {
    list.add(v);
    snap('pushBack($v) — wire next/prev with the old tail.', hot: list.length - 1);
  }
  list.insert(0, 5);
  snap('pushFront(5) — new head, its next is the old head.', hot: 0);
  const target = 20;
  final idx = list.indexOf(target);
  snap('remove($target) — re-link its neighbours around it.', fade: idx);
  list.removeAt(idx);
  snap('remove($target) — gone; prev and next now point to each other.', hot: idx - 1);
  frames.add(LinkedFrame(nodes: [for (final v in list) _ln(v)], doubly: true, caption: 'Final list: ${list.join(' ⇄ ')}.'));
  return frames;
}

/// A circular linked list: the tail's "next" points back to the head, so a
/// traversal loops forever. Handy for round-robin scheduling and ring buffers.
List<LinkedFrame> circularLinkedList() {
  final list = <int>[];
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], circular: true, caption: 'A circular list — the tail points back to the head.'),
  ];

  void snap(String caption, {int? hot}) {
    frames.add(LinkedFrame(
      nodes: [for (var i = 0; i < list.length; i++) _ln(list[i], highlight: i == hot)],
      circular: true,
      caption: caption,
    ));
  }

  for (final v in [1, 2, 3, 4]) {
    list.add(v);
    snap('insert($v) — keep the tail pointing back at the head.', hot: list.length - 1);
  }
  snap('Traverse from the head…', hot: 0);
  snap('…past the tail…', hot: list.length - 1);
  snap('…and the next step wraps to the head again.', hot: 0);
  frames.add(LinkedFrame(nodes: [for (final v in list) _ln(v)], circular: true, caption: 'A ring of ${list.length} nodes with no end.'));
  return frames;
}

/// A double-ended queue (deque): elements can be pushed and popped from both
/// the front and the back in O(1).
List<SequenceFrame> dequeDemo() {
  const ops = [
    ['pushBack', 3],
    ['pushBack', 7],
    ['pushFront', 1],
    ['pushBack', 9],
    ['popFront', 0],
    ['pushFront', 5],
    ['popBack', 0],
  ];
  final dq = <int>[];
  final frames = <SequenceFrame>[
    const SequenceFrame(values: [], vertical: false, caption: 'A deque allows push/pop at both ends.'),
  ];
  for (final op in ops) {
    switch (op[0]) {
      case 'pushBack':
        dq.add(op[1] as int);
        frames.add(SequenceFrame(values: [...dq], vertical: false, highlight: dq.length - 1, caption: 'pushBack(${op[1]}).'));
      case 'pushFront':
        dq.insert(0, op[1] as int);
        frames.add(SequenceFrame(values: [...dq], vertical: false, highlight: 0, caption: 'pushFront(${op[1]}).'));
      case 'popFront':
        final v = dq.removeAt(0);
        frames.add(SequenceFrame(values: [v, ...dq], vertical: false, highlight: 0, removed: true, caption: 'popFront() → $v.'));
      case 'popBack':
        final v = dq.removeLast();
        frames.add(SequenceFrame(values: [...dq, v], vertical: false, highlight: dq.length, removed: true, caption: 'popBack() → $v.'));
    }
  }
  frames.add(SequenceFrame(values: [...dq], vertical: false, caption: 'Final deque (front is leftmost).'));
  return frames;
}

/// A binary min-heap used as a priority queue. Inserts sift up; extract-min
/// swaps the root to the end and sifts the new root down. Rendered as the
/// complete tree (root holds the smallest key).
List<TreeFrame> priorityQueue() {
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
  final frames = <TreeFrame>[
    const TreeFrame(nodes: [], caption: 'A priority queue keeps the smallest key at the root.'),
  ];

  for (final v in [9, 5, 7, 2, 8, 1]) {
    heap.add(v);
    var i = heap.length - 1;
    frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {i}, caption: 'insert($v) at the next slot.'));
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      if (heap[parent] <= heap[i]) break;
      final t = heap[parent];
      heap[parent] = heap[i];
      heap[i] = t;
      frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {parent}, caption: 'Smaller than its parent — sift $v up.'));
      i = parent;
    }
  }

  // Extract the two smallest.
  for (var e = 0; e < 2; e++) {
    final min = heap[0];
    heap[0] = heap.removeLast();
    frames.add(TreeFrame(nodes: snap(), rootId: heap.isEmpty ? null : 0, highlight: heap.isEmpty ? {} : {0}, caption: 'extractMin() → $min; move the last key to the root.'));
    var i = 0;
    while (true) {
      final l = 2 * i + 1, r = 2 * i + 2;
      var smallest = i;
      if (l < heap.length && heap[l] < heap[smallest]) smallest = l;
      if (r < heap.length && heap[r] < heap[smallest]) smallest = r;
      if (smallest == i) break;
      final t = heap[smallest];
      heap[smallest] = heap[i];
      heap[i] = t;
      frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {smallest}, caption: 'Sift the root down to restore the heap.'));
      i = smallest;
    }
  }
  frames.add(TreeFrame(nodes: snap(), rootId: heap.isEmpty ? null : 0, caption: 'The next-smallest key is always ready at the root.'));
  return frames;
}

/// A trie (prefix tree): words share their common prefixes along a path from the
/// root, and a flag marks where a word ends. Inserts a small dictionary, then
/// looks one word up.
List<TrieFrame> trieDemo() {
  final label = <int, String>{0: ''};
  final children = <int, Map<String, int>>{0: {}};
  final isWord = <int>{};
  var nextId = 1;

  List<TrieNode> snap() => [
        for (final id in label.keys)
          TrieNode(
            id: id,
            label: label[id]!,
            children: children[id]!.values.toList()..sort(),
            isWord: isWord.contains(id),
          ),
      ];

  final frames = <TrieFrame>[
    TrieFrame(nodes: snap(), caption: 'An empty trie — words will branch out from the root.'),
  ];

  void insert(String word) {
    var cur = 0;
    final path = <int>{0};
    for (final ch in word.split('')) {
      var next = children[cur]![ch];
      if (next == null) {
        next = nextId++;
        children[cur]![ch] = next;
        label[next] = ch;
        children[next] = {};
      }
      cur = next;
      path.add(cur);
      frames.add(TrieFrame(nodes: snap(), highlight: {...path}, caption: 'insert("$word") — follow/create edge "$ch".'));
    }
    isWord.add(cur);
    frames.add(TrieFrame(nodes: snap(), highlight: {...path}, caption: 'Mark the end of "$word".'));
  }

  for (final w in ['cat', 'car', 'card', 'dog']) {
    insert(w);
  }

  // Lookup.
  const query = 'car';
  var cur = 0;
  final path = <int>{0};
  for (final ch in query.split('')) {
    final next = children[cur]![ch];
    if (next == null) break;
    cur = next;
    path.add(cur);
    frames.add(TrieFrame(nodes: snap(), highlight: {...path}, caption: 'search("$query") — match "$ch".'));
  }
  frames.add(TrieFrame(nodes: snap(), highlight: {...path}, caption: isWord.contains(cur) ? '"$query" is in the trie.' : '"$query" is only a prefix.'));
  return frames;
}

/// Disjoint Set (Union–Find) with union by rank and path compression. Each
/// element points to a parent; `find` follows pointers to the representative
/// root, and `union` links the shorter tree under the taller. Rendered as a
/// forest of parent pointers.
GraphRun unionFind() {
  const n = 7;
  const labels = ['0', '1', '2', '3', '4', '5', '6'];
  const positions = [
    [0.10, 0.30],
    [0.27, 0.30],
    [0.44, 0.30],
    [0.61, 0.30],
    [0.78, 0.30],
    [0.30, 0.75],
    [0.60, 0.75],
  ];

  final parent = [for (var i = 0; i < n; i++) i];
  final rank = List<int>.filled(n, 0);
  final edges = <GraphEdge>[];
  final edgeSeen = <int>{};
  final frames = <GraphFrame>[];

  void addEdge(int child, int par) {
    final e = GraphEdge(child, par, 0);
    if (edgeSeen.add(e.key)) edges.add(e);
  }

  Set<int> activeEdges() {
    final s = <int>{};
    for (var i = 0; i < n; i++) {
      if (parent[i] != i) s.add(GraphEdge(i, parent[i], 0).key);
    }
    return s;
  }

  int find(int x) {
    while (parent[x] != x) {
      x = parent[x];
    }
    return x;
  }

  frames.add(const GraphFrame(caption: 'Seven singleton sets — each element is its own root.'));

  void union(int a, int b) {
    final ra = find(a), rb = find(b);
    frames.add(GraphFrame(
      treeEdges: activeEdges(),
      current: ra,
      caption: 'union($a, $b): roots are $ra and $rb.',
    ));
    if (ra == rb) {
      return;
    }
    if (rank[ra] < rank[rb]) {
      parent[ra] = rb;
      addEdge(ra, rb);
    } else if (rank[ra] > rank[rb]) {
      parent[rb] = ra;
      addEdge(rb, ra);
    } else {
      parent[rb] = ra;
      rank[ra]++;
      addEdge(rb, ra);
    }
    frames.add(GraphFrame(
      treeEdges: activeEdges(),
      current: find(a),
      caption: 'Linked: the shorter tree hangs under the taller root.',
    ));
  }

  for (final pair in const [[0, 1], [2, 3], [1, 3], [4, 5], [5, 6], [0, 6]]) {
    union(pair[0], pair[1]);
  }

  // Path compression on a deep find.
  parent[2] = find(2);
  addEdge(2, parent[2]);
  frames.add(GraphFrame(
    treeEdges: activeEdges(),
    current: parent[2],
    caption: 'find(2) compresses the path: 2 now points straight at the root.',
  ));

  frames.add(GraphFrame(treeEdges: activeEdges(), caption: 'All elements share one root — a single connected set.'));

  return GraphRun(nodeLabels: labels, positions: positions, edges: edges, frames: frames, directed: true);
}

// --- AVL tree --------------------------------------------------------------

class _Avl {
  _Avl(this.value);
  int value;
  int height = 1;
  _Avl? left;
  _Avl? right;
  final int id = _avlId++;
}

int _avlId = 0;

/// A self-balancing AVL tree. After every insertion it checks the balance factor
/// of each node on the path and applies single or double rotations so no
/// subtree's height differs by more than one.
List<TreeFrame> avlTree() {
  _avlId = 0;
  _Avl? root;
  final frames = <TreeFrame>[
    const TreeFrame(nodes: [], caption: 'An AVL tree rebalances itself with rotations after each insert.'),
  ];

  int h(_Avl? n) => n?.height ?? 0;
  int bf(_Avl? n) => n == null ? 0 : h(n.left) - h(n.right);
  void fix(_Avl n) => n.height = 1 + (h(n.left) > h(n.right) ? h(n.left) : h(n.right));

  List<BstNode> snap(_Avl? r) {
    final out = <BstNode>[];
    void walk(_Avl? n) {
      if (n == null) return;
      out.add(BstNode(id: n.id, value: n.value, left: n.left?.id, right: n.right?.id));
      walk(n.left);
      walk(n.right);
    }

    walk(r);
    return out;
  }

  _Avl rotateRight(_Avl y) {
    final x = y.left!;
    y.left = x.right;
    x.right = y;
    fix(y);
    fix(x);
    return x;
  }

  _Avl rotateLeft(_Avl x) {
    final y = x.right!;
    x.right = y.left;
    y.left = x;
    fix(x);
    fix(y);
    return y;
  }

  String? rotationNote;

  _Avl insert(_Avl? node, int v) {
    if (node == null) return _Avl(v);
    if (v < node.value) {
      node.left = insert(node.left, v);
    } else {
      node.right = insert(node.right, v);
    }
    fix(node);
    final balance = bf(node);
    if (balance > 1 && v < node.left!.value) {
      rotationNote = 'Right rotation at ${node.value}.';
      return rotateRight(node);
    }
    if (balance < -1 && v > node.right!.value) {
      rotationNote = 'Left rotation at ${node.value}.';
      return rotateLeft(node);
    }
    if (balance > 1 && v > node.left!.value) {
      rotationNote = 'Left-Right rotation at ${node.value}.';
      node.left = rotateLeft(node.left!);
      return rotateRight(node);
    }
    if (balance < -1 && v < node.right!.value) {
      rotationNote = 'Right-Left rotation at ${node.value}.';
      node.right = rotateRight(node.right!);
      return rotateLeft(node);
    }
    return node;
  }

  for (final v in [10, 20, 30, 40, 50, 25]) {
    rotationNote = null;
    root = insert(root, v);
    frames.add(TreeFrame(nodes: snap(root), rootId: root.id, highlight: {root.id}, caption: 'insert($v).'));
    if (rotationNote != null) {
      frames.add(TreeFrame(nodes: snap(root), rootId: root.id, caption: 'Unbalanced — $rotationNote'));
    }
  }
  frames.add(TreeFrame(nodes: snap(root), rootId: root!.id, caption: 'Balanced: every subtree height differs by at most one.'));
  return frames;
}

// --- Segment tree ----------------------------------------------------------

/// A sum segment tree over a small array: each leaf is an element and every
/// internal node stores the sum of its range. Built bottom-up so a range-sum
/// query later costs O(log n).
List<TreeFrame> segmentTree() {
  const data = [2, 1, 5, 3, 4, 6];
  final n = data.length;
  final value = <int, int>{};
  final left = <int, int?>{};
  final right = <int, int?>{};
  final lo = <int, int>{};
  final hi = <int, int>{};
  var nextId = 0;

  final frames = <TreeFrame>[
    TreeFrame(nodes: const [], caption: 'Build a segment tree over [${data.join(', ')}] — nodes hold range sums.'),
  ];

  List<BstNode> snap() => [
        for (final id in value.keys) BstNode(id: id, value: value[id]!, left: left[id], right: right[id]),
      ];

  int? rootId;

  int build(int l, int r) {
    final id = nextId++;
    lo[id] = l;
    hi[id] = r;
    left[id] = null;
    right[id] = null;
    if (l == r) {
      value[id] = data[l];
      frames.add(TreeFrame(nodes: snap(), rootId: rootId ?? id, highlight: {id}, caption: 'Leaf [$l] = ${data[l]}.'));
      return id;
    }
    final mid = (l + r) ~/ 2;
    final lc = build(l, mid);
    final rc = build(mid + 1, r);
    left[id] = lc;
    right[id] = rc;
    value[id] = value[lc]! + value[rc]!;
    rootId ??= id;
    frames.add(TreeFrame(nodes: snap(), rootId: 0, highlight: {id}, caption: 'Node [$l..$r] = ${value[lc]} + ${value[rc]} = ${value[id]}.'));
    return id;
  }

  rootId = build(0, n - 1);
  frames.add(TreeFrame(nodes: snap(), rootId: 0, caption: 'Root holds the total sum ${value[0]}; any range sum is now O(log n).'));
  return frames;
}

/// An LRU (least-recently-used) cache of fixed capacity. Accessing a key moves
/// it to the most-recent (right) end; inserting into a full cache evicts the
/// least-recent (left) end.
List<SequenceFrame> lruCache() {
  const capacity = 3;
  final order = <int>[]; // left = least recent, right = most recent
  final frames = <SequenceFrame>[
    const SequenceFrame(values: [], vertical: false, caption: 'An LRU cache (capacity $capacity): most-recent on the right.'),
  ];

  void access(int key) {
    final hit = order.remove(key);
    if (hit) {
      order.add(key);
      frames.add(SequenceFrame(values: [...order], vertical: false, highlight: order.length - 1, caption: 'get($key) — hit; move it to most-recent.'));
      return;
    }
    if (order.length >= capacity) {
      final evicted = order.removeAt(0);
      frames.add(SequenceFrame(values: [evicted, ...order], vertical: false, highlight: 0, removed: true, caption: 'put($key) — cache full; evict least-recent $evicted.'));
    }
    order.add(key);
    frames.add(SequenceFrame(values: [...order], vertical: false, highlight: order.length - 1, caption: 'put($key) — insert as most-recent.'));
  }

  for (final key in [1, 2, 3, 1, 4, 2]) {
    access(key);
  }
  frames.add(SequenceFrame(values: [...order], vertical: false, caption: 'Final cache, least-recent (left) to most-recent (right).'));
  return frames;
}

/// A Fenwick tree (binary indexed tree) supports prefix sums and point updates
/// in O(log n). Each 1-indexed slot i is responsible for a range of length
/// i & (-i); building it adds every element along the slots it affects.
List<ArrayFrame> fenwickTree([List<int>? input]) {
  final data = input ?? const [3, 2, 5, 1, 4, 6];
  final n = data.length;
  final tree = List<int>.filled(n + 1, 0); // 1-indexed
  List<int> disp() => tree.sublist(1);

  final frames = <ArrayFrame>[
    ArrayFrame(values: disp(), caption: 'Build a Fenwick tree over [${data.join(', ')}] — each slot covers a power-of-two range.'),
  ];

  for (var i = 0; i < n; i++) {
    var idx = i + 1;
    while (idx <= n) {
      tree[idx] += data[i];
      frames.add(ArrayFrame(
        values: disp(),
        active: {idx - 1},
        caption: 'Add ${data[i]} to slot $idx (it covers ${idx & (-idx)} element(s)).',
      ));
      idx += idx & (-idx);
    }
  }

  // Example prefix-sum query.
  var sum = 0;
  var q = 5;
  final used = <int>{};
  final jumps = <int>[];
  while (q > 0) {
    sum += tree[q];
    used.add(q - 1);
    jumps.add(q);
    q -= q & (-q);
  }
  frames.add(ArrayFrame(values: disp(), comparing: {...used}, caption: 'prefixSum(5) jumps through slots ${jumps.join(', ')} = $sum.'));
  frames.add(ArrayFrame(values: disp(), done: {for (var k = 0; k < n; k++) k}, caption: 'Ready — prefix sums and updates both run in O(log n).'));
  return frames;
}

/// A circular queue over a fixed-capacity buffer: head and tail indices wrap
/// around, so freed slots at the front are reused.
List<SequenceFrame> circularQueue({int capacity = 5}) {
  final q = <int>[];
  final frames = <SequenceFrame>[
    SequenceFrame(values: const [], vertical: false, caption: 'A circular queue reuses freed front slots (capacity $capacity).'),
  ];
  void enq(int v) {
    if (q.length >= capacity) {
      frames.add(SequenceFrame(values: [...q], vertical: false, caption: 'Full — cannot enqueue $v.'));
      return;
    }
    q.add(v);
    frames.add(SequenceFrame(values: [...q], vertical: false, highlight: q.length - 1, caption: 'enqueue($v) at the tail.'));
  }

  void deq() {
    final v = q.removeAt(0);
    frames.add(SequenceFrame(values: [v, ...q], vertical: false, highlight: 0, removed: true, caption: 'dequeue() → $v; the slot wraps for reuse.'));
  }

  for (final v in [1, 2, 3, 4, 5]) {
    enq(v);
  }
  deq();
  deq();
  enq(6);
  enq(7);
  frames.add(SequenceFrame(values: [...q], vertical: false, caption: 'Front slots were reused without shifting.'));
  return frames;
}

/// A stack backed by a singly linked list: push/pop happen at the head.
List<LinkedFrame> linkedStack() {
  final stack = <int>[]; // head = index 0 (top)
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], caption: 'A linked stack pushes and pops at the head (top).'),
  ];
  void push(int v) {
    stack.insert(0, v);
    frames.add(LinkedFrame(nodes: [for (var i = 0; i < stack.length; i++) _ln(stack[i], highlight: i == 0)], caption: 'push($v) — new head.'));
  }

  void pop() {
    final v = stack.removeAt(0);
    frames.add(LinkedFrame(nodes: [_ln(v, fading: true), for (final x in stack) _ln(x)], caption: 'pop() → $v from the head.'));
  }

  push(3);
  push(7);
  push(1);
  pop();
  push(9);
  frames.add(LinkedFrame(nodes: [for (final x in stack) _ln(x)], caption: 'Top is the head: ${stack.join(' → ')}.'));
  return frames;
}

/// A queue backed by a singly linked list: enqueue at the tail, dequeue at the
/// head.
List<LinkedFrame> linkedQueue() {
  final q = <int>[]; // head = index 0 (front)
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], caption: 'A linked queue enqueues at the tail, dequeues at the head.'),
  ];
  void enq(int v) {
    q.add(v);
    frames.add(LinkedFrame(nodes: [for (var i = 0; i < q.length; i++) _ln(q[i], highlight: i == q.length - 1)], caption: 'enqueue($v) at the tail.'));
  }

  void deq() {
    final v = q.removeAt(0);
    frames.add(LinkedFrame(nodes: [_ln(v, fading: true), for (final x in q) _ln(x)], caption: 'dequeue() → $v from the head.'));
  }

  enq(3);
  enq(7);
  enq(1);
  deq();
  enq(9);
  frames.add(LinkedFrame(nodes: [for (final x in q) _ln(x)], caption: 'Front is the head: ${q.join(' → ')}.'));
  return frames;
}

/// A circular linked queue: the tail node links back to the head, so one tail
/// pointer gives O(1) access to both ends.
List<LinkedFrame> circularLinkedQueue() {
  final q = <int>[];
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], circular: true, caption: 'A circular linked queue: the tail points back to the head.'),
  ];
  void enq(int v) {
    q.add(v);
    frames.add(LinkedFrame(nodes: [for (var i = 0; i < q.length; i++) _ln(q[i], highlight: i == q.length - 1)], circular: true, caption: 'enqueue($v); tail re-links to head.'));
  }

  void deq() {
    final v = q.removeAt(0);
    frames.add(LinkedFrame(nodes: [for (final x in q) _ln(x)], circular: true, caption: 'dequeue() → $v; tail now links to the new head.'));
  }

  enq(3);
  enq(7);
  enq(1);
  deq();
  enq(9);
  frames.add(LinkedFrame(nodes: [for (final x in q) _ln(x)], circular: true, caption: 'A ring with O(1) enqueue and dequeue.'));
  return frames;
}

/// Hash table with quadratic probing: on a collision the step grows as 1², 2²,
/// 3², … which spreads clusters out better than linear probing.
List<HashFrame> hashQuadraticProbing({List<int>? keys, int size = 11}) {
  final k = keys ?? const [27, 18, 29, 28, 39, 13, 16];
  final slots = List<int>.filled(size, -1);
  final frames = <HashFrame>[
    HashFrame(size: size, slots: [...slots], caption: 'Insert with h(k)=k mod $size, probing by 1², 2², 3², … on collisions.'),
  ];
  for (final key in k) {
    final base = key % size;
    var i = 0;
    var idx = base;
    while (slots[idx] != -1 && i < size) {
      frames.add(HashFrame(size: size, slots: [...slots], probe: idx, inserting: key, caption: 'Slot $idx taken — try offset ${i + 1}² = ${(i + 1) * (i + 1)}.'));
      i++;
      idx = (base + i * i) % size;
    }
    if (slots[idx] == -1) {
      slots[idx] = key;
      frames.add(HashFrame(size: size, slots: [...slots], probe: idx, inserting: key, placed: idx, caption: 'Place $key at slot $idx.'));
    }
  }
  frames.add(HashFrame(size: size, slots: [...slots], caption: 'All keys inserted with quadratic probing.'));
  return frames;
}

/// Hash table with separate chaining: each bucket holds a linked list of all
/// keys that hash to it.
List<ChainHashFrame> hashSeparateChaining({List<int>? keys, int size = 7}) {
  final k = keys ?? const [15, 11, 27, 8, 22, 1, 18, 29];
  final buckets = [for (var i = 0; i < size; i++) <int>[]];
  List<List<int>> snap() => [for (final b in buckets) [...b]];
  final frames = <ChainHashFrame>[
    ChainHashFrame(buckets: snap(), caption: 'Separate chaining: each bucket is a linked list (h(k)=k mod $size).'),
  ];
  for (final key in k) {
    final b = key % size;
    frames.add(ChainHashFrame(buckets: snap(), activeBucket: b, inserting: key, caption: 'h($key) = $b — append to that bucket\'s chain.'));
    buckets[b].add(key);
    frames.add(ChainHashFrame(buckets: snap(), activeBucket: b, inserting: key, placed: true, caption: 'Appended $key to bucket $b.'));
  }
  frames.add(ChainHashFrame(buckets: snap(), caption: 'Collisions live together in their bucket\'s chain.'));
  return frames;
}

/// Hash table with separate chaining backed by balanced (AVL) buckets: each
/// bucket keeps its keys sorted, so long chains still search in O(log m).
List<ChainHashFrame> hashChainingAvl({List<int>? keys, int size = 5}) {
  final k = keys ?? const [12, 7, 22, 2, 17, 9, 27, 4, 14];
  final buckets = [for (var i = 0; i < size; i++) <int>[]];
  List<List<int>> snap() => [for (final b in buckets) [...b]];
  final frames = <ChainHashFrame>[
    ChainHashFrame(buckets: snap(), caption: 'Each bucket is an AVL tree, shown here as its sorted in-order keys.'),
  ];
  for (final key in k) {
    final b = key % size;
    frames.add(ChainHashFrame(buckets: snap(), activeBucket: b, inserting: key, caption: 'h($key) = $b — insert into that bucket\'s AVL tree.'));
    final chain = buckets[b];
    var pos = 0;
    while (pos < chain.length && chain[pos] < key) {
      pos++;
    }
    chain.insert(pos, key); // sorted == AVL in-order
    frames.add(ChainHashFrame(buckets: snap(), activeBucket: b, inserting: key, placed: true, caption: 'Bucket $b stays sorted for O(log m) lookups.'));
  }
  frames.add(ChainHashFrame(buckets: snap(), caption: 'Balanced buckets keep even heavy collisions fast.'));
  return frames;
}

/// A stack implemented on a doubly linked list: push and pop happen at the head,
/// while the prev pointers also allow walking back from the top.
List<LinkedFrame> doublyLinkedStack() {
  final stack = <int>[]; // index 0 = top (head)
  final frames = <LinkedFrame>[
    const LinkedFrame(nodes: [], doubly: true, caption: 'A doubly linked list used as a stack — push/pop at the head.'),
  ];
  void push(int v) {
    stack.insert(0, v);
    frames.add(LinkedFrame(nodes: [for (var i = 0; i < stack.length; i++) _ln(stack[i], highlight: i == 0)], doubly: true, caption: 'push($v) — new head, prev/next re-linked.'));
  }

  void pop() {
    final v = stack.removeAt(0);
    frames.add(LinkedFrame(nodes: [_ln(v, fading: true), for (final x in stack) _ln(x)], doubly: true, caption: 'pop() → $v from the head.'));
  }

  push(3);
  push(7);
  push(1);
  pop();
  push(9);
  frames.add(LinkedFrame(nodes: [for (final x in stack) _ln(x)], doubly: true, caption: 'Top is the head; prev links allow walking back.'));
  return frames;
}

/// A monotonic (increasing) stack: before pushing each value, pop every larger
/// value off the top, so the stack always stays sorted bottom-to-top. Used for
/// "next smaller/greater element" problems.
List<SequenceFrame> monotonicStack(List<int> input) {
  final st = <int>[];
  final frames = <SequenceFrame>[
    const SequenceFrame(values: [], vertical: true, caption: 'Keep the stack increasing from bottom to top.'),
  ];
  for (final v in input) {
    while (st.isNotEmpty && st.last > v) {
      final popped = st.removeLast();
      frames.add(SequenceFrame(values: [...st, popped], vertical: true, highlight: st.length, removed: true, caption: 'Top $popped > $v — pop it.'));
    }
    st.add(v);
    frames.add(SequenceFrame(values: [...st], vertical: true, highlight: st.length - 1, caption: 'Push $v.'));
  }
  frames.add(SequenceFrame(values: [...st], vertical: true, caption: 'Final increasing stack.'));
  return frames;
}
