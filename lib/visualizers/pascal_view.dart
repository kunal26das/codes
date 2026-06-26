import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [PascalFrame]: the triangle built so far, centered, with the
/// active cell and the two cells feeding it highlighted.
class PascalView extends StatelessWidget {
  const PascalView({super.key, required this.frame});

  final PascalFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _PascalPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _PascalPainter extends CustomPainter {
  _PascalPainter({required this.frame, required this.dark});

  final PascalFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final numRows = frame.rows.length;
    if (numRows == 0) return;
    final cell = (size.width / numRows).clamp(0, size.height / numRows).toDouble();
    final base = dark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
    final ink = dark ? AppColors.inkDark : AppColors.ink;

    final addends = {for (final a in frame.addends) a[0] * 1000 + a[1]};

    for (var r = 0; r < numRows; r++) {
      final rowVals = frame.rows[r];
      final rowWidth = (r + 1) * cell;
      final startX = (size.width - rowWidth) / 2;
      final y = r * cell;
      for (var c = 0; c < rowVals.length; c++) {
        final v = rowVals[c];
        if (v < 0) continue;
        final x = startX + c * cell;
        final rect = Rect.fromLTWH(x, y, cell, cell).deflate(cell * 0.08);

        Color fill = base;
        if (addends.contains(r * 1000 + c)) fill = Color.lerp(base, AppColors.compare, 0.5)!;
        if (frame.highlightRow == r && frame.highlightCol == c) {
          fill = Color.lerp(base, AppColors.active, 0.55)!;
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.16)),
          Paint()..color = fill,
        );

        final tp = TextPainter(
          text: TextSpan(
            text: '$v',
            style: TextStyle(color: ink, fontSize: cell * 0.26, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: cell);
        tp.paint(canvas, Offset(x + (cell - tp.width) / 2, y + (cell - tp.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PascalPainter old) => old.frame != frame || old.dark != dark;
}
