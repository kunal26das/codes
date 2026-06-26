// UI / integration tests for AlgoScope.
//
// Exercises the home screen, navigation into the player, every algorithm's
// visualizer, and the playback controls (play/pause/step/restart/reroll).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:algoscope/main.dart';
import 'package:algoscope/data/catalog.dart';
import 'package:algoscope/models/algorithm.dart';
import 'package:algoscope/screens/algorithm_screen.dart';
import 'package:algoscope/theme/app_theme.dart';

void main() {
  // Never hit the network for fonts in tests — fall back to the bundled font.
  // Without this google_fonts spawns HTTP timers that leak past the test.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Render at a desktop size so the wide two-pane player layout is used and
  // every card/section is laid out.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(1500, 16000);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget wrapScreen(Widget child) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: child,
      );

  group('home screen', () {
    testWidgets('boots and shows branding + hero', (tester) async {
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pump();

      expect(find.text('AlgoScope'), findsOneWidget);
      expect(find.text('Algorithms, in motion.'), findsOneWidget);
    });

    testWidgets('lists every category label', (tester) async {
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pump();

      for (final category in AlgoCategory.values) {
        expect(find.text(category.label), findsWidgets,
            reason: 'category ${category.label} should be on the home screen');
      }
    });

    testWidgets('lists every algorithm in the catalog', (tester) async {
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pump();

      for (final algo in catalog) {
        expect(find.text(algo.name), findsWidgets,
            reason: '${algo.name} card should be visible');
      }
    });

    testWidgets('theme cycles System → Light → Dark → System', (tester) async {
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pump();

      // Defaults to following the OS.
      expect(find.byTooltip('Theme: System (tap for Light)'), findsOneWidget);
      await tester.tap(find.byTooltip('Theme: System (tap for Light)'));
      await tester.pump();
      expect(find.byTooltip('Theme: Light (tap for Dark)'), findsOneWidget);
      await tester.tap(find.byTooltip('Theme: Light (tap for Dark)'));
      await tester.pump();
      expect(find.byTooltip('Theme: Dark (tap for System)'), findsOneWidget);
      await tester.tap(find.byTooltip('Theme: Dark (tap for System)'));
      await tester.pump();
      expect(find.byTooltip('Theme: System (tap for Light)'), findsOneWidget);
    });

    testWidgets('tapping a card opens the player screen', (tester) async {
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pump();

      final card = find.text('Bubble Sort');
      await tester.ensureVisible(card);
      await tester.pump();
      await tester.tap(card);
      await tester.pumpAndSettle();

      // Player screen shows the detail panel.
      expect(find.text('How it works'), findsOneWidget);
      expect(find.text('New input'), findsOneWidget);
    });
  });

  group('player renders every algorithm', () {
    for (final algo in catalog) {
      testWidgets('${algo.name} renders, plays, steps and rerolls',
          (tester) async {
        await tester.pumpWidget(wrapScreen(AlgorithmScreen(info: algo)));
        await tester.pump();

        // Title + description present.
        expect(find.text(algo.name), findsWidgets);
        expect(find.text(algo.description), findsOneWidget);

        // Frame counter starts at frame 1.
        expect(find.textContaining('1/'), findsWidgets);

        // Step forward advances the frame.
        final stepFwd = find.byIcon(Icons.skip_next_rounded);
        await tester.tap(stepFwd);
        await tester.pump();
        expect(find.textContaining('2/'), findsWidgets);

        // Step back returns to frame 1.
        await tester.tap(find.byIcon(Icons.skip_previous_rounded));
        await tester.pump();
        expect(find.textContaining('1/'), findsWidgets);

        // Play, let a couple frames tick, then pause. (Short runs may reach the
        // end and auto-pause before we get there — handle both cases.)
        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        await tester.pump();
        expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 300));
        if (find.byIcon(Icons.pause_rounded).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.pause_rounded));
          await tester.pump();
        }
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

        // Restart returns to frame 1.
        await tester.tap(find.byIcon(Icons.replay_rounded).first);
        await tester.pump();
        expect(find.textContaining('1/'), findsWidgets);

        // Reroll builds a fresh run without throwing.
        await tester.tap(find.text('New input'));
        await tester.pump();
        expect(find.textContaining('1/'), findsWidgets);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('catalog integrity', () {
    test('every entry builds a non-empty run with captions', () {
      expect(catalog, isNotEmpty);
      final ids = <String>{};
      for (final algo in catalog) {
        expect(ids.add(algo.id), isTrue, reason: 'duplicate id ${algo.id}');
        expect(algo.name, isNotEmpty);
        expect(algo.originalSources, isNotEmpty);

        final run = algo.create();
        expect(run.frameCount, greaterThan(0),
            reason: '${algo.name} produced no frames');
        for (var i = 0; i < run.frameCount; i++) {
          expect(run.captionAt(i), isNotEmpty,
              reason: '${algo.name} frame $i has an empty caption');
        }
      }
    });

    test('catalogByCategory groups every algorithm exactly once', () {
      final grouped = catalogByCategory;
      final total = grouped.values.fold<int>(0, (s, l) => s + l.length);
      expect(total, catalog.length);
    });
  });
}
