import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [HashFrame] as an indexed row of slots, highlighting the slot
/// being probed and the one where a key just landed.
class HashView extends StatelessWidget {
  const HashView({super.key, required this.frame});

  final HashFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _HashPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _HashPainter extends CustomPainter {
  _HashPainter({required this.frame, required this.dark});

  final HashFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final size0 = frame.size;
    final cell = (size.width / size0).clamp(0, 56).toDouble();
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final faint = dark ? AppColors.inkFaintDark : AppColors.inkFaint;
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final originX = (size.width - size0 * cell) / 2;
    final y = size.height / 2 - cell / 2;

    for (var i = 0; i < size0; i++) {
      final x = originX + i * cell;
      final occupied = frame.slots[i] != -1;
      Color fill = occupied ? Color.lerp(base, AppColors.done, 0.30)! : base;
      if (frame.probe == i) fill = AppColors.compare;
      if (frame.placed == i) fill = AppColors.done;
      final rect = Rect.fromLTWH(x, y, cell, cell).deflate(2);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), Paint()..color = fill);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), border);

      // Index label above the slot.
      final idx = TextPainter(
        text: TextSpan(text: '$i', style: TextStyle(color: faint, fontSize: 11, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      idx.paint(canvas, Offset(x + (cell - idx.width) / 2, y - 16));

      if (occupied) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${frame.slots[i]}',
            style: TextStyle(
              color: frame.placed == i ? Colors.white : ink,
              fontSize: cell * 0.34,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + (cell - tp.width) / 2, y + (cell - tp.height) / 2));
      }
    }

    // The key currently being inserted, shown above the table.
    if (frame.inserting != null && frame.placed == null) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'inserting ${frame.inserting}',
          style: const TextStyle(color: AppColors.active, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(originX, y - 44));
    }
  }

  @override
  bool shouldRepaint(covariant _HashPainter old) => old.frame != frame || old.dark != dark;
}
