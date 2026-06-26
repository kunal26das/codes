import '../models/frames.dart';

// ----------------------------------------------------------------------------
// k-ary heap
// ----------------------------------------------------------------------------

/// A k-ary min-heap (here k = 3): each node has up to k children, and inserts
/// sift the new key up while it is smaller than its parent.
List<GTreeFrame> karyHeap({int k = 3}) {
  final heap = <int>[];
  GTreeFrame snap(String cap, {Set<int> hot = const {}}) {
    if (heap.isEmpty) {
      return GTreeFrame(nodes: const [GTreeNode(id: 0, label: '∅', children: [])], caption: cap);
    }
    return GTreeFrame(
      nodes: [
        for (var i = 0; i < heap.length; i++)
          GTreeNode(
            id: i,
            label: '${heap[i]}',
            children: [for (var c = 1; c <= k; c++) if (k * i + c < heap.length) k * i + c],
            state: hot.contains(i) ? GNodeState.active : GNodeState.normal,
          ),
      ],
      caption: cap,
    );
  }

  final frames = <GTreeFrame>[snap('A $k-ary min-heap — each node has up to $k children.')];
  for (final v in [9, 5, 7, 2, 8, 1, 6, 3]) {
    heap.add(v);
    var i = heap.length - 1;
    frames.add(snap('Insert $v at the next slot.', hot: {i}));
    while (i > 0) {
      final p = (i - 1) ~/ k;
      if (heap[p] <= heap[i]) break;
      final t = heap[p];
      heap[p] = heap[i];
      heap[i] = t;
      frames.add(snap('Smaller than parent — sift $v up.', hot: {p}));
      i = p;
    }
  }
  frames.add(snap('Done — the minimum ${heap[0]} sits at the root.'));
  return frames;
}

// ----------------------------------------------------------------------------
// B-tree (order 3: up to 2 keys / 3 children per node)
// ----------------------------------------------------------------------------

class _BNode {
  List<int> keys = [];
  List<_BNode> children = [];
  bool get leaf => children.isEmpty;
}

class _Split {
  _Split(this.median, this.right);
  final int median;
  final _BNode right;
}

List<GTreeFrame> bTree() {
  _BNode root = _BNode();

  void sortedInsert(List<int> keys, int key) {
    var i = 0;
    while (i < keys.length && keys[i] < key) {
      i++;
    }
    keys.insert(i, key);
  }

  _Split? insertInto(_BNode node, int key) {
    if (node.leaf) {
      sortedInsert(node.keys, key);
    } else {
      var i = 0;
      while (i < node.keys.length && key > node.keys[i]) {
        i++;
      }
      final res = insertInto(node.children[i], key);
      if (res != null) {
        node.keys.insert(i, res.median);
        node.children.insert(i + 1, res.right);
      }
    }
    if (node.keys.length > 2) {
      final median = node.keys[1];
      final right = _BNode()..keys = [node.keys[2]];
      if (!node.leaf) {
        right.children = [node.children[2], node.children[3]];
        node.children = [node.children[0], node.children[1]];
      }
      node.keys = [node.keys[0]];
      return _Split(median, right);
    }
    return null;
  }

  GTreeFrame snap(String cap) {
    final nodes = <GTreeNode>[];
    var counter = 0;
    int walk(_BNode n) {
      final id = counter++;
      final childIds = <int>[];
      for (final c in n.children) {
        childIds.add(walk(c));
      }
      nodes.add(GTreeNode(id: id, label: n.keys.join(' | '), children: childIds));
      return id;
    }

    walk(root);
    // walk produced ids in pre-order but added post-order; rootId is 0 because
    // root got counter value 0 first.
    return GTreeFrame(nodes: nodes, rootId: 0, caption: cap);
  }

  final frames = <GTreeFrame>[snap('A B-tree of order 3 — at most 2 keys per node.')];
  for (final key in [10, 20, 5, 6, 12, 30, 7, 17, 3, 25]) {
    final res = insertInto(root, key);
    if (res != null) {
      final newRoot = _BNode()
        ..keys = [res.median]
        ..children = [root, res.right];
      root = newRoot;
      frames.add(snap('Insert $key — root split, height grows.'));
    } else {
      frames.add(snap('Insert $key into the right leaf.'));
    }
  }
  frames.add(snap('Balanced B-tree — all leaves at the same depth.'));
  return frames;
}

