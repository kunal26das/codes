import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark [ThemeData] for AlgoScope.
///
/// Typography follows Claude's own type system: the serif **Tiempos** for
/// headings (with **Copernicus** for the largest display sizes) and the
/// grotesque **Styrene B** for body and UI. Those are licensed Klim Type
/// Foundry fonts, so they're requested by family name first — they render
/// wherever they're installed (e.g. a licensed desktop) or bundled into
/// `assets/fonts/`. Everywhere else the theme falls back to the closest open
/// substitutes, Source Serif 4 (≈ Tiempos) and Hanken Grotesk (≈ Styrene),
/// loaded via [GoogleFonts].
class AppTheme {
  AppTheme._();

  // Genuine Claude families (used if licensed/installed/bundled).
  static const String _serif = 'Tiempos';
  static const String _display = 'Copernicus';
  static const String _sans = 'Styrene B';

  static TextTheme _textTheme(TextTheme base, Color ink, Color soft) {
    // Open fallbacks — calling these registers the fonts with GoogleFonts.
    final serifFallback = GoogleFonts.sourceSerif4().fontFamily!;
    final sansFallback = GoogleFonts.hankenGrotesk().fontFamily!;
    final displayFallback = [_serif, serifFallback];
    final serifFallbacks = [serifFallback];
    final sansFallbacks = [sansFallback];

    TextStyle display(TextStyle? s) => (s ?? const TextStyle()).copyWith(
          fontFamily: _display,
          fontFamilyFallback: displayFallback,
          color: ink,
          fontWeight: FontWeight.w600,
        );
    TextStyle serif(TextStyle? s) => (s ?? const TextStyle()).copyWith(
          fontFamily: _serif,
          fontFamilyFallback: serifFallbacks,
          color: ink,
          fontWeight: FontWeight.w600,
        );
    TextStyle sans(TextStyle? s,
            {Color? color, FontWeight? weight, double? height}) =>
        (s ?? const TextStyle()).copyWith(
          fontFamily: _sans,
          fontFamilyFallback: sansFallbacks,
          color: color ?? ink,
          fontWeight: weight,
          height: height,
        );

    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall),
      headlineLarge: serif(base.headlineLarge),
      headlineMedium: serif(base.headlineMedium),
      headlineSmall: serif(base.headlineSmall),
      titleLarge: sans(base.titleLarge, weight: FontWeight.w600),
      titleMedium: sans(base.titleMedium, weight: FontWeight.w600),
      titleSmall: sans(base.titleSmall, color: soft, weight: FontWeight.w500),
      bodyLarge: sans(base.bodyLarge, height: 1.5),
      bodyMedium: sans(base.bodyMedium, color: soft, height: 1.5),
      bodySmall: sans(base.bodySmall, color: soft, height: 1.45),
      labelLarge: sans(base.labelLarge, weight: FontWeight.w600),
      labelMedium: sans(base.labelMedium, color: soft),
    );
  }

  static ThemeData get light {
    final scheme = const ColorScheme.light(
      primary: AppColors.clay,
      onPrimary: Colors.white,
      secondary: AppColors.clayBright,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.surfaceAlt,
      outline: AppColors.border,
    );
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      canvasColor: AppColors.paper,
      dividerColor: AppColors.border,
      textTheme: _textTheme(base.textTheme, AppColors.ink, AppColors.inkSoft),
      cardTheme: _cardTheme(AppColors.surface, AppColors.border),
      appBarTheme: _appBar(AppColors.paper, AppColors.ink),
      iconTheme: const IconThemeData(color: AppColors.inkSoft),
      sliderTheme: _slider(AppColors.clay, AppColors.border),
      chipTheme: _chip(AppColors.surfaceAlt, AppColors.ink, AppColors.border),
    );
  }

  static ThemeData get dark {
    final scheme = const ColorScheme.dark(
      primary: AppColors.clayBright,
      onPrimary: Color(0xFF1F1E1D),
      secondary: AppColors.clay,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.inkDark,
      surfaceContainerHighest: AppColors.surfaceAltDark,
      outline: AppColors.borderDark,
    );
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paperDark,
      canvasColor: AppColors.paperDark,
      dividerColor: AppColors.borderDark,
      textTheme: _textTheme(base.textTheme, AppColors.inkDark, AppColors.inkSoftDark),
      cardTheme: _cardTheme(AppColors.surfaceDark, AppColors.borderDark),
      appBarTheme: _appBar(AppColors.paperDark, AppColors.inkDark),
      iconTheme: const IconThemeData(color: AppColors.inkSoftDark),
      sliderTheme: _slider(AppColors.clayBright, AppColors.borderDark),
      chipTheme: _chip(AppColors.surfaceAltDark, AppColors.inkDark, AppColors.borderDark),
    );
  }

  static CardThemeData _cardTheme(Color color, Color border) => CardThemeData(
        color: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      );

  static AppBarTheme _appBar(Color bg, Color fg) => AppBarTheme(
        // Translucent so the liquid-glass backdrop shows through behind it.
        backgroundColor: bg.withValues(alpha: 0.55),
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      );

  static SliderThemeData _slider(Color active, Color inactive) => SliderThemeData(
        activeTrackColor: active,
        inactiveTrackColor: inactive,
        thumbColor: active,
        overlayColor: active.withValues(alpha: 0.12),
        trackHeight: 3,
      );

  static ChipThemeData _chip(Color bg, Color fg, Color border) => ChipThemeData(
        backgroundColor: bg,
        labelStyle: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
}
