import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [StringMatchFrame]: the text as a row of character cells with the
/// pattern aligned beneath it at the current offset.
class StringView extends StatelessWidget {
  const StringView({super.key, required this.frame});

  final StringMatchFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _StringPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _StringPainter extends CustomPainter {
  _StringPainter({required this.frame, required this.dark});

  final StringMatchFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.text.length;
    final cell = (size.width / (n + 1)).clamp(0, 46).toDouble();
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final headerBg = dark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final originX = (size.width - n * cell) / 2;
    final textY = size.height * 0.3 - cell / 2;
    final patternY = size.height * 0.62 - cell / 2;

    void drawCell(double x, double y, String ch, Color fill, Color fg) {
      final rect = Rect.fromLTWH(x, y, cell, cell);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4)), Paint()..color = fill);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4)), border);
      final tp = TextPainter(
        text: TextSpan(text: ch, style: TextStyle(color: fg, fontSize: cell * 0.42, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + (cell - tp.width) / 2, y + (cell - tp.height) / 2));
    }

    // Text row.
    for (var i = 0; i < n; i++) {
      final x = originX + i * cell;
      final inFound = frame.found.contains(i);
      final patIndex = i - frame.offset;
      Color fill = base;
      if (inFound) {
        fill = AppColors.done;
      } else if (patIndex >= 0 && patIndex < frame.pattern.length) {
        if (frame.compareIndex == patIndex) fill = AppColors.compare;
        if (frame.mismatch == patIndex) fill = AppColors.active;
        if (frame.matched.contains(patIndex)) fill = Color.lerp(base, AppColors.done, 0.4)!;
      }
      drawCell(x, textY, frame.text[i], fill, inFound ? Colors.white : ink);
    }

    // Pattern row aligned at offset.
    for (var j = 0; j < frame.pattern.length; j++) {
      final pos = frame.offset + j;
      if (pos < 0 || pos >= n) continue;
      final x = originX + pos * cell;
      Color fill = headerBg;
      Color fg = ink;
      if (frame.found.isNotEmpty) {
        fill = AppColors.done;
        fg = Colors.white;
      } else if (frame.compareIndex == j) {
        fill = AppColors.compare;
      } else if (frame.mismatch == j) {
        fill = AppColors.active;
        fg = Colors.white;
      } else if (frame.matched.contains(j)) {
        fill = Color.lerp(headerBg, AppColors.done, 0.5)!;
      }
      drawCell(x, patternY, frame.pattern[j], fill, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _StringPainter old) => old.frame != frame || old.dark != dark;
}
