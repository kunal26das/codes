import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/algorithm.dart';
import '../widgets/ui.dart';
import 'algorithm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.themeMode, required this.onCycleTheme});

  final ThemeMode themeMode;
  final VoidCallback onCycleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = catalogByCategory;
    final (themeIcon, themeTooltip) = switch (themeMode) {
      ThemeMode.system => (Icons.brightness_auto_outlined, 'Theme: System (tap for Light)'),
      ThemeMode.light => (Icons.light_mode_outlined, 'Theme: Light (tap for Dark)'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Theme: Dark (tap for System)'),
    };
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.hub_rounded, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            const Text('AlgoScope', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: themeTooltip,
            onPressed: onCycleTheme,
            icon: Icon(themeIcon),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                _Hero(theme: theme),
                const SizedBox(height: 8),
                for (final category in AlgoCategory.values)
                  if (grouped[category] != null)
                    _CategorySection(category: category, items: grouped[category]!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Algorithms, in motion.', style: theme.textTheme.displaySmall),
          const SizedBox(height: 10),
          Text(
            'A visual companion to the classic algorithms in this repository — '
            'reimplemented in Dart and animated step by step. Pick one to watch '
            'it work.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.items});

  final AlgoCategory category;
  final List<AlgorithmInfo> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: 8),
            Text(category.label, style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = (constraints.maxWidth / 320).floor().clamp(1, 3);
            const spacing = 14.0;
            final cardW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final algo in items)
                  SizedBox(width: cardW, child: _AlgoCard(algo: algo)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AlgoCard extends StatelessWidget {
  const _AlgoCard({required this.algo});
  final AlgorithmInfo algo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AlgorithmScreen(info: algo)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: algo.category.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(algo.category.icon, size: 19, color: algo.category.color),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, size: 18, color: theme.dividerColor),
                ],
              ),
              const SizedBox(height: 14),
              Text(algo.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(algo.blurb, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Pill(text: algo.timeComplexity, color: algo.category.color, icon: Icons.timer_outlined),
            ],
          ),
        ),
      ),
    );
  }
}
