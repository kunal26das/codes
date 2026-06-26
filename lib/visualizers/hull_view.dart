import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [HullFrame]: the scatter of points with the partial/complete
/// convex-hull polygon drawn over them.
class HullView extends StatelessWidget {
  const HullView({super.key, required this.frame});

  final HullFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _HullPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _HullPainter extends CustomPainter {
  _HullPainter({required this.frame, required this.dark});

  final HullFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 28.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    Offset at(int i) => Offset(pad + frame.points[i][0] * w, pad + frame.points[i][1] * h);

    final idle = dark ? AppColors.idleDark : AppColors.idle;
    final ink = dark ? AppColors.inkDark : AppColors.ink;

    // Hull edges.
    if (frame.hull.length >= 2) {
      final path = Path()..moveTo(at(frame.hull.first).dx, at(frame.hull.first).dy);
      for (var i = 1; i < frame.hull.length; i++) {
        path.lineTo(at(frame.hull[i]).dx, at(frame.hull[i]).dy);
      }
      if (frame.closed) path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.clayBright
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      if (frame.closed) {
        canvas.drawPath(path, Paint()..color = AppColors.clayBright.withValues(alpha: 0.10));
      }
    }

    final hullSet = frame.hull.toSet();
    for (var i = 0; i < frame.points.length; i++) {
      final c = at(i);
      final onHull = hullSet.contains(i);
      Color fill = idle;
      double radius = 5;
      if (onHull) {
        fill = AppColors.done;
        radius = 6;
      }
      if (frame.current == i) {
        fill = AppColors.compare;
        radius = 7;
      }
      canvas.drawCircle(c, radius, Paint()..color = fill);
      canvas.drawCircle(c, radius, Paint()
        ..color = ink.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant _HullPainter old) => old.frame != frame || old.dark != dark;
}
