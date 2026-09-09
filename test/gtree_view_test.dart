import 'package:algoscope/algorithms/ai.dart';
import 'package:algoscope/algorithms/heaps_trees.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/visualizers/gtree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> render(WidgetTester tester, GTreeFrame frame, Size size) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox.fromSize(size: size, child: GTreeView(frame: frame)),
      ),
    ));
    expect(tester.takeException(), isNull);
  }

  testWidgets('crowded tree nodes and edge labels remain separate and in bounds',
      (tester) async {
    for (final size in [const Size(300, 190), const Size(1100, 600)]) {
      for (final frame in [
        monteCarlo().first,
        monteCarlo().last,
        minimax().last,
        bTree().last,
        karyHeap().last,
      ]) {
        await render(tester, frame, size);
        final canvasFinder = find.byKey(const ValueKey('general-tree-canvas'));
        final canvasSize = tester.getSize(canvasFinder);
        final painter = tester.widget<CustomPaint>(canvasFinder).painter!;
        final canvas = TestRecordingCanvas();
        painter.paint(canvas, canvasSize);
        final calls = canvas.invocations.map((record) => record.invocation);
        final nodes = calls
            .where((call) =>
                call.memberName == #drawRRect &&
                (call.positionalArguments[1] as Paint).style ==
                    PaintingStyle.stroke)
            .map((call) => (call.positionalArguments[0] as RRect).outerRect)
            .toList();
        expect(nodes.length, frame.nodes.length);
        final labelCount = frame.nodes.where((n) => n.edgeLabel != null).length;
        final labels = calls
            .where((call) => call.memberName == #drawRRect)
            .take(labelCount)
            .map((call) => (call.positionalArguments[0] as RRect).outerRect)
            .toList();
        final boxes = [...nodes, ...labels];
        for (var i = 0; i < boxes.length; i++) {
          expect(boxes[i].left, greaterThanOrEqualTo(0));
          expect(boxes[i].right, lessThanOrEqualTo(canvasSize.width));
          expect(boxes[i].top, greaterThanOrEqualTo(0));
          expect(boxes[i].bottom, lessThanOrEqualTo(canvasSize.height));
          for (var j = i + 1; j < boxes.length; j++) {
            expect(boxes[i].overlaps(boxes[j]), isFalse,
                reason: '${frame.caption}: labels $i and $j overlap at $size');
          }
        }
      }
    }
  });

  testWidgets('phone overview can be pinched to read and dragged to inspect',
      (tester) async {
    await render(tester, monteCarlo().last, const Size(300, 190));
    final viewer = find.byType(InteractiveViewer);
    final transform = find.descendant(
      of: viewer,
      matching: find.byType(Transform),
    ).first;
    Matrix4 matrix() => tester.widget<Transform>(transform).transform;
    final center = tester.getCenter(viewer);
    final left = await tester.startGesture(center + const Offset(-25, 0), pointer: 1);
    final right = await tester.startGesture(center + const Offset(25, 0), pointer: 2);
    await left.moveTo(center + const Offset(-70, 0));
    await right.moveTo(center + const Offset(70, 0));
    await tester.pump();
    await left.up();
    await right.up();
    expect(matrix().getMaxScaleOnAxis(), greaterThan(1));

    final before = matrix().getTranslation();
    await tester.drag(viewer, const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(matrix().getTranslation(), isNot(before));
    expect(tester.takeException(), isNull);
  });
}
