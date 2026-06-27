import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/algorithm.dart';
import '../models/viz_run.dart';
import '../theme/app_colors.dart';
import '../widgets/ui.dart';

class AlgorithmScreen extends StatefulWidget {
  const AlgorithmScreen({super.key, required this.info});

  final AlgorithmInfo info;

  @override
  State<AlgorithmScreen> createState() => _AlgorithmScreenState();
}

class _AlgorithmScreenState extends State<AlgorithmScreen> {
  late VizRun _run;
  int _frame = 0;
  bool _playing = false;
  double _speed = 4;
  Timer? _timer;
  final FocusNode _focusNode = FocusNode();

  static const _speeds = [0.5, 1.0, 2.0, 4.0];

  @override
  void initState() {
    super.initState();
    _run = widget.info.create();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  /// Keyboard shortcuts: space toggles play, ← / → step, R restarts,
  /// N rolls a new input, Home / End jump to the ends.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space) {
      _toggle();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _step(1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.keyR) {
      _restart();
    } else if (key == LogicalKeyboardKey.keyN) {
      _reroll();
    } else if (key == LogicalKeyboardKey.home) {
      _pause();
      setState(() => _frame = 0);
    } else if (key == LogicalKeyboardKey.end) {
      _pause();
      setState(() => _frame = _last);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  int get _last => _run.frameCount - 1;

  void _startTimer() {
    _timer?.cancel();
    final ms = (650 / _speed).round();
    _timer = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (_frame >= _last) {
        _pause();
      } else {
        setState(() => _frame++);
      }
    });
  }

  void _play() {
    if (_frame >= _last) _frame = 0;
    setState(() => _playing = true);
    _startTimer();
  }

  void _pause() {
    _timer?.cancel();
    if (mounted) setState(() => _playing = false);
  }

  void _toggle() => _playing ? _pause() : _play();

  void _step(int delta) {
    _pause();
    setState(() => _frame = (_frame + delta).clamp(0, _last));
  }

  void _restart() {
    _pause();
    setState(() => _frame = 0);
  }

  void _reroll() {
    _pause();
    setState(() {
      _run = widget.info.create();
      _frame = 0;
    });
  }

  void _setSpeed(double s) {
    setState(() => _speed = s);
    if (_playing) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: GlassPanel(
          radius: 0,
          settings: Glass.settings(context, thickness: 12, blur: 4),
          child: const SizedBox.expand(),
        ),
        title: Text(info.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Keyboard shortcuts',
            icon: const Icon(Icons.keyboard_outlined, size: 20),
            onPressed: () => _showShortcuts(context),
          ),
          TextButton.icon(
            onPressed: _reroll,
            icon: const Icon(Icons.casino_outlined, size: 18),
            label: const Text('New input'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassScaffoldBackground(
        accents: [
          info.category.color,
          AppColors.highlight,
          AppColors.done,
        ],
        child: Focus(
          focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: SafeArea(
          child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final player = _PlayerColumn(
              run: _run,
              frame: _frame,
              playing: _playing,
              speed: _speed,
              speeds: _speeds,
              category: info.category,
              onToggle: _toggle,
              onStep: _step,
              onRestart: _restart,
              onSeek: (v) {
                _pause();
                setState(() => _frame = v.round());
              },
              onSpeed: _setSpeed,
            );
            final details = _DetailsPanel(info: info);
            if (wide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1700),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: player),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 300,
                          child: SingleChildScrollView(child: details),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 480, child: player),
                  const SizedBox(height: 20),
                  details,
                ],
              ),
            );
          },
        ),
      ),
      ),
      ),
    );
  }

  void _showShortcuts(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        Widget row(String keys, String action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Text(keys,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.textTheme.bodyLarge?.color)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(action, style: theme.textTheme.bodyMedium)),
                ],
              ),
            );
        return AlertDialog(
          title: const Text('Keyboard shortcuts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row('Space', 'Play / pause'),
              row('← / →', 'Step back / forward'),
              row('Home / End', 'Jump to start / end'),
              row('R', 'Restart from frame 1'),
              row('N', 'Roll a new random input'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it')),
          ],
        );
      },
    );
  }
}

