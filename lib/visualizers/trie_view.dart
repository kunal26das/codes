import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [TrieFrame]: a prefix tree laid out top-down, each edge labelled
/// by its character. Word-ending nodes get a filled ring; the active path is
/// highlighted.
class TrieView extends StatelessWidget {
  const TrieView({super.key, required this.frame});

  final TrieFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _TriePainter(
          frame: frame,
          surface: theme.cardColor,
          border: theme.dividerColor,
          ink: dark ? AppColors.inkDark : AppColors.ink,
        ),
      ),
    );
  }
}

class _TriePainter extends CustomPainter {
  _TriePainter({
    required this.frame,
    required this.surface,
    required this.border,
    required this.ink,
  });

  final TrieFrame frame;
  final Color surface;
  final Color border;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final node in frame.nodes) node.id: node};
    if (!byId.containsKey(frame.rootId)) return;

    // Tidy layout: leaves take successive x-slots; internal nodes centre over
    // their children. Depth gives the y-coordinate.
    final xOf = <int, double>{};
    final depthOf = <int, int>{};
    var leafCounter = 0;
    var maxDepth = 0;
    var leafCount = 0;

    // First count leaves for normalisation.
    void countLeaves(int id) {
      final node = byId[id]!;
      final kids = node.children.where(byId.containsKey).toList();
      if (kids.isEmpty) {
        leafCount++;
      } else {
        for (final c in kids) {
          countLeaves(c);
        }
      }
    }

    countLeaves(frame.rootId);
    final slots = leafCount <= 1 ? 1 : leafCount - 1;

    double layout(int id, int depth) {
      final node = byId[id]!;
      depthOf[id] = depth;
      if (depth > maxDepth) maxDepth = depth;
      final kids = node.children.where(byId.containsKey).toList();
      double x;
      if (kids.isEmpty) {
        x = slots == 0 ? 0.5 : leafCounter / slots;
        leafCounter++;
      } else {
        var sum = 0.0;
        for (final c in kids) {
          sum += layout(c, depth + 1);
        }
        x = sum / kids.length;
      }
      xOf[id] = x;
      return x;
    }

    layout(frame.rootId, 0);

    const r = 16.0;
    final usableW = size.width - r * 2 - 20;
    final usableH = size.height - r * 2 - 20;
    Offset posOf(int id) {
      final x = r + 10 + xOf[id]! * usableW;
      final y = r + 10 + (maxDepth == 0 ? 0 : depthOf[id]! / maxDepth * usableH);
      return Offset(x, y);
    }

    // Edges with their character labels.
    final edge = Paint()
      ..color = border
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final node in frame.nodes) {
      final from = posOf(node.id);
      for (final c in node.children) {
        if (!byId.containsKey(c)) continue;
        final to = posOf(c);
        final onPath = frame.highlight.contains(c) && frame.highlight.contains(node.id);
        canvas.drawLine(
          from,
          to,
          onPath
              ? (Paint()
                ..color = AppColors.clayBright
                ..strokeWidth = 2.6
                ..style = PaintingStyle.stroke)
              : edge,
        );
        final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
        _text(canvas, byId[c]!.label, mid, AppColors.clayBright, 13, center: true, bold: true,
            bg: surface);
      }
    }

    // Nodes.
    for (final node in frame.nodes) {
      final p = posOf(node.id);
      final hot = frame.highlight.contains(node.id);
      final isRoot = node.id == frame.rootId;
      canvas.drawCircle(p, r, Paint()..color = hot ? AppColors.active : surface);
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = hot ? AppColors.active : (node.isWord ? AppColors.done : border)
          ..strokeWidth = node.isWord ? 3 : 1.5
          ..style = PaintingStyle.stroke,
      );
      final label = isRoot ? '•' : node.label;
      _text(canvas, label, p, hot ? Colors.white : ink, isRoot ? 18 : 14, center: true, bold: true);
    }
  }

  void _text(Canvas canvas, String s, Offset at, Color color, double size,
      {bool center = false, bool bold = false, Color? bg}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final origin = center ? at - Offset(tp.width / 2, tp.height / 2) : at;
    if (bg != null) {
      final box = Rect.fromCenter(center: at, width: tp.width + 6, height: tp.height + 2);
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(3)), Paint()..color = bg);
    }
    tp.paint(canvas, origin);
  }

  @override
  bool shouldRepaint(covariant _TriePainter old) => old.frame != frame || old.surface != surface;
}
