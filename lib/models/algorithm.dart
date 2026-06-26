import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'viz_run.dart';

enum AlgoCategory {
  sorting('Sorting', AppColors.catSorting, Icons.bar_chart_rounded),
  searching('Searching', AppColors.catSearching, Icons.search_rounded),
  trees('Trees', AppColors.catTrees, Icons.account_tree_rounded),
  pathfinding('Pathfinding', AppColors.catPathfinding, Icons.route_rounded),
  backtracking('Backtracking', AppColors.catBacktracking, Icons.replay_rounded),
  dynamicProgramming('Dynamic Programming', AppColors.catDynamic, Icons.grid_on_rounded),
  graphs('Graphs', AppColors.catGraphs, Icons.hub_outlined),
  strings('Strings', AppColors.catStrings, Icons.abc_rounded),
  dataStructures('Data Structures', AppColors.catDataStructures, Icons.dataset_outlined),
  optimization('Optimization', AppColors.catOptimization, Icons.biotech_outlined),
  geometry('Geometry', AppColors.catGeometry, Icons.change_history_rounded),
  mathematics('Mathematics', AppColors.catMaths, Icons.functions_rounded),
  arrays('Arrays', AppColors.catArrays, Icons.view_array_rounded),
  lists('Lists', AppColors.catLists, Icons.format_list_bulleted_rounded),
  matrices('Matrices', AppColors.catMatrices, Icons.grid_4x4_rounded),
  stacksQueues('Stacks & Queues', AppColors.catStacksQueues, Icons.layers_rounded),
  dataTypes('Data Types', AppColors.catDataTypes, Icons.text_fields_rounded),
  ai('AI', AppColors.catAi, Icons.psychology_rounded);

  const AlgoCategory(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Static description of an algorithm plus a factory that builds a fresh,
/// randomized [VizRun] each time the user opens or re-rolls it.
class AlgorithmInfo {
  const AlgorithmInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.blurb,
    required this.description,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.originalSources,
    required this.create,
  });

  final String id;
  final String name;
  final AlgoCategory category;
  final String blurb; // one-liner for the catalog card
  final String description; // a paragraph for the detail screen
  final String timeComplexity;
  final String spaceComplexity;
  final List<String> originalSources; // languages from the original repo
  final VizRun Function() create;
}
