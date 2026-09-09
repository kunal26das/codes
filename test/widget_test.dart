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

  // Use an ordinary desktop viewport; search and scrolling must work without
  // relying on an artificially tall screen to mount the entire catalog.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(1500, 900);
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

  int currentFrame(WidgetTester tester) {
    final counter = tester.widget<Text>(
        find.byKey(const ValueKey('player-frame-counter')));
    return int.parse(RegExp(r'^\d+').stringMatch(counter.data!)!);
  }

  final playPause = find.byKey(const ValueKey('player-play-pause'));

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

    testWidgets('every algorithm is discoverable through search', (tester) async {
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pump();

      for (final algo in catalog) {
        await tester.enterText(find.byType(TextField), algo.name);
        await tester.pump();
        expect(find.text(algo.name), findsWidgets,
            reason: '${algo.name} card should be found by search');
      }
    });

    testWidgets('theme follows changes to system brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(const AlgoScopeApp());
      await tester.pumpAndSettle();

      Brightness brightness() =>
          Theme.of(tester.element(find.text('AlgoScope'))).brightness;
      expect(brightness(), Brightness.light);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.dark);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.light);
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
        expect(currentFrame(tester), 1);

        // Step forward advances the frame.
        final stepFwd = find.byIcon(Icons.skip_next_rounded);
        await tester.tap(stepFwd);
        await tester.pump();
        expect(currentFrame(tester), 2);

        // Step back returns to frame 1.
        await tester.tap(find.byIcon(Icons.skip_previous_rounded));
        await tester.pump();
        expect(currentFrame(tester), 1);

        // Play, let a couple frames tick, then pause. (Short runs may reach the
        // end and auto-pause before we get there — handle both cases.)
        await tester.tap(playPause);
        await tester.pump();
        expect(find.byTooltip('Pause (Space)'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 300));
        expect(currentFrame(tester), greaterThan(1));
        if (find.byTooltip('Pause (Space)').evaluate().isNotEmpty) {
          await tester.tap(playPause);
          await tester.pumpAndSettle();
        }
        expect(find.byTooltip('Play (Space)'), findsOneWidget);

        // Restart returns to frame 1.
        await tester.tap(find.byIcon(Icons.replay_rounded).first);
        await tester.pump();
        expect(currentFrame(tester), 1);

        // Reroll builds a fresh run without throwing.
        await tester.tap(find.text('New input'));
        await tester.pump();
        expect(currentFrame(tester), 1);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('phone playback', () {
    for (final size in [const Size(360, 800), const Size(390, 844)]) {
      testWidgets('all controls fit and work at $size', (tester) async {
        tester.view.physicalSize = size;
        await tester.pumpWidget(wrapScreen(AlgorithmScreen(
          info: catalog.firstWhere((a) => a.id == 'bubble-sort'),
        )));
        await tester.pump();
        expect(tester.takeException(), isNull);

        for (final label in ['0.5×', '1×', '2×', '4×']) {
          final chip = find.text(label);
          expect(chip.hitTestable(), findsOneWidget);
          final bounds = tester.getRect(chip);
          expect(bounds.left, greaterThanOrEqualTo(16));
          expect(bounds.right, lessThanOrEqualTo(size.width - 16));
        }

        await tester.tap(find.text('0.5×'));
        await tester.tap(playPause);
        await tester.pump(const Duration(milliseconds: 1000));
        expect(currentFrame(tester), 1);
        await tester.pump(const Duration(milliseconds: 300));
        expect(currentFrame(tester), 2);

        await tester.tap(playPause);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        expect(currentFrame(tester), 2);

        await tester.tap(find.byIcon(Icons.skip_previous_rounded));
        await tester.pump();
        expect(currentFrame(tester), 1);
        await tester.tap(find.byIcon(Icons.skip_next_rounded));
        await tester.pump();
        expect(currentFrame(tester), 2);
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
