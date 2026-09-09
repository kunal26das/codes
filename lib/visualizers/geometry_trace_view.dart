import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/geometry_trace.dart';
import '../theme/app_colors.dart';
import 'zoomable_canvas.dart';

class GeometryTraceView extends StatelessWidget {
  const GeometryTraceView({super.key, required this.frame});
  final GeometryTrace frame;

  @override
  Widget build(BuildContext context) => ZoomableCanvas(
    minimumSize: const Size(700, 480),
    builder: (size) => CustomPaint(
      size: size,
      painter: _GeometryPainter(frame, Theme.of(context)),
    ),
  );
}

class _GeometryPainter extends CustomPainter {
  _GeometryPainter(this.frame, this.theme);
  final GeometryTrace frame;
  final ThemeData theme;

  Color color(GeoRole role) => switch (role) {
    GeoRole.original => theme.colorScheme.onSurface.withValues(alpha: 0.4),
    GeoRole.working => AppColors.compare,
    GeoRole.result => AppColors.done,
    GeoRole.guide => AppColors.highlight,
  };

  void text(
    Canvas canvas,
    String value,
    Offset at, {
    double size = 12,
    Color? ink,
    double maxWidth = 200,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: size,
          color: ink ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, at);
    painter.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = frame.bounds;
    final available = Rect.fromLTWH(52, 46, size.width - 80, size.height - 160);
    final scale = math.min(
      available.width / (bounds.maxX - bounds.minX),
      available.height / (bounds.maxY - bounds.minY),
    );
    final plotSize = Size(
      (bounds.maxX - bounds.minX) * scale,
      (bounds.maxY - bounds.minY) * scale,
    );
    final plot = Rect.fromCenter(
      center: available.center,
      width: plotSize.width,
      height: plotSize.height,
    );
    Offset at(GeoPoint point) => Offset(
      plot.left + (point.x - bounds.minX) * scale,
      plot.bottom - (point.y - bounds.minY) * scale,
    );
    final tick = math.max(
      1,
      ((bounds.maxX - bounds.minX).clamp(
                bounds.maxY - bounds.minY,
                double.infinity,
              ) /
              12)
          .ceil(),
    );
    final grid = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.65)
      ..strokeWidth = 0.7;
    for (
      var x = (bounds.minX / tick).ceil() * tick;
      x <= bounds.maxX;
      x += tick
    ) {
      final p = at(GeoPoint(x.toDouble(), bounds.minY));
      canvas.drawLine(Offset(p.dx, plot.top), Offset(p.dx, plot.bottom), grid);
      text(
        canvas,
        '$x',
        Offset(p.dx - 8, plot.bottom + 5),
        size: 10,
        maxWidth: 40,
      );
    }
    for (
      var y = (bounds.minY / tick).ceil() * tick;
      y <= bounds.maxY;
      y += tick
    ) {
      final p = at(GeoPoint(bounds.minX, y.toDouble()));
      canvas.drawLine(Offset(plot.left, p.dy), Offset(plot.right, p.dy), grid);
      text(
        canvas,
        '$y',
        Offset(plot.left - 32, p.dy - 6),
        size: 10,
        maxWidth: 30,
      );
    }
    final window = frame.clipWindow;
    if (window != null) {
      final rect = Rect.fromPoints(
        at(GeoPoint(window.minX, window.minY)),
        at(GeoPoint(window.maxX, window.maxY)),
      );
      canvas.drawRect(
        rect,
        Paint()..color = AppColors.highlight.withValues(alpha: 0.07),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.highlight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    var legendX = 12.0;
    final seen = <String>{};
    for (final layer in frame.layers) {
      final ink = color(layer.role);
      if (seen.add(layer.label)) {
        canvas.drawCircle(Offset(legendX + 4, 19), 4, Paint()..color = ink);
        text(
          canvas,
          layer.label,
          Offset(legendX + 14, 11),
          maxWidth: 130,
          ink: ink,
        );
        legendX += 155;
      }
      final points = layer.points.map(at).toList();
      if (points.isEmpty) continue;
      if (layer.shape == GeoShape.pixels) {
        for (final p in points) {
          canvas.drawRect(
            Rect.fromCenter(
              center: p,
              width: scale * 0.82,
              height: scale * 0.82,
            ),
            Paint()..color = ink.withValues(alpha: 0.75),
          );
        }
      } else {
        if (layer.shape != GeoShape.points && points.length > 1) {
          final path = Path()..moveTo(points.first.dx, points.first.dy);
          for (final p in points.skip(1)) {
            path.lineTo(p.dx, p.dy);
          }
          if (layer.shape == GeoShape.polygon) {
            path.close();
            canvas.drawPath(path, Paint()..color = ink.withValues(alpha: 0.1));
          }
          canvas.drawPath(
            path,
            Paint()
              ..color = ink
              ..style = PaintingStyle.stroke
              ..strokeWidth = layer.role == GeoRole.original ? 1.5 : 2.5,
          );
        }
        for (var i = 0; i < points.length; i++) {
          canvas.drawCircle(
            points[i],
            layer.role == GeoRole.original ? 3 : 4,
            Paint()..color = ink,
          );
          if (layer.role == GeoRole.original && points.length <= 10) {
            text(
              canvas,
              '$i',
              points[i] + const Offset(5, -16),
              size: 11,
              ink: ink,
              maxWidth: 30,
            );
          }
        }
      }
    }
    final variables = frame.variables.entries.toList();
    for (var i = 0; i < variables.length; i++) {
      text(
        canvas,
        '${variables[i].key}: ${variables[i].value}',
        Offset(
          12 + (i % 3) * (size.width - 24) / 3,
          size.height - 82 + (i ~/ 3) * 21,
        ),
        size: 12,
        maxWidth: (size.width - 44) / 3,
      );
    }
    if (frame.result.isNotEmpty) {
      text(
        canvas,
        frame.result,
        Offset(12, size.height - 27),
        size: 14,
        ink: theme.colorScheme.primary,
        maxWidth: size.width - 24,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GeometryPainter old) =>
      old.frame != frame || old.theme != theme;
}