class _PlayerColumn extends StatelessWidget {
  const _PlayerColumn({
    required this.run,
    required this.frame,
    required this.playing,
    required this.speed,
    required this.speeds,
    required this.category,
    required this.onToggle,
    required this.onStep,
    required this.onRestart,
    required this.onSeek,
    required this.onSpeed,
  });

  final VizRun run;
  final int frame;
  final bool playing;
  final double speed;
  final List<double> speeds;
  final AlgoCategory category;
  final VoidCallback onToggle;
  final void Function(int delta) onStep;
  final VoidCallback onRestart;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onSpeed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = run.frameCount - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: run.builder(context, frame),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Legend(category: category),
        const SizedBox(height: 10),
        // Caption for the current step.
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${frame + 1} / ${run.frameCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  run.captionAt(frame),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.textTheme.bodyLarge?.color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: frame.toDouble().clamp(0, last.toDouble()),
            min: 0,
            max: last == 0 ? 1 : last.toDouble(),
            divisions: last == 0 ? null : last,
            label: '${frame + 1}',
            onChanged: onSeek,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            IconButton(
              tooltip: 'Restart  (R)',
              onPressed: onRestart,
              icon: const Icon(Icons.replay_rounded),
            ),
            IconButton(
              tooltip: 'Step back  (←)',
              onPressed: frame == 0 ? null : () => onStep(-1),
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            const SizedBox(width: 2),
            FilledButton(
              onPressed: onToggle,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  key: ValueKey(playing),
                ),
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              tooltip: 'Step forward  (→)',
              onPressed: frame >= last ? null : () => onStep(1),
              icon: const Icon(Icons.skip_next_rounded),
            ),
            const Spacer(),
            for (final s in speeds)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _SpeedChip(
                  label: '${s == s.roundToDouble() ? s.toInt() : s}×',
                  selected: s == speed,
                  onTap: () => onSpeed(s),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? c.withValues(alpha: 0.4) : theme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? c : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.category});
  final AlgoCategory category;

  @override
  Widget build(BuildContext context) {
    final dots = _dotsFor(category);
    return Wrap(spacing: 16, runSpacing: 8, children: dots);
  }

