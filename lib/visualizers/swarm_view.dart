import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [SwarmFrame]: a 2-D fitness landscape drawn as concentric
/// contours around the peak, the searching particles as terracotta dots, and
/// the best position found so far as a ringed marker.
class SwarmView extends StatelessWidget {
  const SwarmView({super.key, required this.frame});

  final SwarmFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _SwarmPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _SwarmPainter extends CustomPainter {
  _SwarmPainter({required this.frame, required this.dark});

  final SwarmFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 30.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    Offset at(List<double> p) => Offset(pad + p[0] * w, pad + p[1] * h);

    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final peak = at(frame.target);
    final maxR = (w < h ? w : h);

    // Fitness landscape: contour rings around the peak (inner = higher).
    for (var k = 6; k >= 1; k--) {
      final t = k / 6;
      canvas.drawCircle(
        peak,
        maxR * 0.62 * t,
        Paint()
          ..color = AppColors.done.withValues(alpha: 0.05 + (1 - t) * 0.12)
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawCircle(
      peak,
      9,
      Paint()..color = AppColors.done.withValues(alpha: 0.85),
    );

    // Best position so far.
    if (frame.bestPos != null) {
      final b = at(frame.bestPos!);
      canvas.drawCircle(
        b,
        11,
        Paint()
          ..color = AppColors.highlight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    // Particles.
    for (final p in frame.particles) {
      final c = at(p);
      canvas.drawCircle(c, 5, Paint()..color = AppColors.clayBright);
      canvas.drawCircle(
        c,
        5,
        Paint()
          ..color = ink.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SwarmPainter old) => old.frame != frame || old.dark != dark;
}
