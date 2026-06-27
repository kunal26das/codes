import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Liquid glass
///
/// AlgoScope's surfaces are rendered with Apple-style **Liquid Glass** via the
/// shader-based `liquid_glass_renderer`: each pane genuinely refracts and
/// lenses the colored backdrop behind it, with specular highlights that bend
/// around its rounded edges — not a flat frosted blur.
/// ─────────────────────────────────────────────────────────────────────────

/// Tunables shared by every glass surface so the look stays consistent.
class Glass {
  Glass._();

  /// A glass tint that adapts to the active theme. Low opacity keeps the
  /// refraction reading as clear glass rather than a painted card.
  static Color tint(BuildContext context, {double opacity = 0.18}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return (dark ? const Color(0xFF2A2927) : Colors.white)
        .withValues(alpha: opacity);
  }

  /// Default settings for a resting pane.
  static LiquidGlassSettings settings(
    BuildContext context, {
    Color? tintColor,
    double thickness = 14,
    double blur = 3,
    double lightIntensity = 0.8,
    double lightAngle = -0.35 * math.pi,
  }) {
    return LiquidGlassSettings(
      glassColor: tintColor ?? tint(context),
      thickness: thickness,
      blur: blur,
      lightAngle: lightAngle,
      lightIntensity: lightIntensity,
      ambientStrength: 0.1,
      refractiveIndex: 1.35,
      chromaticAberration: 0.04,
      saturation: 1.2,
    );
  }
}

/// A real Liquid Glass pane — refracts and lenses whatever colored backdrop
/// sits behind it, with shader-rendered edge highlights. The building block
/// for cards, bars and chips.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding,
    this.settings,
    this.boxShadow,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final LiquidGlassSettings? settings;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final glass = LiquidGlass.withOwnLayer(
      shape: LiquidRoundedSuperellipse(borderRadius: radius),
      settings: settings ?? Glass.settings(context),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
    if (boxShadow == null) return glass;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      ),
      child: glass,
    );
  }
}

/// A soft, colored backdrop of blurred "blobs" that the glass panes float over.
/// The blobs drift slowly along Lissajous paths so the color flowing through
/// the refraction shader actually *moves* — that's what makes the glass read as
/// liquid rather than a static frost.
class GlassBackdrop extends StatefulWidget {
  const GlassBackdrop({super.key, this.accents});

  /// Optional accent colors for the blobs (e.g. a category color). Falls back
  /// to the warm clay/slate/sage house palette.
  final List<Color>? accents;

  @override
  State<GlassBackdrop> createState() => _GlassBackdropState();
}

class _GlassBackdropState extends State<GlassBackdrop> {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // A solid, readable canvas.
    final base = dark ? const Color(0xFF1F1E1D) : const Color(0xFFFAF9F5);
    return ColoredBox(color: base);
  }
}

/// Wraps a screen body so it sits on the [GlassBackdrop]. Use with a
/// transparent [Scaffold] (and `extendBodyBehindAppBar: true`) so the blobs
/// reach edge to edge.
class GlassScaffoldBackground extends StatelessWidget {
  const GlassScaffoldBackground({super.key, required this.child, this.accents});

  final Widget child;
  final List<Color>? accents;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: GlassBackdrop(accents: accents)),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// A tappable glass card that gently lifts and brightens on hover/focus.
///
/// Pointer hover (web + desktop) animates a soft shadow, a 3px rise and a
/// warmer accent edge; the whole card reads as one interactive sheet of glass.
/// Falls back gracefully to a plain tap target on touch.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    required this.onTap,
    this.accent,
    this.padding = const EdgeInsets.all(16),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  // Light angle the specular highlight points toward. Resting glass is lit
  // from the upper-left; on hover it tilts to follow the pointer, like real
  // glass catching a lamp as you move past it.
  double _lightAngle = -0.35 * math.pi;
  Size _size = Size.zero;

  void _track(PointerEvent e) {
    if (_size.isEmpty) return;
    final dx = e.localPosition.dx - _size.width / 2;
    final dy = e.localPosition.dy - _size.height / 2;
    final next = math.atan2(dy, dx);
    if ((next - _lightAngle).abs() > 0.05) {
      setState(() => _lightAngle = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.accent ?? theme.colorScheme.primary;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: LayoutBuilder(builder: (context, constraints) {
        _size = constraints.biggest;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
          onHover: _track,
          onExit: (_) => setState(() {
            _hover = false;
            _lightAngle = -0.35 * math.pi;
          }),
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
            child: GlassPanel(
              radius: 22,
              settings: Glass.settings(
                context,
                // Hover "thickens" the glass and tints it toward the accent —
                // the shader lenses the backdrop more strongly — and the
                // highlight tilts toward the pointer.
                thickness: _hover ? 22 : 14,
                lightIntensity: _hover ? 1.0 : 0.8,
                lightAngle: _lightAngle,
                tintColor: _hover
                    ? accent.withValues(alpha: 0.16)
                    : Glass.tint(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: (_hover ? accent : Colors.black)
                      .withValues(alpha: _hover ? 0.22 : 0.10),
                  blurRadius: _hover ? 28 : 16,
                  offset: Offset(0, _hover ? 12 : 6),
                ),
              ],
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(22),
                  hoverColor: accent.withValues(alpha: 0.04),
                  splashColor: accent.withValues(alpha: 0.10),
                  child: Padding(padding: widget.padding, child: widget.child),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// A small rounded glass label used for complexity and tags.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.text, this.color, this.icon});

  final String text;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GlassPanel(
      radius: 10,
      settings: Glass.settings(
        context,
        thickness: 10,
        blur: 2,
        lightIntensity: 0.9,
        tintColor: c.withValues(alpha: 0.16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// A coloured dot followed by a label, used in the visualizer legend.
class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