  List<Widget> _dotsFor(AlgoCategory category) {
    switch (category) {
      case AlgoCategory.sorting:
        return const [
          LegendDot(color: AppColors.compare, label: 'Comparing'),
          LegendDot(color: AppColors.active, label: 'Swapping'),
          LegendDot(color: AppColors.highlight, label: 'Pivot / range'),
          LegendDot(color: AppColors.done, label: 'Sorted'),
        ];
      case AlgoCategory.searching:
        return const [
          LegendDot(color: AppColors.compare, label: 'Checking'),
          LegendDot(color: AppColors.highlight, label: 'Search window'),
          LegendDot(color: AppColors.done, label: 'Found'),
        ];
      case AlgoCategory.trees:
        return const [
          LegendDot(color: AppColors.active, label: 'Current node'),
        ];
      case AlgoCategory.pathfinding:
        return const [
          LegendDot(color: AppColors.done, label: 'Start'),
          LegendDot(color: AppColors.active, label: 'Goal'),
          LegendDot(color: AppColors.compare, label: 'Expanding'),
          LegendDot(color: AppColors.highlight, label: 'Visited'),
          LegendDot(color: AppColors.clayBright, label: 'Path'),
        ];
      case AlgoCategory.backtracking:
        return const [
          LegendDot(color: AppColors.clay, label: 'Queen / disk'),
          LegendDot(color: AppColors.active, label: 'Active move'),
          LegendDot(color: AppColors.done, label: 'Solved / visited'),
        ];
      case AlgoCategory.dynamicProgramming:
        return const [
          LegendDot(color: AppColors.active, label: 'Computing'),
          LegendDot(color: AppColors.compare, label: 'Sub-results used'),
          LegendDot(color: AppColors.done, label: 'Result'),
        ];
      case AlgoCategory.mathematics:
        return const [
          LegendDot(color: AppColors.active, label: 'Current'),
          LegendDot(color: AppColors.compare, label: 'Inputs'),
          LegendDot(color: AppColors.done, label: 'Prime / result'),
        ];
      case AlgoCategory.graphs:
        return const [
          LegendDot(color: AppColors.done, label: 'In tree'),
          LegendDot(color: AppColors.active, label: 'Newest node'),
          LegendDot(color: AppColors.compare, label: 'Candidate edge'),
          LegendDot(color: AppColors.clayBright, label: 'Tree edge'),
        ];
      case AlgoCategory.strings:
        return const [
          LegendDot(color: AppColors.compare, label: 'Comparing'),
          LegendDot(color: AppColors.active, label: 'Mismatch'),
          LegendDot(color: AppColors.done, label: 'Matched / found'),
        ];
      case AlgoCategory.dataStructures:
        return const [
          LegendDot(color: AppColors.compare, label: 'Probing / active'),
          LegendDot(color: AppColors.done, label: 'Placed / settled'),
          LegendDot(color: AppColors.active, label: 'Outgoing'),
        ];
      case AlgoCategory.optimization:
        return const [
          LegendDot(color: AppColors.done, label: 'Matches target'),
          LegendDot(color: AppColors.compare, label: 'Fittest candidate'),
        ];
      case AlgoCategory.geometry:
        return const [
          LegendDot(color: AppColors.compare, label: 'Point considered'),
          LegendDot(color: AppColors.clayBright, label: 'Hull edge'),
          LegendDot(color: AppColors.done, label: 'Hull vertex'),
        ];
      case AlgoCategory.arrays:
        return const [
          LegendDot(color: AppColors.compare, label: 'Visiting'),
          LegendDot(color: AppColors.active, label: 'Insert / delete'),
          LegendDot(color: AppColors.done, label: 'Result'),
        ];
      case AlgoCategory.lists:
        return const [
          LegendDot(color: AppColors.done, label: 'Active node'),
          LegendDot(color: AppColors.active, label: 'Removing'),
        ];
      case AlgoCategory.matrices:
        return const [
          LegendDot(color: AppColors.compare, label: 'Operands'),
          LegendDot(color: AppColors.active, label: 'Computing'),
          LegendDot(color: AppColors.done, label: 'Result'),
        ];
      case AlgoCategory.stacksQueues:
        return const [
          LegendDot(color: AppColors.done, label: 'Inserted'),
          LegendDot(color: AppColors.active, label: 'Removed'),
        ];
      case AlgoCategory.dataTypes:
        return const [
          LegendDot(color: AppColors.compare, label: 'Examining'),
          LegendDot(color: AppColors.active, label: 'Match / mismatch'),
          LegendDot(color: AppColors.done, label: 'Result'),
        ];
      case AlgoCategory.ai:
        return const [
          LegendDot(color: AppColors.done, label: 'Maximizer / chosen'),
          LegendDot(color: AppColors.active, label: 'Minimizer'),
          LegendDot(color: AppColors.compare, label: 'Evaluating'),
          LegendDot(color: AppColors.idle, label: 'Pruned'),
        ];
    }
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.info});
  final AlgorithmInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(info.category.icon, size: 16, color: info.category.color),
            const SizedBox(width: 6),
            Text(info.category.label,
                style: theme.textTheme.titleSmall?.copyWith(color: info.category.color)),
          ],
        ),
        const SizedBox(height: 10),
        Text('How it works', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(info.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 18),
        Text('Complexity', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Pill(text: 'Time  ${info.timeComplexity}', color: info.category.color, icon: Icons.timer_outlined),
            Pill(text: 'Space  ${info.spaceComplexity}', color: info.category.color, icon: Icons.memory_rounded),
          ],
        ),
      ],
    );
  }
}
