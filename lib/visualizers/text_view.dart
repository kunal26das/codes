import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [TextFrame]: a centred row of character cells, each tinted by its
/// state (examining / matched / rejected). Spaces render as a thin gap marker.
class TextView extends StatelessWidget {
  const TextView({super.key, required this.frame});

  final TextFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _TextPainter(
          frame: frame,
          surface: theme.cardColor,
          border: theme.dividerColor,
          ink: dark ? AppColors.inkDark : AppColors.ink,
        ),
      ),
    );
  }
}

class _TextPainter extends CustomPainter {
  _TextPainter({required this.frame, required this.surface, required this.border, required this.ink});

  final TextFrame frame;
  final Color surface;
  final Color border;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.text.length;
    if (n == 0) return;
    final cell = ((size.width - 32) / n).clamp(20.0, 56.0);
    final totalW = cell * n;
    final startX = (size.width - totalW) / 2;
    final y = size.height / 2 - cell / 2;

    for (var i = 0; i < n; i++) {
      final rect = Rect.fromLTWH(startX + i * cell, y, cell, cell).deflate(3);
      Color fill = surface;
      if (frame.matched.contains(i)) fill = AppColors.done;
      if (frame.examining.contains(i)) fill = AppColors.compare;
      if (frame.rejected.contains(i)) fill = AppColors.active;
      final highlighted = fill != surface;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = fill);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = highlighted ? fill : border
          ..strokeWidth = highlighted ? 2.2 : 1.2
          ..style = PaintingStyle.stroke,
      );
      final ch = frame.text[i];
      final tp = TextPainter(
        text: TextSpan(
          text: ch == ' ' ? '␣' : ch,
          style: TextStyle(
            color: highlighted ? Colors.white : ink,
            fontSize: cell * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));

      // Index label below.
      final it = TextPainter(
        text: TextSpan(text: '$i', style: TextStyle(color: ink.withValues(alpha: 0.4), fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      it.paint(canvas, Offset(rect.center.dx - it.width / 2, rect.bottom + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _TextPainter old) => old.frame != frame || old.surface != surface;
}
