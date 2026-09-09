import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';
import 'zoomable_canvas.dart';

/// Renders one [GTreeFrame]: a general tree with rectangular, label-sized nodes
/// laid out top-down. Node colour follows [GNodeState], and edges may carry
/// labels (e.g. minimax moves or B-tree separators).
class GTreeView extends StatelessWidget {
  const GTreeView({super.key, required this.frame});

  final GTreeFrame frame;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final layout = _TreeSpace.forFrame(frame);
    return ZoomableCanvas(
      minimumSize: Size(layout.width, layout.height),
      builder: (size) => CustomPaint(
        key: const ValueKey('general-tree-canvas'),
        size: size,
        painter: _GTreePainter(
          frame: frame,
          surface: theme.cardColor,
          border: theme.dividerColor,
          ink: dark ? AppColors.inkDark : AppColors.ink,
          dark: dark,
          padX: layout.padX,
        ),
      ),
    );
  }
}

/// Reserve enough space for adjacent nodes and the labels halfway along edges.
/// The viewer fits this canvas initially and lets crowded trees be magnified.
class _TreeSpace {
  const _TreeSpace(this.width, this.height, this.padX);

  final double width;
  final double height;
  final double padX;

  factory _TreeSpace.forFrame(GTreeFrame frame) {
    final nodes = {for (final node in frame.nodes) node.id: node};
    var leaves = 0;
    var depth = 0;
    var nodeWidth = 30.0;
    var edgeWidth = 0.0;
    void visit(int id, int level) {
      final node = nodes[id];
      if (node == null) return;
      depth = math.max(depth, level);
      nodeWidth = math.max(nodeWidth, _textWidth(node.label, 13) + 18);
      if (node.edgeLabel != null) {
        edgeWidth = math.max(edgeWidth, _textWidth(node.edgeLabel!, 11) + 6);
      }
      final children = node.children.where(nodes.containsKey);
      if (children.isEmpty) leaves++;
      for (final child in children) {
        visit(child, level + 1);
      }
    }

    visit(frame.rootId, 0);
    final pad = math.max(24.0, nodeWidth / 2 + 8);
    final spacing = math.max(nodeWidth + 16, edgeWidth * 2 + 16);
    return _TreeSpace(
      pad * 2 + math.max(0, leaves - 1) * spacing,
      58 + depth * 64,
      pad,
    );
  }

  static double _textWidth(String text, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

class _GTreePainter extends CustomPainter {
  _GTreePainter({
    required this.frame,
    required this.surface,
    required this.border,
    required this.ink,
    required this.dark,
    required this.padX,
  });

  final GTreeFrame frame;
  final Color surface;
  final Color border;
  final Color ink;
  final bool dark;
  final double padX;

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final n in frame.nodes) n.id: n};
    if (!byId.containsKey(frame.rootId)) return;

    final xOf = <int, double>{};
    final depthOf = <int, int>{};
    var leafCounter = 0;
    var maxDepth = 0;
    var leafCount = 0;

    void countLeaves(int id) {
      final kids = byId[id]!.children.where(byId.containsKey).toList();
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
      depthOf[id] = depth;
      if (depth > maxDepth) maxDepth = depth;
      final kids = byId[id]!.children.where(byId.containsKey).toList();
      double x;
      if (kids.isEmpty) {
        x = leafCount == 1 ? 0.5 : leafCounter / slots;
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

    const h = 26.0;
    final usableW = size.width - padX * 2;
    final usableH = size.height - h - 24;
    Offset posOf(int id) {
      final x = padX + xOf[id]! * usableW;
      final y =
          16 + h / 2 + (maxDepth == 0 ? 0 : depthOf[id]! / maxDepth * usableH);
      return Offset(x, y);
    }

    double widthFor(GTreeNode n) {
      final tp = _tp(n.label, ink, 13, bold: true);
      return math.max(30.0, tp.width + 18);
    }

    // Edges.
    for (final n in frame.nodes) {
      final from = posOf(n.id);
      for (final c in n.children) {
        if (!byId.containsKey(c)) continue;
        final to = posOf(c);
        canvas.drawLine(
          from,
          to,
          Paint()
            ..color = border
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
        );
        final el = byId[c]!.edgeLabel;
        if (el != null) {
          final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
          final tp = _tp(el, ink.withValues(alpha: 0.7), 11);
          final box = Rect.fromCenter(
            center: mid,
            width: tp.width + 6,
            height: tp.height + 2,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(3)),
            Paint()..color = surface,
          );
          tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
        }
      }
    }

    // Nodes.
    for (final n in frame.nodes) {
      final p = posOf(n.id);
      final w = widthFor(n);
      final rect = Rect.fromCenter(center: p, width: w, height: h);
      final (fill, txt) = _colors(n.state);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        Paint()..color = fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        Paint()
          ..color = fill == surface ? border : fill
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
      final tp = _tp(n.label, txt, 13, bold: true);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  (Color, Color) _colors(GNodeState s) {
    switch (s) {
      case GNodeState.normal:
        return (surface, ink);
      case GNodeState.highlight:
        return (AppColors.compare, Colors.white);
      case GNodeState.active:
        return (AppColors.active, Colors.white);
      case GNodeState.good:
        return (AppColors.done, Colors.white);
      case GNodeState.red:
        return (const Color(0xFFC0392B), Colors.white);
      case GNodeState.black:
        return (const Color(0xFF2B2B2B), Colors.white);
      case GNodeState.pruned:
        return (
          dark ? AppColors.idleDark : AppColors.idle,
          ink.withValues(alpha: 0.55),
        );
    }
  }

  TextPainter _tp(String s, Color color, double size, {bool bold = false}) =>
      TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  bool shouldRepaint(covariant _GTreePainter old) =>
      old.frame != frame || old.surface != surface || old.padX != padX;
}
