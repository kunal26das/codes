import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/sequence_trace.dart';
import '../theme/app_colors.dart';
import 'zoomable_canvas.dart';

/// Labeled cells make pointer motion, auxiliary structures and accumulators
/// visible. A fitted overview can be enlarged without overlapping its labels.
class SequenceTraceView extends StatelessWidget {
  const SequenceTraceView({super.key, required this.frame});

  final SequenceTrace frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = frame.rows.fold<int>(
      1,
      (n, row) => math.max(n, row.values.length),
    );
    final width = math.max(640.0, 140 + columns * 62.0);
    final height =
        80.0 +
        frame.rows.length * 118 +
        ((frame.variables.length / 3).ceil() * 42) +
        (frame.result.isEmpty ? 0 : 72);
    return ZoomableCanvas(
      minimumSize: Size(width, height),
      builder: (size) => Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final row in frame.rows) _TraceRow(row: row),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final entry in frame.variables.entries)
                      Container(
                        constraints: BoxConstraints(maxWidth: (width - 44) / 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
                if (frame.result.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    frame.result,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.row});
  final SequenceTraceRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 118,
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              row.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          if (row.values.isEmpty)
            Text(
              'empty',
              style: TextStyle(color: theme.hintColor, fontSize: 14),
            ),
          for (var i = 0; i < row.values.length; i++)
            SizedBox(
              width: 62,
              child: Column(
                children: [
                  SizedBox(
                    height: 46,
                    child: Center(
                      child: Text(
                        row.pointers.entries
                            .where((entry) => entry.value == i)
                            .map((entry) => entry.key)
                            .join(' / '),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: row.active.contains(i)
                          ? AppColors.compare
                          : row.done.contains(i)
                          ? AppColors.done
                          : row.rangeStart != null &&
                                row.rangeEnd != null &&
                                i >= row.rangeStart! &&
                                i <= row.rangeEnd!
                          ? theme.colorScheme.primary.withValues(alpha: 0.18)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        row.values[i],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '$i',
                    style: TextStyle(fontSize: 11, color: theme.hintColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
