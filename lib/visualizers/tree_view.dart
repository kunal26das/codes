import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders a [TreeFrame] (a binary-search-tree snapshot). Node x-positions
/// follow in-order rank so children sit left/right of their parent; y follows
/// depth.
class TreeView extends StatelessWidget {
  const TreeView({super.key, required this.frame});

  final TreeFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _TreePainter(
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

class _TreePainter extends CustomPainter {
  _TreePainter({
    required this.frame,
    required this.dark,
    required this.surface,
    required this.border,
    required this.ink,
  });

  final TreeFrame frame;
  final bool dark;
  final Color surface;
  final Color border;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.rootId == null || frame.nodes.isEmpty) return;
    final byId = {for (final node in frame.nodes) node.id: node};

    // In-order rank → x slot; depth → y.
    final rank = <int, int>{};
    final depthOf = <int, int>{};
    var counter = 0;
    var maxDepth = 0;
    void inorder(int? id, int depth) {
      if (id == null) return;
      final node = byId[id];
      if (node == null) return;
      inorder(node.left, depth + 1);
      rank[id] = counter++;
      depthOf[id] = depth;
      if (depth > maxDepth) maxDepth = depth;
      inorder(node.right, depth + 1);
    }

    inorder(frame.rootId, 0);
    final count = counter;
    if (count == 0) return;

    const r = 18.0;
    final usableW = size.width - r * 2;
    final usableH = size.height - r * 2;
    Offset posOf(int id) {
      final x = r + (count == 1 ? usableW / 2 : rank[id]! / (count - 1) * usableW);
      final y = r + (maxDepth == 0 ? 0 : depthOf[id]! / maxDepth * usableH);
      return Offset(x, y);
    }

    // Edges first.
    final edge = Paint()
      ..color = border
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final node in frame.nodes) {
      final from = posOf(node.id);
      for (final child in [node.left, node.right]) {
        if (child != null && byId.containsKey(child)) {
          canvas.drawLine(from, posOf(child), edge);
        }
      }
    }

    // Nodes.
    for (final node in frame.nodes) {
      final p = posOf(node.id);
      final highlighted = frame.highlight.contains(node.id);
      final fill = Paint()..color = highlighted ? AppColors.active : surface;
      final ring = Paint()
        ..color = highlighted ? AppColors.active : border
        ..strokeWidth = highlighted ? 2.4 : 1.4
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(p, r, fill);
      canvas.drawCircle(p, r, ring);

      final tp = TextPainter(
        text: TextSpan(
          text: '${node.value}',
          style: TextStyle(
            color: highlighted ? Colors.white : ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) =>
      old.frame != frame || old.surface != surface;
}
