import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [KnightFrame] of the Knight's Tour: a chessboard with the visit
/// order numbered on each square and a polyline through the tour so far.
class KnightView extends StatelessWidget {
  const KnightView({super.key, required this.frame});

  final KnightFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth.clamp(0, constraints.maxHeight).toDouble();
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: CustomPaint(painter: _KnightPainter(frame: frame, dark: dark)),
          ),
        );
      },
    );
  }
}

class _KnightPainter extends CustomPainter {
  _KnightPainter({required this.frame, required this.dark});

  final KnightFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.n;
    final cell = size.width / n;
    final lightSq = dark ? const Color(0xFF35332F) : const Color(0xFFF0EEE6);
    final darkSq = dark ? const Color(0xFF2A2927) : const Color(0xFFE2DDD0);

    Offset center(int i) => Offset((i % n) * cell + cell / 2, (i ~/ n) * cell + cell / 2);

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final i = r * n + c;
        var color = (r + c).isEven ? lightSq : darkSq;
        if (frame.board[i] > 0) color = Color.lerp(color, AppColors.done, 0.28)!;
        if (frame.tryCell == i) color = const Color(0x55E0A458);
        if (frame.current == i) color = frame.solved ? AppColors.done : AppColors.active;
        canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), Paint()..color = color);
      }
    }

    // Connecting polyline through the visited squares in order.
    final order = <int, int>{}; // move number -> cell
    for (var i = 0; i < frame.board.length; i++) {
      if (frame.board[i] > 0) order[frame.board[i]] = i;
    }
    final line = Paint()
      ..color = AppColors.clayBright.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var m = 1; order.containsKey(m) && order.containsKey(m + 1); m++) {
      canvas.drawLine(center(order[m]!), center(order[m + 1]!), line);
    }

    // Move-order numbers on visited squares (skip the one under the knight).
    for (var i = 0; i < frame.board.length; i++) {
      final o = frame.board[i];
      if (o <= 0 || i == frame.current) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: '$o',
          style: TextStyle(
            color: (dark ? AppColors.inkSoftDark : AppColors.inkSoft),
            fontSize: cell * 0.24,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center(i) - Offset(tp.width / 2, tp.height / 2));
    }

    // The knight itself — a real chess piece on the current square.
    final cur = frame.current;
    if (cur != null) {
      final c = center(cur);
      final knight = TextPainter(
        text: TextSpan(
          text: '♞',
          style: TextStyle(
            color: Colors.white,
            fontSize: cell * 0.82,
            height: 1.0,
            shadows: const [Shadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))],
            fontFamilyFallback: const ['Apple Symbols', 'Arial Unicode MS', 'Noto Sans Symbols2'],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      knight.paint(canvas, c - Offset(knight.width / 2, knight.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _KnightPainter old) => old.frame != frame || old.dark != dark;
}
