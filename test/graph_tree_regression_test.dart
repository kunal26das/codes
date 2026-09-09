import 'package:algoscope/algorithms/datastructures.dart';
import 'package:algoscope/algorithms/graphs.dart';
import 'package:algoscope/algorithms/pathfinding.dart';
import 'package:algoscope/algorithms/tree.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/visualizers/graph_view.dart';
import 'package:algoscope/visualizers/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _checkTree(TreeFrame frame) {
  final nodes = {for (final node in frame.nodes) node.id: node};
  expect(nodes.length, frame.nodes.length, reason: 'Node IDs must be unique.');
  final visited = <int>{};
  final values = <int>[];
  void walk(int? id) {
    if (id == null) return;
    expect(nodes, contains(id), reason: frame.caption);
    expect(visited.add(id), isTrue, reason: 'A tree cannot revisit a node.');
    final node = nodes[id]!;
    walk(node.left);
    values.add(node.value);
    walk(node.right);
  }

  walk(frame.rootId);
  expect(visited, nodes.keys.toSet(), reason: 'Every node must be connected.');
  expect(visited.containsAll(frame.highlight), isTrue);
  return values;
}

Future<void> _paintTree(WidgetTester tester, TreeFrame frame) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SizedBox(width: 600, height: 400, child: TreeView(frame: frame)),
    ),
  );
  expect(tester.takeException(), isNull, reason: frame.caption);
}

