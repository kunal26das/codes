import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [GeneticFrame]: the target phrase atop the current population,
/// with characters that match the target tinted and the fittest row marked.
class GeneticView extends StatelessWidget {
  const GeneticView({super.key, required this.frame});

  final GeneticFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GeneticPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _GeneticPainter extends CustomPainter {
  _GeneticPainter({required this.frame, required this.dark});

  final GeneticFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final l = frame.target.length;
    final rows = frame.population.length + 2; // target row + gap + population
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final headerBg = dark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final faint = dark ? AppColors.inkFaintDark : AppColors.inkFaint;

    final cell = (size.width / (l + 4)).clamp(0, (size.height / rows)).clamp(0, 40).toDouble();
    final gridW = l * cell;
    final originX = (size.width - gridW) / 2 - cell;

    void drawRow(double y, String s, {required bool isTarget, bool isBest = false, int? fitness}) {
      for (var i = 0; i < l; i++) {
        final x = originX + cell + i * cell;
        final matches = isTarget || (i < s.length && s[i] == frame.target[i]);
        Color fill = base;
        if (isTarget) {
          fill = headerBg;
        } else if (matches) {
          fill = Color.lerp(base, AppColors.done, 0.5)!;
        }
        final rect = Rect.fromLTWH(x, y, cell, cell).deflate(1.5);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), Paint()..color = fill);
        if (isBest) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(3)),
            Paint()
              ..color = AppColors.compare
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
        final ch = i < s.length ? s[i] : ' ';
        final tp = TextPainter(
          text: TextSpan(
            text: ch == ' ' ? '·' : ch,
            style: TextStyle(
              color: isTarget ? ink : (matches ? ink : faint),
              fontSize: cell * 0.5,
              fontWeight: isTarget ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + (cell - tp.width) / 2, y + (cell - tp.height) / 2));
      }
      if (fitness != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$fitness/$l',
            style: TextStyle(color: isBest ? AppColors.compare : faint, fontSize: cell * 0.4, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(originX + cell + gridW + 6, y + (cell - tp.height) / 2));
      }
    }

    // Target row.
    drawRow(0, frame.target, isTarget: true);
    final targetLabel = TextPainter(
      text: TextSpan(text: 'target', style: TextStyle(color: faint, fontSize: cell * 0.4, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    targetLabel.paint(canvas, Offset(originX + cell + gridW + 6, (cell - targetLabel.height) / 2));

    // Population rows.
    for (var r = 0; r < frame.population.length; r++) {
      final y = (r + 2) * cell;
      drawRow(y, frame.population[r], isTarget: false, isBest: r == frame.best, fitness: frame.fitness[r]);
    }
  }

  @override
  bool shouldRepaint(covariant _GeneticPainter old) => old.frame != frame || old.dark != dark;
}
