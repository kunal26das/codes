import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoscope/data/catalog.dart';
import 'package:algoscope/models/viz_run.dart';
import 'package:algoscope/visualizers/genetic_view.dart';
import 'package:algoscope/visualizers/swarm_view.dart';
import 'package:algoscope/visualizers/tsp_view.dart';

// Compare the visible input and search state, not widget identity or captions.
List<Object> visibleStates(VizRun run, BuildContext context) {
  return List.generate(run.frameCount, (i) {
    final view = run.builder(context, i);
    if (view is GeneticView) {
      return [view.frame.population, view.frame.fitness];
    }
    if (view is TspView) {
      return [view.frame.tour, view.frame.pheromone];
    }
    if (view is SwarmView) {
      return [view.frame.particles, view.frame.bestPos];
    }
    throw StateError('Unexpected optimization visualizer: ${view.runtimeType}');
  });
}

void main() {
  for (final id in [
    'genetic-algorithm',
    'ant-colony',
    'particle-swarm',
    'simulated-annealing',
    'hill-climbing',
    'artificial-bee-colony',
    'firefly',
    'cuckoo-search',
  ]) {
    testWidgets('$id creates a fresh optimization run', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      );
      final algo = catalog.firstWhere((entry) => entry.id == id);
      final first = visibleStates(algo.create(), context);
      final second = visibleStates(algo.create(), context);
      expect(
        second,
        isNot(equals(first)),
        reason: 'New input should change the search state.',
      );
    });
  }
}
