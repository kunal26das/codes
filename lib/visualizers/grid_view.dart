import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [GridFrame] of an A* search over the fixed [run] grid.
class GridView2D extends StatelessWidget {
  const GridView2D({super.key, required this.run, required this.frame});

  final GridRun run;
  final GridFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth / run.cols)
            .clamp(0, constraints.maxHeight / run.rows)
            .toDouble();
        final w = cell * run.cols;
        final h = cell * run.rows;
        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: CustomPaint(
              painter: _GridPainter(run: run, frame: frame, cell: cell, dark: dark),
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.run,
    required this.frame,
    required this.cell,
    required this.dark,
  });

  final GridRun run;
  final GridFrame frame;
  final double cell;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final pathSet = frame.path.toSet();
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final base = dark ? AppColors.surfaceDark : AppColors.surface;

    for (var r = 0; r < run.rows; r++) {
      for (var c = 0; c < run.cols; c++) {
        final idx = r * run.cols + c;
        final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell)
            .deflate(0.5);
        Color fill;
        if (idx == run.start) {
          fill = AppColors.done;
        } else if (idx == run.goal) {
          fill = AppColors.active;
        } else if (run.walls.contains(idx)) {
          fill = dark ? const Color(0xFF4A4742) : const Color(0xFF4A4742);
        } else if (pathSet.contains(idx)) {
          fill = AppColors.clayBright;
        } else if (idx == frame.current) {
          fill = AppColors.compare;
        } else if (frame.closed.contains(idx)) {
          fill = Color.lerp(base, AppColors.highlight, 0.45)!;
        } else if (frame.open.contains(idx)) {
          fill = Color.lerp(base, AppColors.highlight, 0.18)!;
        } else {
          fill = base;
        }
        final rr = RRect.fromRectAndRadius(rect, const Radius.circular(3));
        canvas.drawRRect(rr, Paint()..color = fill);
        canvas.drawRRect(rr, border);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.frame != frame || old.cell != cell || old.dark != dark;
}
