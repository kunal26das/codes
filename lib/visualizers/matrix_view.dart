import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [MatrixFrame] as three labelled grids: A op B = C, with the
/// row/column feeding the active result cell highlighted.
class MatrixView extends StatelessWidget {
  const MatrixView({super.key, required this.frame});

  final MatrixFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _MatrixPainter(frame: frame, dark: dark),
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  _MatrixPainter({required this.frame, required this.dark});

  final MatrixFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final aCols = frame.a[0].length;
    final bCols = frame.b[0].length;
    final cCols = frame.c[0].length;
    final maxRows = [frame.a.length, frame.b.length, frame.c.length]
        .reduce((x, y) => x > y ? x : y);

    // Total horizontal "columns" including two operator gaps (~1 col each).
    final totalCols = aCols + bCols + cCols + 3.0;
    final cell = (size.width / totalCols)
        .clamp(0, (size.height - 24) / maxRows)
        .toDouble();

    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final headerBg = dark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    final border = Paint()
      ..color = (dark ? AppColors.borderDark : AppColors.border)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blockHeight = maxRows * cell;
    final top = (size.height - blockHeight) / 2;

    double drawMatrix(
      double startX,
      List<List<int>> m,
      String name,
      Set<int> hiRows,
      Set<int> hiCols, {
      bool isResult = false,
    }) {
      final rows = m.length;
      final cols = m[0].length;
      final yOffset = top + (blockHeight - rows * cell) / 2;
      for (var i = 0; i < rows; i++) {
        for (var j = 0; j < cols; j++) {
          final x = startX + j * cell;
          final y = yOffset + i * cell;
          Color fill = base;
          if (hiRows.contains(i) || hiCols.contains(j)) {
            fill = Color.lerp(base, AppColors.compare, 0.30)!;
          }
          if (isResult) {
            final key = i * cols + j;
            if (!frame.filled.contains(key)) fill = Color.lerp(base, headerBg, 0.5)!;
            if (frame.activeR == i && frame.activeC == j) {
              fill = Color.lerp(base, AppColors.active, 0.45)!;
            }
          }
          final rect = Rect.fromLTWH(x, y, cell, cell);
          canvas.drawRect(rect, Paint()..color = fill);
          canvas.drawRect(rect, border);
          final show = !isResult || frame.filled.contains(i * cols + j);
          if (show) {
            final tp = TextPainter(
              text: TextSpan(
                text: '${m[i][j]}',
                style: TextStyle(color: ink, fontSize: cell * 0.34, fontWeight: FontWeight.w600),
              ),
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: cell);
            tp.paint(canvas, Offset(x + (cell - tp.width) / 2, y + (cell - tp.height) / 2));
          }
        }
      }
      // Label under the matrix.
      final label = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(startX + (cols * cell - label.width) / 2, yOffset + rows * cell + 4));
      return startX + cols * cell;
    }

    void drawGlyph(String g, double x) {
      final tp = TextPainter(
        text: TextSpan(
          text: g,
          style: TextStyle(color: ink, fontSize: cell * 0.6, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + (cell - tp.width) / 2, top + (blockHeight - tp.height) / 2));
    }

    var x = 0.0;
    x = drawMatrix(x, frame.a, 'A', frame.aRows, frame.aCols);
    drawGlyph(frame.op, x);
    x += cell;
    x = drawMatrix(x, frame.b, 'B', frame.bRows, frame.bCols);
    drawGlyph('=', x);
    x += cell;
    drawMatrix(x, frame.c, 'C', const {}, const {}, isResult: true);
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter old) => old.frame != frame || old.dark != dark;
}
