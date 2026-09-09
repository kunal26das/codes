import 'dart:ui' as ui;

import 'package:algoscope/algorithms/mathematics.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/visualizers/bars_view.dart';
import 'package:algoscope/visualizers/matrix_view.dart';
import 'package:algoscope/visualizers/table_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> render(WidgetTester tester, Widget view) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: SizedBox(width: 300, height: 190, child: view)),
      ),
    );
    expect(tester.takeException(), isNull);
  }

  void checkGeometry(WidgetTester tester, {int? textCount}) {
    final paints = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter != null,
    );
    var labels = 0;
    for (final element in paints.evaluate()) {
      final widget = element.widget as CustomPaint;
      final size = (element.renderObject as RenderBox).size;
      final recording = _MeasuringCanvas();
      widget.painter!.paint(recording, size);
      final rectangles = [...recording.labels];
      labels += recording.labels.length;
      for (final record in recording.invocations) {
        final call = record.invocation;
        Rect? rect;
        if (call.memberName == #drawRRect) {
          rect = (call.positionalArguments[0] as RRect).outerRect;
        } else if (call.memberName == #drawRect) {
          rect = call.positionalArguments[0] as Rect;
        }
        if (rect != null) rectangles.add(rect);
      }
      for (final rect in rectangles) {
        expect(rect.isFinite, isTrue);
        expect(rect.width, greaterThanOrEqualTo(0));
        expect(rect.height, greaterThanOrEqualTo(0));
        expect(rect.left, greaterThanOrEqualTo(-0.01));
        expect(rect.top, greaterThanOrEqualTo(-0.01));
        expect(rect.right, lessThanOrEqualTo(size.width + 0.01));
        expect(rect.bottom, lessThanOrEqualTo(size.height + 0.01));
      }
    }
    if (textCount != null) expect(labels, textCount);
  }

  testWidgets('long signed arrays retain every value and valid bar geometry', (
    tester,
  ) async {
    final values = [for (var i = 0; i < 100; i++) (i - 50) * 103];
    await render(tester, BarsView(frame: ArrayFrame(values: values)));
    checkGeometry(tester, textCount: values.length);
    expect(find.byTooltip('Zoom in; drag the diagram to pan'), findsOneWidget);
  });

  testWidgets(
    'dense tables keep numeric values and headers within their canvas',
    (tester) async {
      const rows = 12, cols = 14;
      await render(
        tester,
        TableView(
          frame: TableFrame(
            rows: rows,
            cols: cols,
            cells: List.generate(
              rows,
              (r) => List.generate(cols, (c) => r * 1000000 + c),
            ),
            rowHeader: List.generate(rows, (i) => 'Interval $i'),
            colHeader: List.generate(cols, (i) => 'Capacity $i'),
            filled: {for (var i = 0; i < rows * cols; i++) i},
          ),
        ),
      );
      checkGeometry(tester, textCount: rows * cols + rows + cols);
    },
  );

  testWidgets('all matrix multiplication frames fit their readable canvas', (
    tester,
  ) async {
    for (final frame in matrixMultiply()) {
      await render(tester, MatrixView(frame: frame));
      checkGeometry(tester);
    }
  });

  testWidgets('zoom buttons enlarge, reduce and restore the overview', (
    tester,
  ) async {
    await render(
      tester,
      BarsView(frame: ArrayFrame(values: [for (var i = 0; i < 40; i++) i])),
    );
    TransformationController controller() => tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer))
        .transformationController!;
    expect(controller().value.getMaxScaleOnAxis(), 1);
    await tester.tap(find.byTooltip('Zoom in; drag the diagram to pan'));
    await tester.pump();
    expect(controller().value.getMaxScaleOnAxis(), closeTo(1.5, 0.001));
    await tester.tap(find.byTooltip('Zoom in; drag the diagram to pan'));
    await tester.pump();
    expect(controller().value.getMaxScaleOnAxis(), closeTo(2.25, 0.001));
    await tester.tap(find.byTooltip('Zoom out'));
    await tester.pump();
    expect(controller().value.getMaxScaleOnAxis(), closeTo(1.5, 0.001));
    await tester.tap(find.byTooltip('Fit diagram'));
    await tester.pump();
    expect(controller().value, Matrix4.identity());
    expect(tester.takeException(), isNull);
  });
}

class _MeasuringCanvas extends TestRecordingCanvas {
  final labels = <Rect>[];

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {
    // Measure before the painter releases the paragraph's native resources.
    labels.add(offset & Size(paragraph.longestLine, paragraph.height));
  }
}