// ----------------------------------------------------------------------------
// Red-Black tree
// ----------------------------------------------------------------------------

class _RbNode {
  _RbNode(this.val);
  int val;
  bool red = true;
  _RbNode? left;
  _RbNode? right;
  _RbNode? parent;
}

List<GTreeFrame> redBlackTree() {
  _RbNode? root;

  void rotateLeft(_RbNode x) {
    final y = x.right!;
    x.right = y.left;
    if (y.left != null) y.left!.parent = x;
    y.parent = x.parent;
    if (x.parent == null) {
      root = y;
    } else if (x == x.parent!.left) {
      x.parent!.left = y;
    } else {
      x.parent!.right = y;
    }
    y.left = x;
    x.parent = y;
  }

  void rotateRight(_RbNode x) {
    final y = x.left!;
    x.left = y.right;
    if (y.right != null) y.right!.parent = x;
    y.parent = x.parent;
    if (x.parent == null) {
      root = y;
    } else if (x == x.parent!.right) {
      x.parent!.right = y;
    } else {
      x.parent!.left = y;
    }
    y.right = x;
    x.parent = y;
  }

  void fixup(_RbNode z) {
    while (z.parent != null && z.parent!.red) {
      final gp = z.parent!.parent!;
      if (z.parent == gp.left) {
        final y = gp.right;
        if (y != null && y.red) {
          z.parent!.red = false;
          y.red = false;
          gp.red = true;
          z = gp;
        } else {
          if (z == z.parent!.right) {
            z = z.parent!;
            rotateLeft(z);
          }
          z.parent!.red = false;
          gp.red = true;
          rotateRight(gp);
        }
      } else {
        final y = gp.left;
        if (y != null && y.red) {
          z.parent!.red = false;
          y.red = false;
          gp.red = true;
          z = gp;
        } else {
          if (z == z.parent!.left) {
            z = z.parent!;
            rotateRight(z);
          }
          z.parent!.red = false;
          gp.red = true;
          rotateLeft(gp);
        }
      }
    }
    root!.red = false;
  }

  void insert(int v) {
    final z = _RbNode(v);
    _RbNode? parent;
    var cur = root;
    while (cur != null) {
      parent = cur;
      cur = v < cur.val ? cur.left : cur.right;
    }
    z.parent = parent;
    if (parent == null) {
      root = z;
    } else if (v < parent.val) {
      parent.left = z;
    } else {
      parent.right = z;
    }
    fixup(z);
  }

  GTreeFrame snap(String cap) {
    final nodes = <GTreeNode>[];
    var counter = 0;
    int walk(_RbNode n) {
      final id = counter++;
      final kids = <int>[];
      if (n.left != null) kids.add(walk(n.left!));
      if (n.right != null) kids.add(walk(n.right!));
      nodes.add(GTreeNode(id: id, label: '${n.val}', children: kids, state: n.red ? GNodeState.red : GNodeState.black));
      return id;
    }

    final r = root;
    if (r != null) walk(r);
    return GTreeFrame(
      nodes: nodes.isEmpty ? const [GTreeNode(id: 0, label: '∅', children: [])] : nodes,
      rootId: 0,
      caption: cap,
    );
  }

  final frames = <GTreeFrame>[snap('A red-black tree recolours and rotates to stay balanced.')];
  for (final v in [10, 20, 30, 15, 25, 5, 1]) {
    insert(v);
    frames.add(snap('Insert $v, then restore the red-black properties.'));
  }
  frames.add(snap('Balanced — no red node has a red child; black-heights match.'));
  return frames;
}

