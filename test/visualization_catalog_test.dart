import 'package:algoscope/data/catalog.dart';
import 'package:algoscope/models/algorithm.dart';
import 'package:algoscope/models/viz_run.dart';
import 'package:algoscope/screens/algorithm_screen.dart';
import 'package:algoscope/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// These tests intentionally visit every generated frame. An opening-frame
/// smoke test misses later table fills, growing lists, and final result labels.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  var totalFrames = 0;
  var renderedAlgorithms = 0;

  tearDownAll(() {
    // This also gives CI a useful measure of animation coverage as the catalog
    // grows. Each frame is laid out and painted in all four configurations.
    if (renderedAlgorithms == 0) return;
    debugPrint(
      'CATALOG COVERAGE: $renderedAlgorithms algorithms, '
      '$totalFrames generated frames, ${totalFrames * 4} frame renders.',
    );
    if (renderedAlgorithms == catalog.length) {
      debugPrint(
        'CATEGORY COUNTS: ${catalogByCategory.map((category, algorithms) => MapEntry(category.label, algorithms.length))}',
      );
    }
  });

  for (final info in catalog) {
    testWidgets(
      '${info.id}: every frame paints on phone and desktop in both themes',
      (tester) async {
        final run = info.create();
        totalFrames += run.frameCount;
        renderedAlgorithms++;
        expect(run.frameCount, greaterThan(1));
        final index = ValueNotifier(0);
        addTearDown(index.dispose);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1;

        for (final size in [const Size(300, 190), const Size(1100, 600)]) {
          tester.view.physicalSize = size;
          for (final brightness in Brightness.values) {
            index.value = 0;
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(brightness: brightness),
                home: Scaffold(
                  body: ValueListenableBuilder<int>(
                    valueListenable: index,
                    builder: (context, frame, _) => run.builder(context, frame),
                  ),
                ),
              ),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '${info.id} opening frame, $size, $brightness',
            );
            for (var frame = 0; frame < run.frameCount; frame++) {
              expect(
                run.captionAt(frame).trim(),
                isNotEmpty,
                reason: '${info.id} frame $frame must explain its state',
              );
              index.value = frame;
              await tester.pump();
              expect(
                tester.takeException(),
                isNull,
                reason: '${info.id} frame $frame, $size, $brightness',
              );
            }
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '${info.id}: full player handles key frames and longest caption',
      (tester) async {
        final run = info.create();
        var longest = 0;
        for (var i = 1; i < run.frameCount; i++) {
          if (run.captionAt(i).length > run.captionAt(longest).length) {
            longest = i;
          }
        }
        final frames = {0, run.frameCount ~/ 2, run.frameCount - 1, longest};
        final frozen = _withRun(info, run);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1;
        for (final (size, textScale) in [
          (const Size(360, 800), 1.0),
          (const Size(1280, 800), 1.0),
          (const Size(390, 844), 1.4),
          (const Size(800, 360), 1.2),
        ]) {
          tester.view.physicalSize = size;
          for (final brightness in Brightness.values) {
            await tester.pumpWidget(
              MaterialApp(
                theme: brightness == Brightness.dark
                    ? AppTheme.dark
                    : AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: AlgorithmScreen(key: UniqueKey(), info: frozen),
              ),
            );
            for (final frame in frames) {
              tester.widget<Slider>(find.byType(Slider)).onChanged!(
                frame.toDouble(),
              );
              await tester.pump();
              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${info.id} player frame $frame, $size, $brightness, text $textScale',
              );
              expect(find.text(run.captionAt(frame)), findsOneWidget);
              expect(
                tester
                    .widget<Text>(
                      find.byKey(const ValueKey('player-frame-counter')),
                    )
                    .data,
                '${frame + 1} / ${run.frameCount}',
              );
            }
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      },
    );
  }
}

AlgorithmInfo _withRun(AlgorithmInfo info, VizRun run) => AlgorithmInfo(
  id: info.id,
  name: info.name,
  category: info.category,
  blurb: info.blurb,
  description: info.description,
  timeComplexity: info.timeComplexity,
  spaceComplexity: info.spaceComplexity,
  originalSources: info.originalSources,
  create: () => run,
);
