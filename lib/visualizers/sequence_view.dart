import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [SequenceFrame] of a stack (vertical) or queue (horizontal),
/// highlighting the element just pushed/popped or enqueued/dequeued.
class SequenceView extends StatelessWidget {
  const SequenceView({super.key, required this.frame});

  final SequenceFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _SequencePainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _SequencePainter extends CustomPainter {
  _SequencePainter({required this.frame, required this.dark});

  final SequenceFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.values.length;
    if (n == 0) return;
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Color fillFor(int i) {
      if (frame.highlight == i) return frame.removed ? AppColors.active : AppColors.done;
      return Color.lerp(base, dark ? AppColors.idleDark : AppColors.idle, 0.25)!;
    }

    void drawCell(double x, double y, double w, double hgt, int i) {
      final rect = Rect.fromLTWH(x, y, w, hgt).deflate(3);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = fillFor(i));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), border);
      final tp = TextPainter(
        text: TextSpan(
          text: '${frame.values[i]}',
          style: TextStyle(
            color: frame.highlight == i ? Colors.white : ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + (w - tp.width) / 2, y + (hgt - tp.height) / 2));
    }

    void drawLabel(String s, double x, double y) {
      final tp = TextPainter(
        text: TextSpan(text: s, style: TextStyle(color: dark ? AppColors.inkFaintDark : AppColors.inkFaint, fontSize: 12, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, y));
    }

    if (frame.vertical) {
      // Stack — bottom at the bottom, top at the top.
      final cellH = (size.height / (n + 1)).clamp(0, 52).toDouble();
      final w = (size.width * 0.4).clamp(80, 220).toDouble();
      final x = (size.width - w) / 2;
      for (var i = 0; i < n; i++) {
        // index 0 is the bottom of the stack.
        final y = size.height - (i + 1) * cellH;
        drawCell(x, y, w, cellH, i);
      }
      drawLabel('top', x + w + 10, size.height - n * cellH);
    } else {
      // Queue — front at the left.
      final cellW = (size.width / (n + 1)).clamp(0, 64).toDouble();
      final h = (size.height * 0.4).clamp(56, 120).toDouble();
      final y = (size.height - h) / 2;
      final originX = (size.width - n * cellW) / 2;
      for (var i = 0; i < n; i++) {
        drawCell(originX + i * cellW, y, cellW, h, i);
      }
      drawLabel('front', originX, y - 20);
      drawLabel('back', originX + n * cellW - 30, y + h + 6);
    }
  }

  @override
  bool shouldRepaint(covariant _SequencePainter old) => old.frame != frame || old.dark != dark;
}
