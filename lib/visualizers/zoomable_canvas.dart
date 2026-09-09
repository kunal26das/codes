import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps the complete diagram in view while allowing its labels to be read at
/// their intended size. Buttons make zoom available without a pinch gesture.
class ZoomableCanvas extends StatefulWidget {
  const ZoomableCanvas({
    super.key,
    required this.minimumSize,
    required this.builder,
  });

  final Size minimumSize;
  final Widget Function(Size size) builder;

  @override
  State<ZoomableCanvas> createState() => _ZoomableCanvasState();
}

class _ZoomableCanvasState extends State<ZoomableCanvas> {
  final _transform = TransformationController();

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _zoom(double factor, Size viewport, double maximum) {
    final oldScale = _transform.value.getMaxScaleOnAxis();
    final newScale = (oldScale * factor).clamp(1.0, maximum);
    if (newScale == 1) {
      _transform.value = Matrix4.identity();
      return;
    }
    final center = viewport.center(Offset.zero);
    final scene = _transform.toScene(center);
    _transform.value = Matrix4.identity()
      ..translateByDouble(
        center.dx - scene.dx * newScale,
        center.dy - scene.dy * newScale,
        0,
        1,
      )
      ..scaleByDouble(newScale, newScale, 1, 1);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = constraints.biggest;
      final size = Size(
        math.max(widget.minimumSize.width, viewport.width),
        math.max(widget.minimumSize.height, viewport.height),
      );
      final maximum = math.max(
        5.0,
        math.max(size.width / viewport.width, size.height / viewport.height) *
            1.5,
      );
      return Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: 1,
              maxScale: maximum,
              child: SizedBox.expand(
                child: FittedBox(
                  child: SizedBox.fromSize(
                    size: size,
                    child: widget.builder(size),
                  ),
                ),
              ),
            ),
          ),
          if (size.width > viewport.width || size.height > viewport.height)
            Positioned(
              right: 0,
              top: 0,
              child: Material(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Zoom out',
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      onPressed: () => _zoom(1 / 1.5, viewport, maximum),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    IconButton(
                      tooltip: 'Fit diagram',
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      onPressed: () => _transform.value = Matrix4.identity(),
                      icon: const Icon(Icons.fit_screen_rounded),
                    ),
                    IconButton(
                      tooltip: 'Zoom in; drag the diagram to pan',
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      onPressed: () => _zoom(1.5, viewport, maximum),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
