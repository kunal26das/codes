import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [GraphFrame] over the fixed [run] graph: weighted edges and
/// labelled nodes, with the MST built so far highlighted.
class GraphView extends StatelessWidget {
  const GraphView({super.key, required this.run, required this.frame});

  final GraphRun run;
  final GraphFrame frame;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GraphPainter(run: run, frame: frame, dark: dark),
        );
      },
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({required this.run, required this.frame, required this.dark});

  final GraphRun run;
  final GraphFrame frame;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 36.0;
    const r = 18.0;
    final stripH = frame.order.isNotEmpty ? 38.0 : 0.0;
    final w = size.width - pad * 2;
    final h = size.height - stripH - pad * 2;
    Offset nodeAt(int i) =>
        Offset(pad + run.positions[i][0] * w, pad + run.positions[i][1] * h);

    final base = dark ? AppColors.surfaceDark : AppColors.surface;
    final idleEdge = dark ? AppColors.borderDark : const Color(0xFFCDC8BB);
    final ink = dark ? AppColors.inkDark : AppColors.ink;

    // Edges.
    for (final e in run.edges) {
      final inTree = frame.treeEdges.contains(e.key);
      final candidate = frame.candidate == e.key;
      final color = inTree
          ? AppColors.clayBright
          : candidate
              ? AppColors.compare
              : idleEdge;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = inTree || candidate ? 4 : 2
        ..color = color;
      final p1 = nodeAt(e.a), p2 = nodeAt(e.b);

      if (run.directed) {
        // Stop the line at the target node's rim and draw an arrowhead.
        final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
        final tip = p2 - Offset(math.cos(angle) * r, math.sin(angle) * r);
        canvas.drawLine(p1, tip, paint);
        const ah = 9.0;
        final head = Paint()..color = color;
        final path = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - ah * math.cos(angle - 0.45), tip.dy - ah * math.sin(angle - 0.45))
          ..lineTo(tip.dx - ah * math.cos(angle + 0.45), tip.dy - ah * math.sin(angle + 0.45))
          ..close();
        canvas.drawPath(path, head);
      } else {
        canvas.drawLine(p1, p2, paint);
        // Weight label at the midpoint (only weighted graphs).
        final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        final tp = TextPainter(
          text: TextSpan(
            text: '${e.w}',
            style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final box = Rect.fromCenter(center: mid, width: tp.width + 8, height: tp.height + 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(4)),
          Paint()..color = base,
        );
        tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Nodes.
    for (var i = 0; i < run.nodeLabels.length; i++) {
      final c = nodeAt(i);
      final colored = frame.colors.containsKey(i);
      final inTree = frame.inTree.contains(i);
      final isCurrent = frame.current == i;
      final fill = colored
          ? AppColors.palette[frame.colors[i]! % AppColors.palette.length]
          : (inTree ? AppColors.done : base);
      canvas.drawCircle(c, r, Paint()..color = fill);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCurrent ? 3.5 : 1.5
          ..color = isCurrent ? AppColors.active : idleEdge,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: run.nodeLabels[i],
          style: TextStyle(
            color: colored || inTree ? Colors.white : ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));

      // Shortest-distance label (Bellman–Ford).
      if (frame.dist.isNotEmpty) {
        final d = frame.dist[i];
        final label = d == null || d >= (1 << 28) ? '∞' : '$d';
        final dt = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: AppColors.clayBright, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final box = Rect.fromCenter(center: c + const Offset(0, r + 9), width: dt.width + 8, height: dt.height + 3);
        canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(4)), Paint()..color = base);
        dt.paint(canvas, c + Offset(-dt.width / 2, r + 9 - dt.height / 2));
      }
    }

    // Output-order strip (e.g. topological sort).
    if (frame.order.isNotEmpty) {
      const chip = 26.0;
      var x = pad;
      final y = size.height - stripH + 6;
      for (var k = 0; k < frame.order.length; k++) {
        final id = frame.order[k];
        final rect = Rect.fromLTWH(x, y, chip, chip);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = AppColors.done,
        );
        final tp = TextPainter(
          text: TextSpan(
            text: run.nodeLabels[id],
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + (chip - tp.width) / 2, y + (chip - tp.height) / 2));
        x += chip + 6;
        if (k < frame.order.length - 1) {
          final arrow = TextPainter(
            text: TextSpan(
              text: '→',
              style: TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          arrow.paint(canvas, Offset(x - 3, y + (chip - arrow.height) / 2));
          x += arrow.width + 2;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.frame != frame || old.dark != dark;
}
