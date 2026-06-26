import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders an [ArrayFrame] as a row of value-proportional bars with
/// role-based colouring. Shared by sorting and searching visualizers.
class BarsView extends StatelessWidget {
  const BarsView({super.key, required this.frame});

  final ArrayFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _BarsPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.frame, required this.dark});

  final ArrayFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final values = frame.values;
    if (values.isEmpty) return;
    final n = values.length;
    const gap = 4.0;
    final barW = (size.width - gap * (n - 1)) / n;
    final idle = dark ? AppColors.idleDark : AppColors.idle;

    // Support negative values with a zero baseline: positive bars grow up from
    // it, negative bars grow down.
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minV = values.reduce((a, b) => a < b ? a : b).toDouble();
    final top = maxV > 0 ? maxV : 0.0;
    final bot = minV < 0 ? minV : 0.0;
    final span = (top - bot) == 0 ? 1.0 : (top - bot);
    final usable = size.height - 22;
    double yOf(double v) => (top - v) / span * usable;
    final zeroY = yOf(0);
    final showLabels = n <= 24 && barW >= 14 && minV >= 0;

    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < n; i++) {
      final v = values[i].toDouble();
      final negative = v < 0;
      final yTop = yOf(negative ? 0 : v);
      final yBot = yOf(negative ? v : 0);
      final h = (yBot - yTop).abs().clamp(1.0, usable);
      final x = i * (barW + gap);
      paint.color = _colorFor(i, idle);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, negative ? zeroY : yTop, barW, h),
        topLeft: Radius.circular(negative ? 0 : 4),
        topRight: Radius.circular(negative ? 0 : 4),
        bottomLeft: Radius.circular(negative ? 4 : 0),
        bottomRight: Radius.circular(negative ? 4 : 0),
      );
      canvas.drawRRect(rect, paint);

      if (showLabels) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${values[i]}',
            style: TextStyle(
              color: dark ? AppColors.inkSoftDark : AppColors.inkSoft,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: barW + gap);
        tp.paint(canvas, Offset(x + (barW - tp.width) / 2, size.height - 16));
      }
    }
  }

  Color _colorFor(int i, Color idle) {
    if (frame.done.contains(i)) return AppColors.done;
    if (frame.active.contains(i)) return AppColors.active;
    if (frame.comparing.contains(i)) return AppColors.compare;
    if (frame.pivot == i) return AppColors.highlight;
    final lo = frame.windowLo, hi = frame.windowHi;
    if (lo != null && hi != null && i >= lo && i <= hi) {
      return Color.lerp(idle, AppColors.highlight, 0.35)!;
    }
    return idle;
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.frame != frame || old.dark != dark;
}