void main() {
  testWidgets(
    'BST deletion keeps every frame connected for all deletion cases',
    (tester) async {
      for (final (values, target) in <(List<int>, int)>[
        ([50, 30, 70, 20, 40], 20), // Leaf.
        ([50, 30, 70, 20], 30), // One child.
        ([50, 30, 70, 20, 40], 30), // Two children, direct successor.
        ([50, 30, 80, 60, 70, 90], 50), // Root; successor has a child.
        ([50, 30], 50), // Root with one child.
        ([50], 50), // Last node.
        ([5, 5, 4, 6], 5), // Remove only one duplicate.
        ([50, 30, 70], 99), // Absent target.
      ]) {
        final frames = bstDelete(values, target);
        for (final frame in frames) {
          _checkTree(frame);
          await _paintTree(tester, frame);
        }
        final expected = [...values]
          ..remove(target)
          ..sort();
        expect(_checkTree(frames.last), expected);
      }
    },
  );

  testWidgets('all segment-tree construction frames are connected and paint', (
    tester,
  ) async {
    final frames = segmentTree();
    for (final frame in frames) {
      _checkTree(frame);
      await _paintTree(tester, frame);
    }
    final nodes = {for (final node in frames.last.nodes) node.id: node};
    final leaves = <int>[];
    int sum(int id) {
      final node = nodes[id]!;
      if (node.left == null && node.right == null) {
        leaves.add(node.value);
        return node.value;
      }
      final expected = sum(node.left!) + sum(node.right!);
      expect(node.value, expected);
      return expected;
    }

    expect(sum(frames.last.rootId!), 21);
    expect(leaves, [2, 1, 5, 3, 4, 6]);
  });

  test(
    'directed identities distinguish endpoints and preserve undirected keys',
    () {
      expect(const GraphEdge(1, 3, 5).key, const GraphEdge(3, 1, -2).key);
      expect(const GraphEdge(1, 3, 5).key, 103);
      expect(
        const GraphEdge.directed(1, 3, 5).key,
        isNot(const GraphEdge.directed(3, 1, -2).key),
      );
      for (final run in [
        topologicalSort(),
        cycleDetection(),
        bellmanFord(),
        unionFind(),
      ]) {
        final keys = run.edges.map((edge) => edge.key).toSet();
        expect(keys.length, run.edges.length);
        expect(run.edges.every((edge) => edge.directed), isTrue);
        for (final frame in run.frames) {
          expect(keys.containsAll(frame.treeEdges), isTrue);
          if (frame.candidate != null) {
            expect(
              run.edges.where((edge) => edge.key == frame.candidate).length,
              1,
            );
          }
        }
      }
      final bellman = bellmanFord();
      final relax = bellman.frames.firstWhere(
        (frame) => frame.caption.contains('relax B→D'),
      );
      final edge = bellman.edges.singleWhere(
        (edge) => edge.key == relax.candidate,
      );
      expect((edge.a, edge.b, edge.w), (1, 3, 5));
      expect(bellman.frames.last.dist, {0: 0, 1: 2, 2: 7, 3: 4, 4: -2});
      expect(bellman.weighted, isTrue);
      expect(topologicalSort().weighted, isFalse);
      for (final mst in [primDemo(), kruskalDemo()]) {
        expect(mst.weighted, isTrue);
        final weight = mst.edges
            .where((edge) => mst.frames.last.treeEdges.contains(edge.key))
            .fold<int>(0, (sum, edge) => sum + edge.w);
        expect(weight, 18);
      }
    },
  );

  test('union-find visibly shortens a deep path without changing its root', () {
    final run = unionFind();
    final at = run.frames.indexWhere(
      (frame) => frame.caption.startsWith('Compress the path:'),
    );
    expect(at, greaterThan(0));
    Map<int, int> parents(GraphFrame frame) => {
      for (final edge in run.edges)
        if (frame.treeEdges.contains(edge.key)) edge.a: edge.b,
    };
    final before = parents(run.frames[at - 1]);
    final after = parents(run.frames[at]);
    expect(before[3], 2);
    expect(before[2], 0);
    expect(after[3], 0);
    expect(after[2], 0);
    final last = parents(run.frames.last);
    for (var node = 0; node < run.nodeLabels.length; node++) {
      var root = node;
      final seen = <int>{};
      while (last.containsKey(root)) {
        expect(seen.add(root), isTrue);
        root = last[root]!;
      }
      expect(root, 0);
    }
  });

  test('only searches that guarantee optimality claim a shortest path', () {
    final shortest = bfsDemo(seed: 0).frames.last;
    expect(shortest.path.length - 1, 25);
    for (final run in [astarDemo(seed: 0), dijkstraDemo(seed: 0)]) {
      expect(run.frames.last.path.length, shortest.path.length);
      expect(run.frames.last.caption, startsWith('Shortest path found'));
    }
    for (final run in [dfsDemo(seed: 0), greedyBestFirstDemo(seed: 0)]) {
      final result = run.frames.last;
      expect(result.path.length, greaterThan(shortest.path.length));
      expect(result.caption, startsWith('Path found'));
      expect(result.path.first, run.start);
      expect(result.path.last, run.goal);
      for (var i = 1; i < result.path.length; i++) {
        final a = result.path[i - 1], b = result.path[i];
        expect(
          (a ~/ run.cols - b ~/ run.cols).abs() +
              (a % run.cols - b % run.cols).abs(),
          1,
        );
        expect(run.walls, isNot(contains(b)));
      }
    }
  });

  testWidgets('union-find draws only the current parent pointers', (
    tester,
  ) async {
    final run = unionFind();
    for (final frame in [run.frames.first, run.frames.last]) {
      await tester.pumpWidget(
        MaterialApp(
          home: GraphView(run: run, frame: frame),
        ),
      );
      final paintFinder = find.descendant(
        of: find.byType(GraphView),
        matching: find.byType(CustomPaint),
      );
      final painter = tester.widget<CustomPaint>(paintFinder).painter!;
      final canvas = TestRecordingCanvas();
      painter.paint(canvas, const Size(600, 400));
      final arrows = canvas.invocations.where(
        (record) => record.invocation.memberName == #drawPath,
      );
      expect(arrows.length, frame.treeEdges.length);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('opposite arrows have separate curves, weights and highlighting', (
    tester,
  ) async {
    const edges = [GraphEdge.directed(0, 1, 5), GraphEdge.directed(1, 0, -2)];
    final frame = GraphFrame(candidate: edges.first.key);
    final run = GraphRun(
      nodeLabels: const ['A', 'B'],
      positions: const [
        [0, 0.5],
        [1, 0.5],
      ],
      edges: edges,
      frames: [frame],
      directed: true,
      weighted: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: GraphView(run: run, frame: frame),
      ),
    );
    expect(tester.takeException(), isNull);
    final paintFinder = find.descendant(
      of: find.byType(GraphView),
      matching: find.byType(CustomPaint),
    );
    final painter = tester.widget<CustomPaint>(paintFinder).painter!;
    final canvas = TestRecordingCanvas();
    painter.paint(canvas, const Size(600, 300));
    final invocations = canvas.invocations
        .map((record) => record.invocation)
        .toList();
    final curves = invocations
        .where(
          (call) =>
              call.memberName == #drawPath &&
              (call.positionalArguments[1] as Paint).style ==
                  PaintingStyle.stroke,
        )
        .toList();
    expect(curves.length, 2);
    final bounds = curves
        .map((call) => (call.positionalArguments[0] as Path).getBounds())
        .toList();
    expect(bounds[0].center.dy, greaterThan(150));
    expect(bounds[1].center.dy, lessThan(150));
    expect(
      curves.map((call) => (call.positionalArguments[1] as Paint).strokeWidth),
      [4, 2],
    );
    // Two edge weights plus two node labels. Unweighted arrows used to omit both weights.
    expect(
      invocations.where((call) => call.memberName == #drawParagraph).length,
      4,
    );
    final labelBoxes = invocations
        .where((call) => call.memberName == #drawRRect)
        .map((call) => (call.positionalArguments[0] as RRect).outerRect)
        .toList();
    expect(labelBoxes.length, 2);
    expect(labelBoxes.first.overlaps(labelBoxes.last), isFalse);
  });

  testWidgets(
    'Bellman-Ford keeps readable graph bounds in phone and desktop viewports',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final run = bellmanFord();
      for (final viewport in [const Size(300, 120), const Size(900, 500)]) {
        await tester.binding.setSurfaceSize(viewport);
        for (final frame in [run.frames.first, run.frames.last]) {
          await tester.pumpWidget(
            MaterialApp(
              home: GraphView(run: run, frame: frame),
            ),
          );
          expect(tester.takeException(), isNull);
          final paintFinder = find.byKey(const ValueKey('graph-canvas'));
          final size = tester.getSize(paintFinder);
          expect(size, viewport.width < 600 ? const Size(600, 400) : viewport);
          expect(find.byType(InteractiveViewer), findsOneWidget);
          expect(
            find.byTooltip('Zoom in; drag the diagram to pan'),
            viewport.width < 600 ? findsOneWidget : findsNothing,
          );
          final painter = tester.widget<CustomPaint>(paintFinder).painter!;
          final canvas = TestRecordingCanvas();
          painter.paint(canvas, size);
          final invocations = canvas.invocations
              .map((record) => record.invocation)
              .toList();
          expect(
            invocations
                .where((call) => call.memberName == #drawParagraph)
                .length,
            run.edges.length + run.nodeLabels.length * 2,
          );
          final labels = invocations
              .where((call) => call.memberName == #drawRRect)
              .map((call) => (call.positionalArguments[0] as RRect).outerRect)
              .toList();
          expect(labels.length, run.edges.length + run.nodeLabels.length);
          final nodes = invocations
              .where((call) => call.memberName == #drawCircle)
              .map(
                (call) => Rect.fromCircle(
                  center: call.positionalArguments[0] as Offset,
                  radius: call.positionalArguments[1] as double,
                ),
              )
              .toSet();
          expect(nodes.length, run.nodeLabels.length);
          final bounds = Offset.zero & size;
          for (final rect in [...labels, ...nodes]) {
            expect(bounds.contains(rect.topLeft), isTrue);
            expect(bounds.contains(rect.bottomRight), isTrue);
          }
          for (var i = 0; i < labels.length; i++) {
            for (var j = i + 1; j < labels.length; j++) {
              expect(
                labels[i].overlaps(labels[j]),
                isFalse,
                reason: 'Graph labels $i and $j must remain readable.',
              );
            }
            for (final node in nodes) {
              expect(
                labels[i].overlaps(node),
                isFalse,
                reason: 'Labels must not cover node circles.',
              );
            }
          }
        }
      }
    },
  );
}
