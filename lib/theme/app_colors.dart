import 'package:flutter/material.dart';

/// Claude-inspired palette: warm ivory paper, terracotta accent, slate ink.
class AppColors {
  AppColors._();

  // Brand
  static const Color clay = Color(0xFFCC785C); // "book cloth" terracotta
  static const Color clayBright = Color(0xFFD97757); // clay / claude orange
  static const Color clayDeep = Color(0xFFA85B43);

  // Light theme
  static const Color paper = Color(0xFFFAF9F5); // background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0EEE6);
  static const Color ink = Color(0xFF1F1E1D);
  static const Color inkSoft = Color(0xFF52514C);
  static const Color inkFaint = Color(0xFF8A887F);
  static const Color border = Color(0xFFE6E2D8);

  // Dark theme
  static const Color paperDark = Color(0xFF1F1E1D);
  static const Color surfaceDark = Color(0xFF2A2927);
  static const Color surfaceAltDark = Color(0xFF35332F);
  static const Color inkDark = Color(0xFFF3F1EA);
  static const Color inkSoftDark = Color(0xFFC4C1B6);
  static const Color inkFaintDark = Color(0xFF8E8B81);
  static const Color borderDark = Color(0xFF403D38);

  // Semantic visualizer colors (work on both themes)
  static const Color compare = Color(0xFFE0A458); // amber — being compared
  static const Color active = Color(0xFFD97757); // terracotta — active / swap
  static const Color done = Color(0xFF7C9A6E); // sage — finalized / sorted
  static const Color highlight = Color(0xFF6E8CA8); // slate blue — pivot / target
  static const Color idle = Color(0xFFBFC4CC); // neutral bars (light)
  static const Color idleDark = Color(0xFF5A6470);

  // Category accents for the catalog
  static const Color catSorting = Color(0xFFCC785C);
  static const Color catSearching = Color(0xFF6E8CA8);
  static const Color catTrees = Color(0xFF7C9A6E);
  static const Color catPathfinding = Color(0xFF9A6E8C);
  static const Color catBacktracking = Color(0xFFC2944B);
  static const Color catDynamic = Color(0xFF4F7CAC);
  static const Color catMaths = Color(0xFFB5683A);
  static const Color catGraphs = Color(0xFF5E8C7D);
  static const Color catStrings = Color(0xFF8A6E9A);
  static const Color catDataStructures = Color(0xFF7A8C5E);
  static const Color catOptimization = Color(0xFFC2705B);
  static const Color catGeometry = Color(0xFF5E7C8C);
  static const Color catArrays = Color(0xFFB08968);
  static const Color catLists = Color(0xFF6E9A8C);
  static const Color catMatrices = Color(0xFF8C7AAE);
  static const Color catStacksQueues = Color(0xFFAE7A8C);
  static const Color catDataTypes = Color(0xFF5E8CA8);
  static const Color catAi = Color(0xFFB55E5E);

  // Distinct fills for graph colouring.
  static const List<Color> palette = [
    Color(0xFFD97757), // terracotta
    Color(0xFF6E8CA8), // slate blue
    Color(0xFF7C9A6E), // sage
    Color(0xFFE0A458), // amber
    Color(0xFF9A6E8C), // mauve
  ];
}
