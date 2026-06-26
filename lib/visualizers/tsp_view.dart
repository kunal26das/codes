import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [TspFrame]: the cities as dots, optional pheromone trails (faint
/// lines whose opacity grows with edge strength), and the current/best tour as
/// a closed terracotta loop.
class TspView extends StatelessWidget {
  const TspView({super.key, required this.frame});

  final TspFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _TspPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _TspPainter extends CustomPainter {
  _TspPainter({required this.frame, required this.dark});

  final TspFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 30.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    Offset at(int i) => Offset(pad + frame.cities[i][0] * w, pad + frame.cities[i][1] * h);

    final idle = dark ? AppColors.idleDark : AppColors.idle;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final n = frame.cities.length;

    // Pheromone trails: opacity proportional to relative strength.
    if (frame.pheromone.isNotEmpty) {
      var maxP = 0.0001;
      for (var i = 0; i < n; i++) {
        for (var j = i + 1; j < n; j++) {
          if (frame.pheromone[i][j] > maxP) maxP = frame.pheromone[i][j];
        }
      }
      for (var i = 0; i < n; i++) {
        for (var j = i + 1; j < n; j++) {
          final strength = frame.pheromone[i][j] / maxP;
          if (strength < 0.06) continue;
          canvas.drawLine(
            at(i),
            at(j),
            Paint()
              ..color = AppColors.done.withValues(alpha: 0.10 + strength * 0.55)
              ..strokeWidth = 0.6 + strength * 3.2,
          );
        }
      }
    }

    // Current / best tour as a closed loop.
    if (frame.tour.length >= 2) {
      final path = Path()..moveTo(at(frame.tour.first).dx, at(frame.tour.first).dy);
      for (var i = 1; i < frame.tour.length; i++) {
        path.lineTo(at(frame.tour[i]).dx, at(frame.tour[i]).dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.clayBright
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Cities.
    for (var i = 0; i < n; i++) {
      final c = at(i);
      canvas.drawCircle(c, 6, Paint()..color = frame.tour.contains(i) ? AppColors.clayDeep : idle);
      canvas.drawCircle(
        c,
        6,
        Paint()
          ..color = ink.withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    if (frame.bestLength != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'best ${frame.bestLength!.toStringAsFixed(2)}',
          style: TextStyle(color: ink.withValues(alpha: 0.65), fontSize: 13, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(pad - 6, 4));
    }
  }

  @override
  bool shouldRepaint(covariant _TspPainter old) => old.frame != frame || old.dark != dark;
}
