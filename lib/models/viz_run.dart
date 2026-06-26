import 'package:flutter/widgets.dart';

/// A self-contained, replayable visualization: a fixed number of frames,
/// a caption per frame, and a builder that renders a given frame index.
///
/// Algorithms produce a [VizRun] so the player screen can stay generic —
/// it only steps an index from 0..[frameCount]-1.
class VizRun {
  VizRun({
    required this.frameCount,
    required this.captionAt,
    required this.builder,
  });

  final int frameCount;
  final String Function(int index) captionAt;
  final Widget Function(BuildContext context, int index) builder;
}
