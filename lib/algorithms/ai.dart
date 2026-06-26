import '../models/frames.dart';

// Shared 3-level game tree: root (MAX) → 3 children (MIN) → 3 leaves each.
const _leaves = [
  [3, 12, 8],
  [2, 4, 6],
  [14, 5, 2],
];

// Node ids: root = 0, children = 1..3, leaves = 4..12.
int _childId(int c) => 1 + c;
int _leafId(int c, int l) => 4 + c * 3 + l;

GTreeFrame _gameFrame({
  required Map<int, String> label,
  required Map<int, GNodeState> state,
  required String caption,
}) {
  final nodes = <GTreeNode>[
    GTreeNode(id: 0, label: label[0] ?? 'MAX', children: [for (var c = 0; c < 3; c++) _childId(c)], state: state[0] ?? GNodeState.normal),
    for (var c = 0; c < 3; c++)
      GTreeNode(
        id: _childId(c),
        label: label[_childId(c)] ?? 'min',
        children: [for (var l = 0; l < 3; l++) _leafId(c, l)],
        state: state[_childId(c)] ?? GNodeState.normal,
      ),
    for (var c = 0; c < 3; c++)
      for (var l = 0; l < 3; l++)
        GTreeNode(
          id: _leafId(c, l),
          label: label[_leafId(c, l)] ?? '${_leaves[c][l]}',
          children: const [],
          state: state[_leafId(c, l)] ?? GNodeState.normal,
        ),
  ];
  return GTreeFrame(nodes: nodes, caption: caption);
}

/// Minimax — the maximiser and minimiser alternate, each assuming optimal play.
/// Leaves are evaluated, MIN nodes take the smallest child, the MAX root takes
/// the largest.
List<GTreeFrame> minimax() {
  final label = <int, String>{0: 'MAX', for (var c = 0; c < 3; c++) _childId(c): 'min'};
  final state = <int, GNodeState>{};
  final frames = <GTreeFrame>[_gameFrame(label: label, state: state, caption: 'Minimax: MAX wants the largest score, MIN the smallest.')];

  var rootBest = -1 << 30;
  var rootChoice = 0;
  for (var c = 0; c < 3; c++) {
    var minVal = 1 << 30;
    for (var l = 0; l < 3; l++) {
      state[_leafId(c, l)] = GNodeState.highlight;
      frames.add(_gameFrame(label: label, state: state, caption: 'Evaluate leaf ${_leaves[c][l]}.'));
      minVal = _leaves[c][l] < minVal ? _leaves[c][l] : minVal;
      state[_leafId(c, l)] = GNodeState.normal;
    }
    label[_childId(c)] = '$minVal';
    state[_childId(c)] = GNodeState.active;
    frames.add(_gameFrame(label: label, state: state, caption: 'MIN node takes the smallest child → $minVal.'));
    state[_childId(c)] = GNodeState.normal;
    if (minVal > rootBest) {
      rootBest = minVal;
      rootChoice = c;
    }
  }
  label[0] = '$rootBest';
  state[0] = GNodeState.good;
  state[_childId(rootChoice)] = GNodeState.good;
  frames.add(_gameFrame(label: label, state: state, caption: 'MAX picks the largest MIN value → $rootBest.'));
  return frames;
}

/// Alpha–Beta pruning — minimax that skips branches which cannot affect the
/// result, marking pruned leaves in grey.
List<GTreeFrame> alphaBeta() {
  final label = <int, String>{0: 'MAX', for (var c = 0; c < 3; c++) _childId(c): 'min'};
  final state = <int, GNodeState>{};
  final frames = <GTreeFrame>[_gameFrame(label: label, state: state, caption: 'Alpha–Beta prunes branches that cannot change the outcome.')];

  var alpha = -1 << 30;
  var rootChoice = 0;
  for (var c = 0; c < 3; c++) {
    var minVal = 1 << 30;
    var pruned = false;
    for (var l = 0; l < 3; l++) {
      if (pruned) {
        state[_leafId(c, l)] = GNodeState.pruned;
        frames.add(_gameFrame(label: label, state: state, caption: 'β ≤ α — prune the rest of this branch.'));
        continue;
      }
      state[_leafId(c, l)] = GNodeState.highlight;
      frames.add(_gameFrame(label: label, state: state, caption: 'Evaluate leaf ${_leaves[c][l]} (α=${alpha == -(1 << 30) ? '−∞' : alpha}).'));
      minVal = _leaves[c][l] < minVal ? _leaves[c][l] : minVal;
      state[_leafId(c, l)] = GNodeState.normal;
      if (minVal <= alpha) {
        pruned = true; // MAX already has a better option; cut.
      }
    }
    label[_childId(c)] = '$minVal';
    state[_childId(c)] = GNodeState.active;
    frames.add(_gameFrame(label: label, state: state, caption: 'MIN value here is $minVal.'));
    state[_childId(c)] = GNodeState.normal;
    if (minVal > alpha) {
      alpha = minVal;
      rootChoice = c;
    }
  }
  label[0] = '$alpha';
  state[0] = GNodeState.good;
  state[_childId(rootChoice)] = GNodeState.good;
  frames.add(_gameFrame(label: label, state: state, caption: 'Same answer as minimax ($alpha) with fewer evaluations.'));
  return frames;
}

