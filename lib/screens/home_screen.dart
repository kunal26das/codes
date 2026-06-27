import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/algorithm.dart';
import '../widgets/ui.dart';
import 'algorithm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  AlgoCategory? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Algorithms matching the current text query and category filter.
  List<AlgorithmInfo> get _filtered {
    final q = _query.trim().toLowerCase();
    return catalog.where((a) {
      if (_categoryFilter != null && a.category != _categoryFilter)
        return false;
      if (q.isEmpty) return true;
      return a.name.toLowerCase().contains(q) ||
          a.blurb.toLowerCase().contains(q) ||
          a.category.label.toLowerCase().contains(q);
    }).toList();
  }

  bool get _isFiltering => _query.trim().isNotEmpty || _categoryFilter != null;

  void _clearFilters() {
    setState(() {
      _query = '';
      _searchController.clear();
      _categoryFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final results = _filtered;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(Icons.hub_rounded, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            const Text('AlgoScope', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(child: _Hero(theme: theme)),
                ),
                // Search + filter bar.
                SliverToBoxAdapter(
                  child: _SearchBar(
                    controller: _searchController,
                    query: _query,
                    categoryFilter: _categoryFilter,
                    onQueryChanged: (v) => setState(() => _query = v),
                    onCategorySelected: (c) =>
                        setState(() => _categoryFilter = c),
                    background: theme.scaffoldBackgroundColor,
                  ),
                ),
                if (results.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(onClear: _clearFilters),
                  )
                else if (_isFiltering)
                  ..._buildFlatResults(results)
                else
                  ..._buildGroupedResults(),
                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Flat grid of results with a count, shown while a search/filter is active.
  List<Widget> _buildFlatResults(List<AlgorithmInfo> results) {
    final theme = Theme.of(context);
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Text(
                '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: _CardGrid(items: results),
      ),
    ];
  }

  /// Default view: every category as its own labelled section.
  List<Widget> _buildGroupedResults() {
    final grouped = catalogByCategory;
    final slivers = <Widget>[];
    for (final category in AlgoCategory.values) {
      final items = grouped[category];
      if (items == null) continue;
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          sliver: SliverToBoxAdapter(
            child: _CategoryHeader(category: category, count: items.length),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: _CardGrid(items: items),
        ),
      );
    }
    return slivers;
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
            'A visual companion to classic algorithms — animated step by step. '
            'Search, pick one, and watch it work.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 16),
          const _StatRow(),
        ],
      ),
    );
  }
}

/// Small at-a-glance counts under the hero copy.
class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    final algos = catalog.length;
    final cats = catalogByCategory.length;
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        _Stat(value: '$algos', label: 'algorithms'),
        _Stat(value: '$cats', label: 'categories'),
        _Stat(value: 'Live', label: 'animated'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Search field plus a scrollable row of category filter chips.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.query,
    required this.categoryFilter,
    required this.onQueryChanged,
    required this.onCategorySelected,
    required this.background,
  });

  final TextEditingController controller;
  final String query;
  final AlgoCategory? categoryFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<AlgoCategory?> onCategorySelected;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search 158 algorithms…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        controller.clear();
                        onQueryChanged('');
                      },
                    ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: categoryFilter == null,
                color: theme.colorScheme.primary,
                onTap: () => onCategorySelected(null),
              ),
              for (final c in AlgoCategory.values)
                _FilterChip(
                  label: c.label,
                  icon: c.icon,
                  color: c.color,
                  selected: categoryFilter == c,
                  onTap: () =>
                      onCategorySelected(categoryFilter == c ? null : c),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.16)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.55)
                    : theme.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 15,
                      color:
                          selected ? color : theme.textTheme.bodyMedium?.color),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    color: selected ? color : theme.textTheme.bodyMedium?.color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.count});

  final AlgoCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(category.icon, size: 17, color: category.color),
        ),
        const SizedBox(width: 10),
        Text(category.label, style: theme.textTheme.titleLarge),
        const SizedBox(width: 8),
        Text('$count',
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.textTheme.bodySmall?.color)),
      ],
    );
  }
}

/// Responsive sliver grid of algorithm cards.
class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.items});

  final List<AlgorithmInfo> items;

  @override
  Widget build(BuildContext context) {
    // Derive column count from the (capped) content width. Returning the
    // SliverGrid directly keeps this a sliver — a LayoutBuilder here would
    // wrap it in a box and break the CustomScrollView.
    final width = MediaQuery.of(context).size.width.clamp(0, 1100).toDouble();
    final cols = (width / 340).floor().clamp(1, 3);
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 196,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => _AlgoCard(algo: items[i]),
        childCount: items.length,
      ),
    );
  }
}

class _AlgoCard extends StatelessWidget {
  const _AlgoCard({required this.algo});
  final AlgorithmInfo algo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverCard(
      accent: algo.category.color,
      semanticLabel: '${algo.name}, ${algo.category.label}. ${algo.blurb}',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AlgorithmScreen(info: algo)),
      ),
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
                child: Icon(algo.category.icon,
                    size: 19, color: algo.category.color),
              ),
              const Spacer(),
              Icon(Icons.arrow_outward_rounded,
                  size: 18, color: theme.dividerColor),
            ],
          ),
          const SizedBox(height: 14),
          Text(algo.name,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Expanded(
            child: Text(algo.blurb,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 12),
          Pill(
              text: algo.timeComplexity,
              color: algo.category.color,
              icon: Icons.timer_outlined),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No algorithms found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Try a different search term or category.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset filters'),
            ),
          ],
        ),
      ),
    );
  }
}
