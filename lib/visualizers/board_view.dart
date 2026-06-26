import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [BoardFrame] of the N-Queens backtracking search.
class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.frame});

  final BoardFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth
            .clamp(0, constraints.maxHeight)
            .toDouble();
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: CustomPaint(
              painter: _BoardPainter(frame: frame, dark: dark),
            ),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.frame, required this.dark});

  final BoardFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.n;
    final cell = size.width / n;
    final lightSq = dark ? const Color(0xFF35332F) : const Color(0xFFF0EEE6);
    final darkSq = dark ? const Color(0xFF2A2927) : const Color(0xFFE2DDD0);

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell);
        var color = (r + c).isEven ? lightSq : darkSq;
        if (frame.tryRow == r && frame.tryCol == c) {
          color = frame.conflict ? const Color(0x55D97757) : const Color(0x557C9A6E);
        }
        canvas.drawRect(rect, Paint()..color = color);
      }
    }

    // Placed queens — real chess pieces.
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    for (var r = 0; r < n; r++) {
      final c = frame.queens[r];
      if (c < 0) continue;
      final center = Offset(c * cell + cell / 2, r * cell + cell / 2);
      _drawQueen(canvas, center, cell, frame.solved ? AppColors.done : ink);
    }

    // Trial marker — a faint queen on the square being considered.
    if (frame.tryRow != null && frame.tryCol != null && !frame.conflict) {
      final center = Offset(
        frame.tryCol! * cell + cell / 2,
        frame.tryRow! * cell + cell / 2,
      );
      _drawQueen(canvas, center, cell, AppColors.clayBright.withValues(alpha: 0.5));
    }
  }

  void _drawQueen(Canvas canvas, Offset c, double cell, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: '♛',
        style: TextStyle(
          color: color,
          fontSize: cell * 0.82,
          height: 1.0,
          shadows: const [Shadow(color: Color(0x55000000), blurRadius: 2, offset: Offset(0, 1))],
          fontFamilyFallback: const ['Apple Symbols', 'Arial Unicode MS', 'Noto Sans Symbols2'],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) =>
      old.frame != frame || old.dark != dark;
}
