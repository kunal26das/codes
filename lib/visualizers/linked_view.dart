import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [LinkedFrame]: a row of value boxes joined by pointer arrows
/// (single → for a singly list, ⇄ for a doubly list) with an optional wrap-around
/// arrow for a circular list.
class LinkedView extends StatelessWidget {
  const LinkedView({super.key, required this.frame});

  final LinkedFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _LinkedPainter(
          frame: frame,
          dark: dark,
          surface: theme.cardColor,
          border: theme.dividerColor,
          ink: dark ? AppColors.inkDark : AppColors.ink,
        ),
      ),
    );
  }
}

class _LinkedPainter extends CustomPainter {
  _LinkedPainter({
    required this.frame,
    required this.dark,
    required this.surface,
    required this.border,
    required this.ink,
  });

  final LinkedFrame frame;
  final bool dark;
  final Color surface;
  final Color border;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final n = frame.nodes.length;
    if (n == 0) {
      _text(canvas, 'empty list', Offset(size.width / 2, size.height / 2),
          ink.withValues(alpha: 0.5), 14, center: true);
      return;
    }

    const boxW = 54.0;
    const boxH = 44.0;
    final gap = (boxW * 0.8).clamp(36.0, 60.0);
    final totalW = n * boxW + (n - 1) * gap;
    final startX = (size.width - totalW) / 2;
    final y = size.height / 2 - boxH / 2;

    Rect boxAt(int i) => Rect.fromLTWH(startX + i * (boxW + gap), y, boxW, boxH);

    final arrow = Paint()
      ..color = ink.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Pointer arrows between consecutive nodes.
    for (var i = 0; i < n - 1; i++) {
      final from = boxAt(i);
      final to = boxAt(i + 1);
      final y1 = frame.doubly ? from.center.dy - 6 : from.center.dy;
      _arrowLine(canvas, Offset(from.right, y1), Offset(to.left, y1), arrow);
      if (frame.doubly) {
        _arrowLine(canvas, Offset(to.left, to.center.dy + 6), Offset(from.right, from.center.dy + 6), arrow);
      }
    }

    // Circular wrap arrow from the tail back to the head.
    if (frame.circular && n >= 1) {
      final tail = boxAt(n - 1);
      final head = boxAt(0);
      final dipY = y + boxH + 26;
      final path = Path()
        ..moveTo(tail.center.dx, tail.bottom)
        ..cubicTo(tail.center.dx, dipY, head.center.dx, dipY, head.center.dx, head.bottom);
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.clayBright.withValues(alpha: 0.8)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      _arrowHead(canvas, Offset(head.center.dx, head.bottom), -math.pi / 2, AppColors.clayBright);
    }

    // Nodes.
    for (var i = 0; i < n; i++) {
      final node = frame.nodes[i];
      final rect = boxAt(i);
      final fill = node.highlight
          ? AppColors.done
          : node.fading
              ? AppColors.active
              : surface;
      final p = Paint()..color = node.fading ? fill.withValues(alpha: 0.45) : fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = node.highlight || node.fading ? fill : border
          ..strokeWidth = node.highlight || node.fading ? 2.4 : 1.4
          ..style = PaintingStyle.stroke,
      );
      _text(canvas, '${node.value}', rect.center, node.highlight ? Colors.white : ink, 17,
          center: true, bold: true);
    }

    // head / null labels.
    _text(canvas, 'head', Offset(boxAt(0).center.dx, y - 16), ink.withValues(alpha: 0.55), 12,
        center: true);
    if (!frame.circular) {
      _text(canvas, 'null', Offset(boxAt(n - 1).right + 20, boxAt(n - 1).center.dy),
          ink.withValues(alpha: 0.4), 12, center: true);
    }
  }

  void _arrowLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    canvas.drawLine(a, b, paint);
    _arrowHead(canvas, b, (b - a).direction, paint.color);
  }

  void _arrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    const ah = 7.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - ah * math.cos(angle - 0.5), tip.dy - ah * math.sin(angle - 0.5))
      ..lineTo(tip.dx - ah * math.cos(angle + 0.5), tip.dy - ah * math.sin(angle + 0.5))
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _text(Canvas canvas, String s, Offset at, Color color, double size,
      {bool center = false, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at);
  }

  @override
  bool shouldRepaint(covariant _LinkedPainter old) =>
      old.frame != frame || old.surface != surface || old.dark != dark;
}
