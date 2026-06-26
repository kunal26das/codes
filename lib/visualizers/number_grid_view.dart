import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [NumberGridFrame] of the Sieve of Eratosthenes: numbers 1..maxN
/// in a grid, primes tinted, composites struck through.
class NumberGridView extends StatelessWidget {
  const NumberGridView({super.key, required this.frame});

  final NumberGridFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _NumberGridPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _NumberGridPainter extends CustomPainter {
  _NumberGridPainter({required this.frame, required this.dark});

  final NumberGridFrame frame;
  final bool dark;

  static const _perRow = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final count = frame.maxN;
    final rows = (count / _perRow).ceil();
    final cell = (size.width / _perRow).clamp(0, size.height / rows).toDouble();
    final gridW = cell * _perRow;
    final originX = (size.width - gridW) / 2;
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final idle = dark ? AppColors.idleDark : AppColors.idle;
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var num = 1; num <= count; num++) {
      final i = num - 1;
      final r = i ~/ _perRow;
      final c = i % _perRow;
      final x = originX + c * cell;
      final y = r * cell;
      final rect = Rect.fromLTWH(x, y, cell, cell).deflate(1);

      final isPrime = frame.primes.contains(num);
      final isMarked = frame.marked.contains(num);
      Color fill;
      if (frame.current == num) {
        fill = isMarked ? AppColors.active : AppColors.compare;
      } else if (isPrime) {
        fill = Color.lerp(base, AppColors.done, 0.42)!;
      } else if (isMarked) {
        fill = Color.lerp(base, idle, 0.5)!;
      } else {
        fill = base;
      }

      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rr, Paint()..color = fill);
      canvas.drawRRect(rr, border);
      if (frame.multiplesOf == num) {
        canvas.drawRRect(
          rr,
          Paint()
            ..color = AppColors.active
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      final tp = TextPainter(
        text: TextSpan(
          text: '$num',
          style: TextStyle(
            color: isMarked && frame.current != num
                ? (dark ? AppColors.inkFaintDark : AppColors.inkFaint)
                : (dark ? AppColors.inkDark : AppColors.ink),
            fontSize: cell * 0.30,
            fontWeight: isPrime ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final tc = Offset(x + cell / 2, y + cell / 2);
      tp.paint(canvas, tc - Offset(tp.width / 2, tp.height / 2));

      if (isMarked) {
        canvas.drawLine(
          Offset(x + cell * 0.2, tc.dy),
          Offset(x + cell * 0.8, tc.dy),
          Paint()
            ..color = (dark ? AppColors.inkFaintDark : AppColors.inkFaint)
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NumberGridPainter old) => old.frame != frame || old.dark != dark;
}
