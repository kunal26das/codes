import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../models/graph_trace.dart';
import 'graph_view.dart';

/// Keep the graph and its algorithm state visible together. Each state panel
/// scrolls independently when a short phone viewport cannot fit every row.
class GraphTraceView extends StatelessWidget {
  const GraphTraceView({super.key, required this.run, required this.frame});

  final GraphTraceRun run;
  final GraphTraceFrame frame;

  @override
  Widget build(BuildContext context) {
    final base = run.graph;
    final graph = GraphRun(
      nodeLabels: base.nodeLabels,
      positions: base.positions,
      edges: frame.edges ?? base.edges,
      frames: [frame.graph],
      directed: base.directed,
      weighted: base.weighted,
      activeEdgesOnly: base.activeEdgesOnly,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final diagram = GraphView(run: graph, frame: frame.graph);
        final state = _StatePanel(frame: frame);
        if (constraints.maxWidth >= 700) {
          return Row(
            children: [
              Expanded(child: diagram),
              const SizedBox(width: 12),
              SizedBox(width: 280, child: state),
            ],
          );
        }
        return Column(
          children: [
            Expanded(flex: 3, child: diagram),
            const SizedBox(height: 6),
            Expanded(flex: 2, child: state),
          ],
        );
      },
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({required this.frame});
  final GraphTraceFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget cell(String text, {bool header = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: header ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (frame.graphTitle.isNotEmpty)
              Text(frame.graphTitle, style: theme.textTheme.labelMedium),
            if (frame.frontierLabel.isNotEmpty) ...[
              Text(frame.frontierLabel, style: theme.textTheme.labelMedium),
              Text(
                frame.frontier.isEmpty ? 'Empty' : frame.frontier.join(' → '),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
            ],
            if (frame.columns.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder(
                    horizontalInside: BorderSide(color: theme.dividerColor),
                  ),
                  children: [
                    TableRow(
                      children: [
                        for (final column in frame.columns)
                          cell(column, header: true),
                      ],
                    ),
                    for (final row in frame.rows)
                      TableRow(
                        children: [for (final value in row) cell(value)],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