// ----------------------------------------------------------------------------
// Binomial heap
// ----------------------------------------------------------------------------

class _BinNode {
  _BinNode(this.val);
  int val;
  List<_BinNode> children = [];
  int get order => children.length;
}

List<GTreeFrame> binomialHeap() {
  final forest = <int, _BinNode>{}; // order -> root

  _BinNode link(_BinNode a, _BinNode b) {
    if (a.val <= b.val) {
      a.children.add(b);
      return a;
    } else {
      b.children.add(a);
      return b;
    }
  }

  void insert(int v) {
    var carry = _BinNode(v);
    var o = 0;
    while (forest[o] != null) {
      carry = link(forest[o]!, carry);
      forest.remove(o);
      o++;
    }
    forest[o] = carry;
  }

  GTreeFrame snap(String cap) {
    final nodes = <GTreeNode>[const GTreeNode(id: 0, label: 'H', children: [], state: GNodeState.good)];
    var counter = 1;
    final rootIds = <int>[];
    int walk(_BinNode n) {
      final id = counter++;
      final kids = <int>[for (final c in n.children) walk(c)];
      nodes.add(GTreeNode(id: id, label: '${n.val}', children: kids));
      return id;
    }

    final orders = forest.keys.toList()..sort();
    for (final o in orders) {
      rootIds.add(walk(forest[o]!));
    }
    nodes[0] = GTreeNode(id: 0, label: 'heap', children: rootIds, state: GNodeState.good);
    return GTreeFrame(nodes: nodes, rootId: 0, caption: cap);
  }

  final frames = <GTreeFrame>[snap('A binomial heap is a forest of binomial trees (one per set bit of the size).')];
  for (final v in [7, 3, 9, 1, 5, 8, 2]) {
    insert(v);
    final orders = (forest.keys.toList()..sort()).join(', ');
    frames.add(snap('Insert $v; merge equal-order trees with carry. Tree orders: {$orders}.'));
  }
  frames.add(snap('Each binomial tree of order k has exactly 2^k nodes.'));
  return frames;
}

// ----------------------------------------------------------------------------
// Interval tree
// ----------------------------------------------------------------------------

class _IvNode {
  _IvNode(this.lo, this.hi) : max = hi;
  int lo;
  int hi;
  int max;
  _IvNode? left;
  _IvNode? right;
}

List<GTreeFrame> intervalTree() {
  _IvNode? root;

  _IvNode add(_IvNode? node, int lo, int hi) {
    if (node == null) return _IvNode(lo, hi);
    if (lo < node.lo) {
      node.left = add(node.left, lo, hi);
    } else {
      node.right = add(node.right, lo, hi);
    }
    node.max = [node.max, hi].reduce((a, b) => a > b ? a : b);
    return node;
  }

  GTreeFrame snap(String cap) {
    final nodes = <GTreeNode>[];
    var counter = 0;
    int walk(_IvNode n) {
      final id = counter++;
      final kids = <int>[];
      if (n.left != null) kids.add(walk(n.left!));
      if (n.right != null) kids.add(walk(n.right!));
      nodes.add(GTreeNode(id: id, label: '[${n.lo},${n.hi}] m${n.max}', children: kids));
      return id;
    }

    final r = root;
    if (r != null) walk(r);
    return GTreeFrame(
      nodes: nodes.isEmpty ? const [GTreeNode(id: 0, label: '∅', children: [])] : nodes,
      rootId: 0,
      caption: cap,
    );
  }

  final frames = <GTreeFrame>[snap('An interval tree augments a BST with each subtree\'s maximum endpoint.')];
  for (final iv in const [
    [15, 20],
    [10, 30],
    [17, 19],
    [5, 20],
    [12, 15],
    [30, 40],
  ]) {
    root = add(root, iv[0], iv[1]);
    frames.add(snap('Insert [${iv[0]}, ${iv[1]}]; update max endpoints up the path.'));
  }
  frames.add(snap('The stored max lets overlap queries skip whole subtrees.'));
  return frames;
}
