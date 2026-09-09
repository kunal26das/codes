import 'dart:math';

import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// A Sudoku board with actual 2×2 boundaries and separate clue/choice styling.
class SudokuMiniView extends StatelessWidget {
  const SudokuMiniView({super.key, required this.frame, required this.clues});

  final TableFrame frame;
  final Set<int> clues;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: CustomPaint(painter: _SudokuPainter(frame, clues, dark)),
          ),
        );
      },
    );
  }
}

class _SudokuPainter extends CustomPainter {
  _SudokuPainter(this.frame, this.clues, this.dark);
  final TableFrame frame;
  final Set<int> clues;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 4;
    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        final key = r * 4 + c;
        var fill = clues.contains(key)
            ? (dark ? AppColors.surfaceAltDark : AppColors.surfaceAlt)
            : base;
        if (frame.refs.contains(key)) {
          fill = Color.lerp(fill, AppColors.compare, 0.35)!;
        }
        if (frame.activeR == r && frame.activeC == c) {
          fill = Color.lerp(fill, AppColors.active, 0.4)!;
        }
        canvas.drawRect(
          Rect.fromLTWH(c * cell, r * cell, cell, cell),
          Paint()..color = fill,
        );
        if (!frame.filled.contains(key)) continue;
        final text = TextPainter(
          text: TextSpan(
            text: '${frame.cells[r][c]}',
            style: TextStyle(
              color: clues.contains(key) ? ink : AppColors.done,
              fontSize: min(32.0, cell * 0.5),
              fontWeight: clues.contains(key)
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        text.paint(
          canvas,
          Offset(
            c * cell + (cell - text.width) / 2,
            r * cell + (cell - text.height) / 2,
          ),
        );
      }
    }
    for (var i = 0; i <= 4; i++) {
      final line = Paint()
        ..color = i.isEven
            ? ink
            : (dark ? AppColors.borderDark : AppColors.border)
        ..strokeWidth = i.isEven ? 2.5 : 1;
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), line);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), line);
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuPainter old) =>
      old.frame != frame || old.dark != dark || old.clues != clues;
}
