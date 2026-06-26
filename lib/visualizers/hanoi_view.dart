import 'package:flutter/material.dart';

import '../models/frames.dart';
import '../theme/app_colors.dart';

/// Renders one [HanoiFrame] of the Tower of Hanoi.
class HanoiView extends StatelessWidget {
  const HanoiView({super.key, required this.frame, required this.diskCount});

  final HanoiFrame frame;
  final int diskCount;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _HanoiPainter(frame: frame, diskCount: diskCount, dark: dark),
      ),
    );
  }
}

class _HanoiPainter extends CustomPainter {
  _HanoiPainter({
    required this.frame,
    required this.diskCount,
    required this.dark,
  });

  final HanoiFrame frame;
  final int diskCount;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final pegSpacing = size.width / 3;
    final baseY = size.height - 24;
    final diskH = ((size.height - 60) / diskCount).clamp(8.0, 26.0);
    final maxDiskW = pegSpacing * 0.8;
    final minDiskW = maxDiskW * 0.32;

    // Pegs + base.
    final post = Paint()..color = dark ? AppColors.borderDark : AppColors.border;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, baseY, size.width - 16, 8),
        const Radius.circular(4),
      ),
      post,
    );
    for (var i = 0; i < 3; i++) {
      final cx = pegSpacing * i + pegSpacing / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 3, baseY - (diskH * diskCount + 16), 6,
              diskH * diskCount + 16),
          const Radius.circular(3),
        ),
        post,
      );
    }

    // Disks.
    for (var peg = 0; peg < 3; peg++) {
      final cx = pegSpacing * peg + pegSpacing / 2;
      final stack = frame.pegs[peg];
      for (var level = 0; level < stack.length; level++) {
        final disk = stack[level];
        final t = diskCount == 1 ? 1.0 : (disk - 1) / (diskCount - 1);
        final w = minDiskW + (maxDiskW - minDiskW) * t;
        final y = baseY - diskH * (level + 1);
        final moving = frame.movingDisk == disk;
        final color = Color.lerp(AppColors.highlight, AppColors.clay, t)!;
        final rect = Rect.fromLTWH(cx - w / 2, y + 1, w, diskH - 2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = moving ? AppColors.active : color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HanoiPainter old) =>
      old.frame != frame || old.dark != dark;
}
