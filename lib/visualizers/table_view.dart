import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [TableFrame] of a dynamic-programming table, with a header row
/// and column, computed cells, the active cell, and the cells it references.
class TableView extends StatelessWidget {
  const TableView({super.key, required this.frame});

  final TableFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _TablePainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _TablePainter extends CustomPainter {
  _TablePainter({required this.frame, required this.dark});

  final TableFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = frame.cols + 1; // + header column
    final rows = frame.rows + 1; // + header row
    final cw = size.width / cols;
    final ch = (size.height / rows).clamp(0, 46).toDouble();
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final headerBg = dark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    void label(String s, double x, double y, {Color? color, FontWeight fw = FontWeight.w500}) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            color: color ?? (dark ? AppColors.inkSoftDark : AppColors.inkSoft),
            fontSize: 12,
            fontWeight: fw,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: cw);
      tp.paint(canvas, Offset(x + (cw - tp.width) / 2, y + (ch - tp.height) / 2));
    }

    final ink = dark ? AppColors.inkDark : AppColors.ink;

    // Column headers.
    for (var c = 0; c < frame.cols; c++) {
      final x = (c + 1) * cw;
      final rect = Rect.fromLTWH(x, 0, cw, ch);
      canvas.drawRect(rect, Paint()..color = headerBg);
      canvas.drawRect(rect, border);
      label(c < frame.colHeader.length ? frame.colHeader[c] : '', x, 0, color: ink, fw: FontWeight.w700);
    }
    // Row headers.
    for (var r = 0; r < frame.rows; r++) {
      final y = (r + 1) * ch;
      final rect = Rect.fromLTWH(0, y, cw, ch);
      canvas.drawRect(rect, Paint()..color = headerBg);
      canvas.drawRect(rect, border);
      label(r < frame.rowHeader.length ? frame.rowHeader[r] : '', 0, y, color: ink, fw: FontWeight.w700);
    }

    // Cells.
    for (var r = 0; r < frame.rows; r++) {
      for (var c = 0; c < frame.cols; c++) {
        final x = (c + 1) * cw;
        final y = (r + 1) * ch;
        final key = r * frame.cols + c;
        final isFilled = frame.filled.contains(key);
        Color fill = isFilled ? base : Color.lerp(base, headerBg, 0.5)!;
        if (frame.refs.contains(key)) fill = Color.lerp(base, AppColors.compare, 0.35)!;
        if (frame.activeR == r && frame.activeC == c) fill = Color.lerp(base, AppColors.active, 0.45)!;
        final rect = Rect.fromLTWH(x, y, cw, ch);
        canvas.drawRect(rect, Paint()..color = fill);
        canvas.drawRect(rect, border);
        if (isFilled) {
          final raw = frame.cells[r][c];
          label(raw >= (1 << 28) ? '∞' : '$raw', x, y, color: ink, fw: FontWeight.w600);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TablePainter old) => old.frame != frame || old.dark != dark;
}