/// Monte-Carlo Tree Search — repeatedly select a promising node, expand, run a
/// random rollout, and back-propagate the result, shown as wins/visits.
List<GTreeFrame> monteCarlo() {
  // Root with three move children; track wins/visits.
  final wins = List<int>.filled(3, 0);
  final visits = List<int>.filled(3, 0);
  // Deterministic pseudo-rollouts (precomputed outcomes per pick).
  const rollouts = [1, 1, 0, 1, 0, 1, 1, 1, 0, 1];
  const picks = [0, 1, 2, 0, 1, 0, 2, 0, 1, 0];

  GTreeFrame snap(String caption, {int? hot}) {
    var rv = 0, rw = 0;
    for (var i = 0; i < 3; i++) {
      rv += visits[i];
      rw += wins[i];
    }
    return GTreeFrame(
      nodes: [
        GTreeNode(id: 0, label: '$rw/$rv', children: const [1, 2, 3], state: GNodeState.good),
        for (var c = 0; c < 3; c++)
          GTreeNode(
            id: 1 + c,
            label: '${wins[c]}/${visits[c]}',
            children: const [],
            state: hot == c ? GNodeState.highlight : GNodeState.normal,
            edgeLabel: 'm$c',
          ),
      ],
      caption: caption,
    );
  }

  final frames = <GTreeFrame>[snap('MCTS: each child shows wins/visits; balance exploration & exploitation.')];
  for (var i = 0; i < picks.length; i++) {
    final c = picks[i];
    visits[c]++;
    wins[c] += rollouts[i];
    frames.add(snap('Iteration ${i + 1}: roll out move $c → ${rollouts[i] == 1 ? 'win' : 'loss'}.', hot: c));
  }
  var best = 0;
  for (var c = 1; c < 3; c++) {
    if (visits[c] > visits[best]) best = c;
  }
  frames.add(snap('Most-visited move ($best) is chosen as best.', hot: best));
  return frames;
}

/// Uniform Cost Search — expand the frontier node with the smallest cumulative
/// cost g, building a search tree until the goal is reached.
List<GTreeFrame> uniformCostSearch() {
  // Search tree: Start(0) → A(g1), B(g4); A → C(g3), G(g6); B → G(g5).
  // We expand by smallest g and stop when G is popped.
  final label = <int, String>{
    0: 'S g0',
    1: 'A g1',
    2: 'B g4',
    3: 'C g3',
    4: 'G g6',
    5: 'G g5',
  };
  GTreeFrame snap(Map<int, GNodeState> state, String caption) => GTreeFrame(
        nodes: [
          GTreeNode(id: 0, label: label[0]!, children: const [1, 2], state: state[0] ?? GNodeState.normal),
          GTreeNode(id: 1, label: label[1]!, children: const [3, 4], state: state[1] ?? GNodeState.normal),
          GTreeNode(id: 2, label: label[2]!, children: const [5], state: state[2] ?? GNodeState.normal),
          GTreeNode(id: 3, label: label[3]!, children: const [], state: state[3] ?? GNodeState.normal),
          GTreeNode(id: 4, label: label[4]!, children: const [], state: state[4] ?? GNodeState.normal),
          GTreeNode(id: 5, label: label[5]!, children: const [], state: state[5] ?? GNodeState.normal),
        ],
        caption: caption,
      );

  final frames = <GTreeFrame>[snap({0: GNodeState.active}, 'UCS expands the frontier node with the smallest cost g.')];
  frames.add(snap({0: GNodeState.good, 1: GNodeState.active}, 'Pop S; push A (g1) and B (g4). Smallest is A.'));
  frames.add(snap({0: GNodeState.good, 1: GNodeState.good, 3: GNodeState.highlight, 4: GNodeState.highlight, 2: GNodeState.normal}, 'Expand A; push C (g3) and G (g6).'));
  frames.add(snap({0: GNodeState.good, 1: GNodeState.good, 3: GNodeState.active}, 'Frontier {C g3, B g4, G g6}; smallest is C (g3).'));
  frames.add(snap({0: GNodeState.good, 1: GNodeState.good, 3: GNodeState.good, 2: GNodeState.active}, 'C is a dead end; expand B (g4), pushing G (g5).'));
  frames.add(snap({0: GNodeState.good, 1: GNodeState.good, 3: GNodeState.good, 2: GNodeState.good, 5: GNodeState.good}, 'Cheapest goal G is g5 via B — optimal path found.'));
  return frames;
}
