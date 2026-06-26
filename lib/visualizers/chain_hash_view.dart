import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [ChainHashFrame]: a column of buckets, each with its chained keys
/// drawn as a horizontal list to the right.
class ChainHashView extends StatelessWidget {
  const ChainHashView({super.key, required this.frame});

  final ChainHashFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _ChainPainter(
          frame: frame,
          surface: theme.cardColor,
          border: theme.dividerColor,
          ink: dark ? AppColors.inkDark : AppColors.ink,
        ),
      ),
    );
  }
}

class _ChainPainter extends CustomPainter {
  _ChainPainter({required this.frame, required this.surface, required this.border, required this.ink});

  final ChainHashFrame frame;
  final Color surface;
  final Color border;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.buckets.length;
    if (n == 0) return;
    final rowH = (size.height / (n + 1)).clamp(28.0, 56.0);
    final top = (size.height - rowH * n) / 2;
    const bucketW = 52.0;
    const cell = 46.0;
    final leftX = 24.0;

    for (var b = 0; b < n; b++) {
      final y = top + b * rowH;
      final active = frame.activeBucket == b;
      // Bucket label box.
      final brect = Rect.fromLTWH(leftX, y + 3, bucketW, rowH - 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(brect, const Radius.circular(6)),
        Paint()..color = active ? AppColors.compare : (Color.lerp(surface, ink, 0.06) ?? surface),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(brect, const Radius.circular(6)),
        Paint()
          ..color = active ? AppColors.compare : border
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke,
      );
      _text(canvas, '$b', brect.center, active ? Colors.white : ink.withValues(alpha: 0.7), 14, bold: true);

      // Chain.
      var x = leftX + bucketW + 18;
      final chain = frame.buckets[b];
      for (var i = 0; i < chain.length; i++) {
        // arrow
        canvas.drawLine(
          Offset(x - 16, y + rowH / 2),
          Offset(x, y + rowH / 2),
          Paint()
            ..color = ink.withValues(alpha: 0.4)
            ..strokeWidth = 1.6,
        );
        final isNew = active && frame.placed && frame.inserting == chain[i];
        final rect = Rect.fromLTWH(x, y + (rowH - cell.clamp(0, rowH - 6)) / 2, cell, (cell).clamp(0, rowH - 6));
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = isNew ? AppColors.done : surface);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()
            ..color = isNew ? AppColors.done : border
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke,
        );
        _text(canvas, '${chain[i]}', rect.center, isNew ? Colors.white : ink, 15, bold: true);
        x += cell + 18;
      }
    }
  }

  void _text(Canvas canvas, String s, Offset center, Color color, double size, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ChainPainter old) => old.frame != frame || old.surface != surface;
}
