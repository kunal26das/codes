import 'dart:math';

import '../algorithms/ai.dart';
import '../algorithms/arrays.dart';
import '../algorithms/backtracking.dart';
import '../algorithms/datastructures.dart';
import '../algorithms/datatypes.dart';
import '../algorithms/dynamic.dart';
import '../algorithms/geometry.dart';
import '../algorithms/graphs.dart';
import '../algorithms/heaps_trees.dart';
import '../algorithms/lists.dart';
import '../algorithms/mathematics.dart';
import '../algorithms/optimization.dart';
import '../algorithms/pathfinding.dart';
import '../algorithms/searching.dart';
import '../algorithms/sorting.dart';
import '../algorithms/strings.dart';
import '../algorithms/tree.dart';
import '../models/algorithm.dart';
import '../models/frames.dart';
import '../models/viz_run.dart';
import '../visualizers/board_view.dart';
import '../visualizers/bars_view.dart';
import '../visualizers/chain_hash_view.dart';
import '../visualizers/gtree_view.dart';
import '../visualizers/graph_view.dart';
import '../visualizers/genetic_view.dart';
import '../visualizers/grid_view.dart';
import '../visualizers/hanoi_view.dart';
import '../visualizers/hash_view.dart';
import '../visualizers/hull_view.dart';
import '../visualizers/knight_view.dart';
import '../visualizers/linked_view.dart';
import '../visualizers/matrix_view.dart';
import '../visualizers/number_grid_view.dart';
import '../visualizers/pascal_view.dart';
import '../visualizers/sequence_view.dart';
import '../visualizers/string_view.dart';
import '../visualizers/swarm_view.dart';
import '../visualizers/text_view.dart';
import '../visualizers/table_view.dart';
import '../visualizers/tree_view.dart';
import '../visualizers/trie_view.dart';
import '../visualizers/tsp_view.dart';

List<int> _randomArray({int n = 16, int min = 8, int max = 99}) {
  final rng = Random();
  return [for (var i = 0; i < n; i++) min + rng.nextInt(max - min + 1)];
}

VizRun _arrayRun(List<ArrayFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => BarsView(frame: frames[i]),
    );

VizRun _gridRunOf(GridRun run) => VizRun(
      frameCount: run.frames.length,
      captionAt: (i) => run.frames[i].caption,
      builder: (context, i) => GridView2D(run: run, frame: run.frames[i]),
    );

VizRun _knightRun(List<KnightFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => KnightView(frame: frames[i]),
    );

VizRun _tableRun(List<TableFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => TableView(frame: frames[i]),
    );

VizRun _numberGridRun(List<NumberGridFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => NumberGridView(frame: frames[i]),
    );

VizRun _pascalRun(List<PascalFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => PascalView(frame: frames[i]),
    );

VizRun _treeRun(List<TreeFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => TreeView(frame: frames[i]),
    );

VizRun _graphRun(GraphRun run) => VizRun(
      frameCount: run.frames.length,
      captionAt: (i) => run.frames[i].caption,
      builder: (context, i) => GraphView(run: run, frame: run.frames[i]),
    );

VizRun _matrixRun(List<MatrixFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => MatrixView(frame: frames[i]),
    );

VizRun _stringRun(List<StringMatchFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => StringView(frame: frames[i]),
    );

VizRun _hashRun(List<HashFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => HashView(frame: frames[i]),
    );

VizRun _sequenceRun(List<SequenceFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => SequenceView(frame: frames[i]),
    );

VizRun _geneticRun(List<GeneticFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => GeneticView(frame: frames[i]),
    );

VizRun _hullRun(List<HullFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => HullView(frame: frames[i]),
    );

VizRun _tspRun(List<TspFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => TspView(frame: frames[i]),
    );

VizRun _swarmRun(List<SwarmFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => SwarmView(frame: frames[i]),
    );

VizRun _linkedRun(List<LinkedFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => LinkedView(frame: frames[i]),
    );

VizRun _trieRun(List<TrieFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => TrieView(frame: frames[i]),
    );

VizRun _textRun(List<TextFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => TextView(frame: frames[i]),
    );

VizRun _gtreeRun(List<GTreeFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => GTreeView(frame: frames[i]),
    );

VizRun _chainHashRun(List<ChainHashFrame> frames) => VizRun(
      frameCount: frames.length,
      captionAt: (i) => frames[i].caption,
      builder: (context, i) => ChainHashView(frame: frames[i]),
    );

List<int> _distinctValues({int count = 9, int min = 10, int max = 99}) {
  final rng = Random();
  final values = <int>{};
  while (values.length < count) {
    values.add(min + rng.nextInt(max - min + 1));
  }
  return values.toList();
}

/// The curated set of algorithms shown in the app.
final List<AlgorithmInfo> catalog = [
  AlgorithmInfo(
    id: 'bubble-sort',
    name: 'Bubble Sort',
    category: AlgoCategory.sorting,
    blurb: 'Repeatedly swap adjacent out-of-order pairs.',
    description:
        'Bubble sort walks the array repeatedly, swapping any two neighbours '
        'that are out of order. After each pass the largest remaining value '
        '"bubbles" to its final position at the end.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _arrayRun(bubbleSort(_randomArray())),
  ),
  AlgorithmInfo(
    id: 'insertion-sort',
    name: 'Insertion Sort',
    category: AlgoCategory.sorting,
    blurb: 'Grow a sorted run one element at a time.',
    description:
        'Insertion sort keeps a sorted run on the left and repeatedly takes the '
        'next element, shifting larger values right until it slots into place. '
        'It is efficient on small or nearly-sorted inputs.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _arrayRun(insertionSort(_randomArray())),
  ),
  AlgorithmInfo(
    id: 'selection-sort',
    name: 'Selection Sort',
    category: AlgoCategory.sorting,
    blurb: 'Select the smallest remaining value each pass.',
    description:
        'Selection sort scans the unsorted region for the minimum value and '
        'swaps it into the next position. It always does the same number of '
        'comparisons regardless of the input.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _arrayRun(selectionSort(_randomArray())),
  ),
  AlgorithmInfo(
    id: 'merge-sort',
    name: 'Merge Sort',
    category: AlgoCategory.sorting,
    blurb: 'Divide in half, sort, then merge.',
    description:
        'Merge sort splits the array in half recursively, then merges the '
        'sorted halves back together. The merge step is the heart of the '
        'algorithm and gives it a stable O(n log n) running time.',
    timeComplexity: 'O(n log n)',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _arrayRun(mergeSort(_randomArray(n: 14))),
  ),
  AlgorithmInfo(
    id: 'quick-sort',
    name: 'Quick Sort',
    category: AlgoCategory.sorting,
    blurb: 'Partition around a pivot, then recurse.',
    description:
        'Quick sort picks a pivot and partitions the array so smaller values '
        'sit to its left and larger to its right. It then sorts each partition '
        'recursively. This demo uses the Lomuto partition scheme.',
    timeComplexity: 'O(n log n) avg',
    spaceComplexity: 'O(log n)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _arrayRun(quickSort(_randomArray(n: 14))),
  ),
  AlgorithmInfo(
    id: 'linear-search',
    name: 'Linear Search',
    category: AlgoCategory.searching,
    blurb: 'Check each element in turn.',
    description:
        'Linear search examines elements one by one until it finds the target '
        'or reaches the end. It needs no ordering and works on any list.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++'],
    create: () {
      final a = _randomArray(n: 14);
      final target = a[Random().nextInt(a.length)];
      return _arrayRun(linearSearch(a, target));
    },
  ),
  AlgorithmInfo(
    id: 'binary-search',
    name: 'Binary Search',
    category: AlgoCategory.searching,
    blurb: 'Halve a sorted range each step.',
    description:
        'Binary search repeatedly compares the target with the middle of a '
        'sorted range, discarding the half that cannot contain it. Each step '
        'halves the search space.',
    timeComplexity: 'O(log n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++'],
    create: () {
      final a = _randomArray(n: 15)..sort();
      final target = a[Random().nextInt(a.length)];
      return _arrayRun(binarySearch(a, target));
    },
  ),
  AlgorithmInfo(
    id: 'bst',
    name: 'Binary Search Tree',
    category: AlgoCategory.trees,
    blurb: 'Insert values, then traverse in order.',
    description:
        'A binary search tree stores each value so that everything in a node\'s '
        'left subtree is smaller and everything on the right is larger. Walking '
        'the tree in order then yields the values sorted.',
    timeComplexity: 'O(h) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () {
      final rng = Random();
      final values = <int>{};
      while (values.length < 9) {
        values.add(10 + rng.nextInt(90));
      }
      final frames = bstDemo(values.toList());
      return VizRun(
        frameCount: frames.length,
        captionAt: (i) => frames[i].caption,
        builder: (context, i) => TreeView(frame: frames[i]),
      );
    },
  ),
  AlgorithmInfo(
    id: 'astar',
    name: 'A* Pathfinding',
    category: AlgoCategory.pathfinding,
    blurb: 'Shortest path with a heuristic guide.',
    description:
        'A* explores a grid by always expanding the frontier cell with the '
        'lowest estimated total cost f = g + h, where g is the distance so far '
        'and h is the Manhattan distance to the goal. It finds a shortest path '
        'while exploring far fewer cells than a blind search.',
    timeComplexity: 'O(E log V)',
    spaceComplexity: 'O(V)',
    originalSources: ['AI'],
    create: () {
      final run = astarDemo();
      return VizRun(
        frameCount: run.frames.length,
        captionAt: (i) => run.frames[i].caption,
        builder: (context, i) => GridView2D(run: run, frame: run.frames[i]),
      );
    },
  ),
  AlgorithmInfo(
    id: 'n-queens',
    name: 'N-Queens',
    category: AlgoCategory.backtracking,
    blurb: 'Place N queens with no attacks.',
    description:
        'The N-Queens puzzle asks you to place N queens on an N×N board so that '
        'no two share a row, column, or diagonal. Backtracking places a queen '
        'row by row, retreating whenever a row offers no safe square.',
    timeComplexity: 'O(n!)',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++'],
    create: () {
      final frames = nQueens(8);
      return VizRun(
        frameCount: frames.length,
        captionAt: (i) => frames[i].caption,
        builder: (context, i) => BoardView(frame: frames[i]),
      );
    },
  ),
  AlgorithmInfo(
    id: 'tower-of-hanoi',
    name: 'Tower of Hanoi',
    category: AlgoCategory.backtracking,
    blurb: 'Move a stack using a spare peg.',
    description:
        'Move a stack of disks from the first peg to the third, never placing a '
        'larger disk on a smaller one. The elegant recursive solution moves the '
        'top n−1 disks aside, moves the largest, then moves the rest back.',
    timeComplexity: 'O(2ⁿ)',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++'],
    create: () {
      const disks = 4;
      final frames = hanoi(disks);
      return VizRun(
        frameCount: frames.length,
        captionAt: (i) => frames[i].caption,
        builder: (context, i) => HanoiView(frame: frames[i], diskCount: disks),
      );
    },
  ),
  AlgorithmInfo(
    id: 'heap-sort',
    name: 'Heap Sort',
    category: AlgoCategory.sorting,
    blurb: 'Build a max-heap, then extract the root repeatedly.',
    description:
        'Heap sort first rearranges the array into a binary max-heap so the '
        'largest value sits at the root. It then swaps the root to the end, '
        'shrinks the heap, and sifts the new root down — repeating until the '
        'array is sorted.',
    timeComplexity: 'O(n log n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++'],
    create: () => _arrayRun(heapSort(_randomArray(n: 14))),
  ),
  AlgorithmInfo(
    id: 'interpolation-search',
    name: 'Interpolation Search',
    category: AlgoCategory.searching,
    blurb: 'Guess the position from the value distribution.',
    description:
        'On a sorted, roughly uniform array, interpolation search estimates '
        'where the target should be — like looking up a name near the back of a '
        'phone book — instead of always probing the middle. It can reach '
        'O(log log n) on uniform data.',
    timeComplexity: 'O(log log n) avg',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final a = _randomArray(n: 15)..sort();
      final target = a[Random().nextInt(a.length)];
      return _arrayRun(interpolationSearch(a, target));
    },
  ),
  AlgorithmInfo(
    id: 'quick-select',
    name: 'Quickselect',
    category: AlgoCategory.searching,
    blurb: 'Find the k-th smallest without fully sorting.',
    description:
        'Quickselect partitions the array around a pivot like quicksort, but '
        'only recurses into the side that contains the rank it is looking for. '
        'This finds the k-th smallest value in linear time on average.',
    timeComplexity: 'O(n) avg',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final a = _randomArray(n: 14);
      final k = 1 + Random().nextInt(a.length);
      return _arrayRun(quickSelect(a, k));
    },
  ),
  AlgorithmInfo(
    id: 'bfs',
    name: 'Breadth-First Search',
    category: AlgoCategory.pathfinding,
    blurb: 'Explore in expanding rings with a queue.',
    description:
        'Breadth-first search visits cells in order of distance from the start '
        'using a FIFO queue, fanning out level by level. On an unweighted grid '
        'the first time it reaches the goal is along a shortest path.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _gridRunOf(bfsDemo()),
  ),
  AlgorithmInfo(
    id: 'dfs',
    name: 'Depth-First Search',
    category: AlgoCategory.pathfinding,
    blurb: 'Dive deep with a stack, then backtrack.',
    description:
        'Depth-first search follows one path as far as it can using a stack, '
        'backtracking when it hits a dead end. It is cheap on memory and great '
        'for reachability, but the path it finds need not be the shortest.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _gridRunOf(dfsDemo()),
  ),
  AlgorithmInfo(
    id: 'dijkstra',
    name: "Dijkstra's Algorithm",
    category: AlgoCategory.pathfinding,
    blurb: 'Always settle the nearest unvisited cell.',
    description:
        'Dijkstra grows a set of settled cells, each time choosing the '
        'unvisited cell with the smallest distance from the start and relaxing '
        'its neighbours. With uniform step costs it explores like BFS, but it '
        'generalises cleanly to weighted graphs.',
    timeComplexity: 'O(E log V)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _gridRunOf(dijkstraDemo()),
  ),
  AlgorithmInfo(
    id: 'rat-in-a-maze',
    name: 'Rat in a Maze',
    category: AlgoCategory.backtracking,
    blurb: 'Grow one path, retreat from dead ends.',
    description:
        'Starting at the entrance, the rat steps into any open neighbouring '
        'cell, marking its trail. When it reaches a dead end it backtracks and '
        'tries another direction, until it finds the exit.',
    timeComplexity: 'O(4^(n²))',
    spaceComplexity: 'O(n²)',
    originalSources: ['C++'],
    create: () => _gridRunOf(ratInMaze()),
  ),
  AlgorithmInfo(
    id: 'knights-tour',
    name: "Knight's Tour",
    category: AlgoCategory.backtracking,
    blurb: 'Visit every square with a knight exactly once.',
    description:
        'The knight must visit every square of the board exactly once. This '
        "demo uses Warnsdorff's rule — always move to the square with the "
        'fewest onward moves — which finds an open tour quickly with little '
        'backtracking.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(n²)',
    originalSources: ['C++'],
    create: () => _knightRun(knightsTour(n: 8)),
  ),
  AlgorithmInfo(
    id: 'knapsack',
    name: '0/1 Knapsack',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Maximize value within a weight budget.',
    description:
        'Given items with weights and values, choose a subset of greatest '
        'total value that fits in the capacity. The DP table dp[i][w] holds the '
        'best value using the first i items within weight w, each cell built '
        'from the row above it.',
    timeComplexity: 'O(nW)',
    spaceComplexity: 'O(nW)',
    originalSources: ['C++'],
    create: () => _tableRun(knapsack()),
  ),
  AlgorithmInfo(
    id: 'sieve-of-eratosthenes',
    name: 'Sieve of Eratosthenes',
    category: AlgoCategory.mathematics,
    blurb: 'Strike out multiples to find the primes.',
    description:
        'Starting from 2, the sieve takes each unmarked number as a prime and '
        'strikes out all of its multiples. Whatever remains unmarked when it '
        'finishes is exactly the set of primes up to the limit.',
    timeComplexity: 'O(n log log n)',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _numberGridRun(sieve(maxN: 60)),
  ),
  AlgorithmInfo(
    id: 'pascals-triangle',
    name: "Pascal's Triangle",
    category: AlgoCategory.mathematics,
    blurb: 'Each entry is the sum of the two above.',
    description:
        'Pascal’s triangle starts and ends every row with 1; each interior '
        'entry is the sum of the two entries diagonally above it. The rows are '
        'the binomial coefficients and sum to successive powers of two.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(n²)',
    originalSources: ['C'],
    create: () => _pascalRun(pascalsTriangle(numRows: 9)),
  ),
  AlgorithmInfo(
    id: 'collatz',
    name: 'Collatz Conjecture',
    category: AlgoCategory.mathematics,
    blurb: 'Halve evens, 3n+1 odds — always reach 1?',
    description:
        'Pick any positive integer. If it is even, halve it; if it is odd, '
        'triple it and add one. The Collatz conjecture says this process always '
        'eventually reaches 1 — unproven, but verified for enormous ranges.',
    timeComplexity: 'unknown',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(collatz(7 + Random().nextInt(20))),
  ),
  AlgorithmInfo(
    id: 'fibonacci',
    name: 'Fibonacci Series',
    category: AlgoCategory.mathematics,
    blurb: 'Each number is the sum of the previous two.',
    description:
        'The Fibonacci sequence begins 0, 1 and continues by adding the two '
        'preceding numbers. Computing it bottom-up reuses each result once, '
        'turning the naive exponential recursion into a linear pass.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++', 'Python'],
    create: () => _arrayRun(fibonacci(count: 13)),
  ),
  AlgorithmInfo(
    id: 'tree-preorder',
    name: 'Pre-order Traversal',
    category: AlgoCategory.trees,
    blurb: 'Visit the node before its subtrees.',
    description:
        'A pre-order traversal visits each node first, then recurses into its '
        'left subtree and finally its right. It is how you would copy a tree or '
        'print a prefix expression.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h)',
    originalSources: ['C', 'C++', 'Java'],
    create: () => _treeRun(treeTraversal(_distinctValues(), 'pre')),
  ),
  AlgorithmInfo(
    id: 'tree-postorder',
    name: 'Post-order Traversal',
    category: AlgoCategory.trees,
    blurb: 'Visit the node after its subtrees.',
    description:
        'A post-order traversal recurses into both subtrees before visiting the '
        'node itself. It is the order you would use to safely delete a tree or '
        'evaluate a postfix expression.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h)',
    originalSources: ['C', 'C++', 'Java'],
    create: () => _treeRun(treeTraversal(_distinctValues(), 'post')),
  ),
  AlgorithmInfo(
    id: 'tree-levelorder',
    name: 'Level-order Traversal',
    category: AlgoCategory.trees,
    blurb: 'Visit nodes breadth-first, level by level.',
    description:
        'A level-order (breadth-first) traversal uses a queue to visit the root, '
        'then every node one level down, and so on — reading the tree top to '
        'bottom, left to right.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++', 'Java'],
    create: () => _treeRun(treeTraversal(_distinctValues(), 'level')),
  ),
  AlgorithmInfo(
    id: 'kadane',
    name: "Kadane's Max Subarray",
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Largest contiguous sum in one pass.',
    description:
        'Kadane’s algorithm scans the array once, keeping a running sum that it '
        'restarts whenever the sum drops below the current element. The best '
        'running sum ever seen is the maximum subarray sum.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    originalSources: ['Python'],
    create: () {
      final rng = Random();
      final a = [for (var i = 0; i < 13; i++) -8 + rng.nextInt(20)];
      return _arrayRun(kadane(a));
    },
  ),
  AlgorithmInfo(
    id: 'floyd-warshall',
    name: 'Floyd–Warshall',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'All-pairs shortest paths via a DP matrix.',
    description:
        'Floyd–Warshall finds the shortest distance between every pair of '
        'vertices by repeatedly asking whether routing through an intermediate '
        'vertex k shortens the path from i to j, updating a distance matrix.',
    timeComplexity: 'O(V³)',
    spaceComplexity: 'O(V²)',
    originalSources: ['C++'],
    create: () => _tableRun(floydWarshall()),
  ),
  AlgorithmInfo(
    id: 'fractional-knapsack',
    name: 'Fractional Knapsack',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Greedy fill by value-to-weight ratio.',
    description:
        'When items can be split, the optimal knapsack is greedy: sort by '
        'value-to-weight ratio and take as much of each item as fits, slicing '
        'the final item to fill the remaining capacity exactly.',
    timeComplexity: 'O(n log n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(fractionalKnapsack()),
  ),
  AlgorithmInfo(
    id: 'factorial',
    name: 'Factorial',
    category: AlgoCategory.mathematics,
    blurb: 'The running product 1·2·3·…·n.',
    description:
        'The factorial n! is the product of all positive integers up to n. '
        'Building it iteratively multiplies the running total by each next '
        'integer — the bars show how fast it grows.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    originalSources: ['Python'],
    create: () => _arrayRun(factorial(8)),
  ),
  AlgorithmInfo(
    id: 'prim-mst',
    name: "Prim's MST",
    category: AlgoCategory.graphs,
    blurb: 'Grow a minimum spanning tree greedily.',
    description:
        'Prim’s algorithm builds a minimum spanning tree by starting at one '
        'vertex and repeatedly adding the cheapest edge that links the growing '
        'tree to a vertex not yet in it, until every vertex is connected.',
    timeComplexity: 'O(E log V)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _graphRun(primDemo()),
  ),
  AlgorithmInfo(
    id: 'kruskal-mst',
    name: "Kruskal's MST",
    category: AlgoCategory.graphs,
    blurb: 'Add cheapest edges, skipping cycles.',
    description:
        'Kruskal’s algorithm considers every edge in increasing weight order, '
        'adding an edge whenever it connects two so-far separate components. A '
        'union–find structure detects (and rejects) edges that would close a '
        'cycle.',
    timeComplexity: 'O(E log E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _graphRun(kruskalDemo()),
  ),
  AlgorithmInfo(
    id: 'topological-sort',
    name: 'Topological Sort',
    category: AlgoCategory.graphs,
    blurb: 'Order a DAG so edges point forward.',
    description:
        'A topological sort lists the vertices of a directed acyclic graph so '
        'that every edge goes from earlier to later. Kahn’s algorithm achieves '
        'this by repeatedly removing a vertex with no remaining incoming edges.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _graphRun(topologicalSort()),
  ),
  AlgorithmInfo(
    id: 'matrix-multiply',
    name: 'Matrix Multiplication',
    category: AlgoCategory.matrices,
    blurb: 'Each cell is a row · column dot product.',
    description:
        'The product C = A × B has one entry per (row of A, column of B): the '
        'sum of their pairwise products. The inner dimensions must match; the '
        'result takes the outer dimensions.',
    timeComplexity: 'O(n³)',
    spaceComplexity: 'O(n²)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _matrixRun(matrixMultiply()),
  ),
  AlgorithmInfo(
    id: 'matrix-add',
    name: 'Matrix Addition',
    category: AlgoCategory.matrices,
    blurb: 'Add two equal-sized matrices element-wise.',
    description:
        'Matrix addition combines two matrices of the same shape by adding '
        'corresponding entries, producing a matrix of that same shape.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(n²)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _matrixRun(matrixAdd()),
  ),
  AlgorithmInfo(
    id: 'base-conversion',
    name: 'Base Conversion',
    category: AlgoCategory.mathematics,
    blurb: 'Decimal → binary by repeated division.',
    description:
        'To rewrite a number in another base, repeatedly divide by the base and '
        'record the remainder. Reading the remainders from last to first gives '
        'the digits in the new base.',
    timeComplexity: 'O(log n)',
    spaceComplexity: 'O(log n)',
    originalSources: ['C'],
    create: () => _tableRun(baseConversion(20 + Random().nextInt(80), base: 2)),
  ),
  AlgorithmInfo(
    id: 'shell-sort',
    name: 'Shell Sort',
    category: AlgoCategory.sorting,
    blurb: 'Gap-based insertion sort that shrinks the gap.',
    description:
        'Shell sort generalises insertion sort by comparing elements a large '
        'gap apart, then repeatedly shrinking the gap. Early long-distance '
        'moves let later passes finish quickly.',
    timeComplexity: 'O(n^1.5)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(shellSort(_randomArray(n: 16))),
  ),
  AlgorithmInfo(
    id: 'cocktail-sort',
    name: 'Cocktail Shaker Sort',
    category: AlgoCategory.sorting,
    blurb: 'Bubble sort that sweeps both directions.',
    description:
        'Cocktail shaker sort is a bidirectional bubble sort: it bubbles the '
        'largest value to the end, then the smallest to the front, narrowing '
        'the unsorted region from both sides each pass.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(cocktailSort(_randomArray(n: 14))),
  ),
  AlgorithmInfo(
    id: 'comb-sort',
    name: 'Comb Sort',
    category: AlgoCategory.sorting,
    blurb: 'Bubble sort with a shrinking comparison gap.',
    description:
        'Comb sort improves bubble sort by comparing elements a gap apart and '
        'dividing the gap by ~1.3 each pass, eliminating the small "turtle" '
        'values that slow bubble sort down.',
    timeComplexity: 'O(n²/2^p)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(combSort(_randomArray(n: 16))),
  ),
  AlgorithmInfo(
    id: 'gnome-sort',
    name: 'Gnome Sort',
    category: AlgoCategory.sorting,
    blurb: 'Swap backwards until each element fits.',
    description:
        'Gnome sort steps forward while order holds and swaps backward when it '
        'finds an inversion, like a garden gnome sorting flower pots — simple, '
        'with no nested loops.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(gnomeSort(_randomArray(n: 12))),
  ),
  AlgorithmInfo(
    id: 'radix-sort',
    name: 'Radix Sort',
    category: AlgoCategory.sorting,
    blurb: 'Stable-sort by each digit, least significant first.',
    description:
        'Radix sort sorts integers without comparisons: it stably distributes '
        'them by their least-significant digit, then the next, and so on. After '
        'the most-significant digit pass the array is fully sorted.',
    timeComplexity: 'O(d·n)',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _arrayRun(radixSort(_randomArray(n: 14, min: 10, max: 999))),
  ),
  AlgorithmInfo(
    id: 'jump-search',
    name: 'Jump Search',
    category: AlgoCategory.searching,
    blurb: 'Leap in √n blocks, then scan one block.',
    description:
        'Jump search skips ahead in fixed blocks of about √n until it passes '
        'the target, then scans the previous block linearly — a middle ground '
        'between linear and binary search on sorted data.',
    timeComplexity: 'O(√n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final a = _randomArray(n: 16)..sort();
      return _arrayRun(jumpSearch(a, a[Random().nextInt(a.length)]));
    },
  ),
  AlgorithmInfo(
    id: 'ternary-search',
    name: 'Ternary Search',
    category: AlgoCategory.searching,
    blurb: 'Split a sorted range into thirds.',
    description:
        'Ternary search divides the sorted range into three parts using two '
        'probes, discarding two-thirds of the range each step. It does more '
        'comparisons per step than binary search but fewer steps.',
    timeComplexity: 'O(log₃ n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final a = _randomArray(n: 16)..sort();
      return _arrayRun(ternarySearch(a, a[Random().nextInt(a.length)]));
    },
  ),
  AlgorithmInfo(
    id: 'exponential-search',
    name: 'Exponential Search',
    category: AlgoCategory.searching,
    blurb: 'Double a bound, then binary search.',
    description:
        'Exponential search doubles an index until it overshoots the target, '
        'then binary-searches the bracketed range. It is ideal for unbounded '
        'or very large sorted inputs where the target is near the front.',
    timeComplexity: 'O(log i)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final a = _randomArray(n: 16)..sort();
      return _arrayRun(exponentialSearch(a, a[Random().nextInt(a.length)]));
    },
  ),
  AlgorithmInfo(
    id: 'lcs',
    name: 'Longest Common Subsequence',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Longest order-preserving shared subsequence.',
    description:
        'The LCS of two strings is the longest sequence of characters that '
        'appears in both, in order but not necessarily contiguously. The DP '
        'table builds each cell from its top, left, and diagonal neighbours.',
    timeComplexity: 'O(mn)',
    spaceComplexity: 'O(mn)',
    originalSources: ['C++'],
    create: () => _tableRun(lcs()),
  ),
  AlgorithmInfo(
    id: 'edit-distance',
    name: 'Edit Distance',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Fewest edits to turn one string into another.',
    description:
        'The Levenshtein edit distance is the minimum number of single-'
        'character insertions, deletions, or substitutions that transform one '
        'string into another, computed bottom-up in a DP table.',
    timeComplexity: 'O(mn)',
    spaceComplexity: 'O(mn)',
    originalSources: ['C++'],
    create: () => _tableRun(editDistance()),
  ),
  AlgorithmInfo(
    id: 'coin-change',
    name: 'Coin Change',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Fewest coins to make an amount.',
    description:
        'Given coin denominations, the coin-change DP computes the minimum '
        'number of coins for every amount up to the target, each built from '
        'smaller amounts one coin away.',
    timeComplexity: 'O(amount·coins)',
    spaceComplexity: 'O(amount)',
    originalSources: ['C++'],
    create: () => _tableRun(coinChange()),
  ),
  AlgorithmInfo(
    id: 'graph-coloring',
    name: 'Graph Colouring',
    category: AlgoCategory.graphs,
    blurb: 'Colour vertices so no edge repeats a colour.',
    description:
        'Greedy graph colouring assigns each vertex, in turn, the smallest '
        'colour not already used by one of its neighbours — a fast heuristic '
        'for a generally hard problem.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _graphRun(graphColoring()),
  ),
  AlgorithmInfo(
    id: 'cycle-detection',
    name: 'Cycle Detection',
    category: AlgoCategory.graphs,
    blurb: 'Find a cycle in a directed graph via DFS.',
    description:
        'Depth-first search detects a cycle in a directed graph: if it ever '
        'follows an edge to a vertex still on the recursion stack (a "back '
        'edge"), the graph has a cycle.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _graphRun(cycleDetection()),
  ),
  AlgorithmInfo(
    id: 'naive-string-search',
    name: 'Naive String Search',
    category: AlgoCategory.strings,
    blurb: 'Try the pattern at every position.',
    description:
        'The naive matcher aligns the pattern at each text position and '
        'compares character by character, sliding right by one whenever a '
        'mismatch occurs.',
    timeComplexity: 'O(nm)',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++'],
    create: () => _stringRun(naiveSearch()),
  ),
  AlgorithmInfo(
    id: 'kmp',
    name: 'KMP String Matching',
    category: AlgoCategory.strings,
    blurb: 'Skip ahead using a prefix table.',
    description:
        'Knuth–Morris–Pratt precomputes how far the pattern can safely shift on '
        'a mismatch using its longest prefix-suffix table, so text characters '
        'are never re-examined — linear-time matching.',
    timeComplexity: 'O(n + m)',
    spaceComplexity: 'O(m)',
    originalSources: ['C++'],
    create: () => _stringRun(kmpSearch()),
  ),
  AlgorithmInfo(
    id: 'gcd',
    name: 'Euclidean GCD',
    category: AlgoCategory.mathematics,
    blurb: 'Repeated remainder until one is zero.',
    description:
        'Euclid’s algorithm finds the greatest common divisor by repeatedly '
        'replacing the pair (a, b) with (b, a mod b). When b reaches 0, a is '
        'the GCD.',
    timeComplexity: 'O(log min(a,b))',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++'],
    create: () {
      final rng = Random();
      return _arrayRun(gcd(24 + rng.nextInt(180), 12 + rng.nextInt(120)));
    },
  ),
  AlgorithmInfo(
    id: 'lcm',
    name: 'Least Common Multiple',
    category: AlgoCategory.mathematics,
    blurb: 'lcm(a, b) = a·b / gcd(a, b).',
    description:
        'The least common multiple is found from the GCD: lcm(a, b) = a·b / '
        'gcd(a, b), where the GCD comes from the Euclidean algorithm.',
    timeComplexity: 'O(log min(a,b))',
    spaceComplexity: 'O(1)',
    originalSources: ['C', 'C++'],
    create: () {
      final rng = Random();
      return _arrayRun(lcm(6 + rng.nextInt(18), 4 + rng.nextInt(20)));
    },
  ),
  AlgorithmInfo(
    id: 'prime-factorization',
    name: 'Prime Factorization',
    category: AlgoCategory.mathematics,
    blurb: 'Divide out primes until 1 remains.',
    description:
        'Trial division finds a number’s prime factors by repeatedly dividing '
        'out the smallest factor; any remainder above 1 at the end is itself '
        'prime.',
    timeComplexity: 'O(√n)',
    spaceComplexity: 'O(log n)',
    originalSources: ['C', 'C++'],
    create: () => _arrayRun(primeFactorization(180 + Random().nextInt(600))),
  ),
  AlgorithmInfo(
    id: 'counting-sort',
    name: 'Counting Sort',
    category: AlgoCategory.sorting,
    blurb: 'Tally each value, then emit in order.',
    description:
        'Counting sort avoids comparisons: it counts how many times each value '
        'occurs, then writes the values back out in order. It is linear when the '
        'value range is small.',
    timeComplexity: 'O(n + k)',
    spaceComplexity: 'O(n + k)',
    originalSources: ['C++'],
    create: () => _arrayRun(countingSort(_randomArray(n: 12, min: 0, max: 20))),
  ),
  AlgorithmInfo(
    id: 'bellman-ford',
    name: 'Bellman–Ford',
    category: AlgoCategory.graphs,
    blurb: 'Shortest paths, even with negative edges.',
    description:
        'Bellman–Ford finds shortest paths from a source by relaxing every edge '
        'V−1 times. Unlike Dijkstra it tolerates negative edge weights and can '
        'detect negative cycles.',
    timeComplexity: 'O(VE)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _graphRun(bellmanFord()),
  ),
  AlgorithmInfo(
    id: 'boyer-moore',
    name: 'Boyer–Moore',
    category: AlgoCategory.strings,
    blurb: 'Match right-to-left, skip with bad-character rule.',
    description:
        'Boyer–Moore compares the pattern to the text from right to left and, on '
        'a mismatch, uses the bad-character rule to jump the pattern ahead — '
        'often skipping large chunks of text.',
    timeComplexity: 'O(n/m) best',
    spaceComplexity: 'O(k)',
    originalSources: ['C++'],
    create: () => _stringRun(boyerMoore()),
  ),
  AlgorithmInfo(
    id: 'rabin-karp',
    name: 'Rabin–Karp',
    category: AlgoCategory.strings,
    blurb: 'Match by comparing rolling hashes.',
    description:
        'Rabin–Karp hashes the pattern and each text window, comparing hashes '
        'instead of characters and confirming only on a hash collision — handy '
        'for multi-pattern search.',
    timeComplexity: 'O(n + m) avg',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _stringRun(rabinKarp()),
  ),
  AlgorithmInfo(
    id: 'binary-heap',
    name: 'Binary Heap',
    category: AlgoCategory.trees,
    blurb: 'Insert and sift up to keep the heap property.',
    description:
        'A binary max-heap is a complete tree where every parent is at least as '
        'large as its children. Inserting a value places it at the end and '
        'sifts it up by swapping with larger-needed parents.',
    timeComplexity: 'O(log n) insert',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _treeRun(binaryHeapDemo(_distinctValues(count: 8, min: 5, max: 60))),
  ),
  AlgorithmInfo(
    id: 'hash-table',
    name: 'Hash Table',
    category: AlgoCategory.dataStructures,
    blurb: 'Open addressing with linear probing.',
    description:
        'A hash table maps each key to a slot with a hash function. With linear '
        'probing, collisions are resolved by stepping forward to the next free '
        'slot.',
    timeComplexity: 'O(1) avg',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _hashRun(hashLinearProbing()),
  ),
  AlgorithmInfo(
    id: 'stack',
    name: 'Stack',
    category: AlgoCategory.stacksQueues,
    blurb: 'Last-in, first-out push and pop.',
    description:
        'A stack adds and removes elements at the same end — the top. The last '
        'element pushed is the first one popped (LIFO).',
    timeComplexity: 'O(1) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++', 'Java', 'Python'],
    create: () => _sequenceRun(stackDemo()),
  ),
  AlgorithmInfo(
    id: 'queue',
    name: 'Queue',
    category: AlgoCategory.stacksQueues,
    blurb: 'First-in, first-out enqueue and dequeue.',
    description:
        'A queue adds elements at the back and removes them from the front, so '
        'the first element in is the first out (FIFO).',
    timeComplexity: 'O(1) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++'],
    create: () => _sequenceRun(queueDemo()),
  ),
  AlgorithmInfo(
    id: 'singly-linked-list',
    name: 'Singly Linked List',
    category: AlgoCategory.lists,
    blurb: 'Nodes chained by a single next pointer.',
    description:
        'A singly linked list stores each value in a node that points to the '
        'next. Inserting at the head or appending at the tail is cheap, and '
        'deleting a node just re-links its predecessor past it — no shifting '
        'like an array.',
    timeComplexity: 'O(1) insert / O(n) find',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++', 'Java'],
    create: () => _linkedRun(singlyLinkedList()),
  ),
  AlgorithmInfo(
    id: 'doubly-linked-list',
    name: 'Doubly Linked List',
    category: AlgoCategory.lists,
    blurb: 'Each node links both forward and back.',
    description:
        'A doubly linked list gives every node both a next and a prev pointer, '
        'so it can be walked in either direction and a known node deletes in '
        'O(1) by re-linking its two neighbours.',
    timeComplexity: 'O(1) insert/delete',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++', 'Java'],
    create: () => _linkedRun(doublyLinkedList()),
  ),
  AlgorithmInfo(
    id: 'circular-linked-list',
    name: 'Circular Linked List',
    category: AlgoCategory.lists,
    blurb: 'The tail points back to the head.',
    description:
        'In a circular linked list the last node points back to the first, so '
        'traversal loops endlessly. It underpins round-robin scheduling and '
        'ring buffers where there is no natural end.',
    timeComplexity: 'O(1) insert',
    spaceComplexity: 'O(n)',
    originalSources: ['C', 'C++'],
    create: () => _linkedRun(circularLinkedList()),
  ),
  AlgorithmInfo(
    id: 'deque',
    name: 'Deque',
    category: AlgoCategory.dataStructures,
    blurb: 'Push and pop at both ends.',
    description:
        'A double-ended queue (deque) supports adding and removing elements at '
        'both the front and the back in constant time — a superset of both the '
        'stack and the queue.',
    timeComplexity: 'O(1) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C++', 'Python'],
    create: () => _sequenceRun(dequeDemo()),
  ),
  AlgorithmInfo(
    id: 'priority-queue',
    name: 'Priority Queue',
    category: AlgoCategory.dataStructures,
    blurb: 'A min-heap that always serves the smallest.',
    description:
        'A priority queue returns elements by priority rather than insertion '
        'order. Backed by a binary min-heap, inserts sift a new key up and '
        'extract-min swaps the last key to the root and sifts it down — both '
        'O(log n).',
    timeComplexity: 'O(log n) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C++', 'Java'],
    create: () => _treeRun(priorityQueue()),
  ),
  AlgorithmInfo(
    id: 'trie',
    name: 'Trie (Prefix Tree)',
    category: AlgoCategory.dataStructures,
    blurb: 'Words share common prefixes along edges.',
    description:
        'A trie stores strings by their characters: words with a common prefix '
        'share the same path from the root, and a flag marks where a word ends. '
        'Lookups and prefix queries run in O(length), independent of how many '
        'words are stored.',
    timeComplexity: 'O(L) per op',
    spaceComplexity: 'O(Σ·N)',
    originalSources: ['C++'],
    create: () => _trieRun(trieDemo()),
  ),
  AlgorithmInfo(
    id: 'union-find',
    name: 'Disjoint Set (Union–Find)',
    category: AlgoCategory.dataStructures,
    blurb: 'Merge sets; query membership near O(1).',
    description:
        'A disjoint-set forest tracks elements partitioned into groups. find '
        'follows parent pointers to a representative root, and union links two '
        'roots — by rank, with path compression — giving almost-constant '
        'amortised time.',
    timeComplexity: 'O(α(n)) amortised',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _graphRun(unionFind()),
  ),
  AlgorithmInfo(
    id: 'avl-tree',
    name: 'AVL Tree',
    category: AlgoCategory.dataStructures,
    blurb: 'A self-balancing BST using rotations.',
    description:
        'An AVL tree is a binary search tree that keeps every subtree’s height '
        'balanced to within one. After each insertion it checks balance factors '
        'and applies single or double rotations, guaranteeing O(log n) height.',
    timeComplexity: 'O(log n) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _treeRun(avlTree()),
  ),
  AlgorithmInfo(
    id: 'segment-tree',
    name: 'Segment Tree',
    category: AlgoCategory.dataStructures,
    blurb: 'Range sums in O(log n) via a tree of ranges.',
    description:
        'A segment tree stores an array’s elements in its leaves and the sum of '
        'each range in the internal nodes. Built bottom-up, it answers any '
        'range-sum (or min/max) query and point update in O(log n).',
    timeComplexity: 'O(log n) query',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _treeRun(segmentTree()),
  ),
  AlgorithmInfo(
    id: 'lru-cache',
    name: 'LRU Cache',
    category: AlgoCategory.dataStructures,
    blurb: 'Evict the least-recently-used entry when full.',
    description:
        'A least-recently-used cache keeps entries ordered by recency: every '
        'access moves a key to the most-recent end, and inserting into a full '
        'cache evicts the least-recent one. A hash map plus a doubly linked '
        'list makes every operation O(1).',
    timeComplexity: 'O(1) per op',
    spaceComplexity: 'O(capacity)',
    originalSources: ['C++', 'Java'],
    create: () => _sequenceRun(lruCache()),
  ),
  AlgorithmInfo(
    id: 'genetic-algorithm',
    name: 'Genetic Algorithm',
    category: AlgoCategory.optimization,
    blurb: 'Evolve a population toward a target.',
    description:
        'A genetic algorithm mimics natural selection: it scores each candidate '
        'in a population by fitness, then breeds the next generation through '
        'selection, crossover, and mutation. Here it evolves random strings '
        'toward a target phrase, generation by generation.',
    timeComplexity: 'O(gen · pop · L)',
    spaceComplexity: 'O(pop · L)',
    originalSources: ['AI'],
    create: () => _geneticRun(geneticAlgorithm()),
  ),
  AlgorithmInfo(
    id: 'ant-colony',
    name: 'Ant Colony Optimization',
    category: AlgoCategory.optimization,
    blurb: 'Ants lay pheromone to find a short tour.',
    description:
        'Ant Colony Optimization mimics how ants find short routes: each '
        'iteration a swarm of ants builds tours, biased toward edges with more '
        'pheromone and shorter length. Pheromone then evaporates and is '
        'reinforced along the tours taken, so good edges accumulate scent and '
        'the colony collectively converges on a short travelling-salesman tour.',
    timeComplexity: 'O(iter · ants · n²)',
    spaceComplexity: 'O(n²)',
    originalSources: ['AI'],
    create: () => _tspRun(antColony()),
  ),
  AlgorithmInfo(
    id: 'particle-swarm',
    name: 'Particle Swarm Optimization',
    category: AlgoCategory.optimization,
    blurb: 'A flock drifts toward the best spot found.',
    description:
        'Particle Swarm Optimization scatters particles across a fitness '
        'landscape. Each remembers its own best spot and is pulled toward both '
        'it and the swarm’s global best, with inertia carrying its velocity '
        'forward. The flock spreads, then converges on the optimum.',
    timeComplexity: 'O(iter · particles)',
    spaceComplexity: 'O(particles)',
    originalSources: ['AI'],
    create: () => _swarmRun(particleSwarm()),
  ),
  AlgorithmInfo(
    id: 'simulated-annealing',
    name: 'Simulated Annealing',
    category: AlgoCategory.optimization,
    blurb: 'Accept worse moves while hot, then cool.',
    description:
        'Simulated annealing borrows from metallurgy: it proposes random 2-opt '
        'changes to a tour, always taking improvements but also accepting '
        'worse moves with probability exp(-Δ/T). The temperature T cools '
        'geometrically, so the search explores wildly when hot and settles '
        'into a good solution as it freezes.',
    timeComplexity: 'O(steps · n)',
    spaceComplexity: 'O(n)',
    originalSources: ['AI'],
    create: () => _tspRun(simulatedAnnealing()),
  ),
  AlgorithmInfo(
    id: 'hill-climbing',
    name: 'Hill Climbing',
    category: AlgoCategory.optimization,
    blurb: 'Always step to the highest neighbour.',
    description:
        'Hill climbing is the simplest local search: from the current point it '
        'always steps to the best uphill neighbour, stopping when none is '
        'higher. It races to the optimum on a smooth landscape but can get '
        'trapped in a local maximum on a bumpy one.',
    timeComplexity: 'O(steps)',
    spaceComplexity: 'O(1)',
    originalSources: ['AI'],
    create: () => _swarmRun(hillClimbing()),
  ),
  AlgorithmInfo(
    id: 'artificial-bee-colony',
    name: 'Artificial Bee Colony',
    category: AlgoCategory.optimization,
    blurb: 'Employed, onlooker, and scout bees refine food sources.',
    description:
        'Artificial Bee Colony models a hive: employed bees tweak their own '
        'food source, onlooker bees crowd toward the richer sources via a '
        'fitness-weighted roulette, and a scout bee abandons any source that '
        'stops improving for a fresh random one. Together they uncover the '
        'optimum.',
    timeComplexity: 'O(iter · sources)',
    spaceComplexity: 'O(sources)',
    originalSources: ['AI'],
    create: () => _swarmRun(artificialBeeColony()),
  ),
  AlgorithmInfo(
    id: 'firefly',
    name: 'Firefly Algorithm',
    category: AlgoCategory.optimization,
    blurb: 'Dimmer fireflies drift toward brighter ones.',
    description:
        'In the Firefly Algorithm each firefly glows in proportion to its '
        'fitness and is attracted to brighter neighbours, with attractiveness '
        'fading over distance (β = β₀·e^(−γr²)) plus a shrinking random jitter. '
        'Brighter fireflies pull the swarm together at the brightest point.',
    timeComplexity: 'O(iter · n²)',
    spaceComplexity: 'O(n)',
    originalSources: ['AI'],
    create: () => _swarmRun(firefly()),
  ),
  AlgorithmInfo(
    id: 'cuckoo-search',
    name: 'Cuckoo Search',
    category: AlgoCategory.optimization,
    blurb: 'Lay better eggs via Lévy flights; abandon poor nests.',
    description:
        'Cuckoo Search has each cuckoo lay an egg — a new solution — by taking '
        'a heavy-tailed Lévy flight from an existing nest. A better egg takes '
        'over a random nest, and each round the worst fraction of nests are '
        'abandoned and rebuilt at random, balancing exploration with elitism.',
    timeComplexity: 'O(iter · nests)',
    spaceComplexity: 'O(nests)',
    originalSources: ['AI'],
    create: () => _swarmRun(cuckooSearch()),
  ),
  AlgorithmInfo(
    id: 'bitonic-sort', name: 'Bitonic Sort', category: AlgoCategory.sorting,
    blurb: 'A sorting network of compare-swaps.',
    description: 'Bitonic sort recursively builds bitonic (up-then-down) sequences and merges them with a fixed pattern of compare-swaps. It is data-independent, so it parallelises well; the length must be a power of two.',
    timeComplexity: 'O(n log²n)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () => _arrayRun(bitonicSort(_randomArray(n: 8))),
  ),
  AlgorithmInfo(
    id: 'bst-sort', name: 'BST Sort', category: AlgoCategory.sorting,
    blurb: 'Insert into a BST, then read in-order.',
    description: 'BST sort inserts every element into a binary search tree, then performs an in-order traversal — which visits the values in sorted order.',
    timeComplexity: 'O(n log n) avg', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _arrayRun(bstSort(_randomArray(n: 12))),
  ),
  AlgorithmInfo(
    id: 'pancake-sort',
    name: 'Pancake Sort',
    category: AlgoCategory.sorting,
    blurb: 'Sort by flipping prefixes of the array.',
    description:
        'Pancake sort may only reverse a prefix of the array (a "flip"). Each '
        'round it flips the largest unsorted value to the front, then flips it '
        'down to its final position.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(pancakeSort(_randomArray(n: 12))),
  ),
  AlgorithmInfo(
    id: 'cycle-sort',
    name: 'Cycle Sort',
    category: AlgoCategory.sorting,
    blurb: 'Minimise writes by following cycles.',
    description:
        'Cycle sort writes each element exactly once to its correct position by '
        'following the permutation cycles, making it optimal in the number of '
        'memory writes.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(cycleSort(_randomArray(n: 12))),
  ),
  AlgorithmInfo(
    id: 'bucket-sort',
    name: 'Bucket Sort',
    category: AlgoCategory.sorting,
    blurb: 'Scatter into buckets, sort, then gather.',
    description:
        'Bucket sort distributes values into several range buckets, sorts each '
        'bucket, and concatenates them. It is fast when the input is spread '
        'evenly across the range.',
    timeComplexity: 'O(n + k)',
    spaceComplexity: 'O(n + k)',
    originalSources: ['C++'],
    create: () => _arrayRun(bucketSort(_randomArray(n: 14))),
  ),
  AlgorithmInfo(
    id: 'odd-even-sort',
    name: 'Odd-Even Sort',
    category: AlgoCategory.sorting,
    blurb: 'Brick sort: alternate odd/even compare-swaps.',
    description:
        'Odd-even (brick) sort repeatedly compare-swaps all odd-indexed pairs, '
        'then all even-indexed pairs, until no swaps occur. It parallelises '
        'naturally.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(oddEvenSort(_randomArray(n: 12))),
  ),
  AlgorithmInfo(
    id: 'pigeonhole-sort',
    name: 'Pigeonhole Sort',
    category: AlgoCategory.sorting,
    blurb: 'One hole per value, then read in order.',
    description:
        'Pigeonhole sort places each element into a hole indexed by its value, '
        'then reads the holes in order. Like counting sort, it shines on small '
        'value ranges.',
    timeComplexity: 'O(n + range)',
    spaceComplexity: 'O(range)',
    originalSources: ['C++'],
    create: () => _arrayRun(pigeonholeSort(_randomArray(n: 12, min: 0, max: 24))),
  ),
  AlgorithmInfo(
    id: 'fibonacci-search',
    name: 'Fibonacci Search',
    category: AlgoCategory.searching,
    blurb: 'Split a sorted range by Fibonacci numbers.',
    description:
        'Fibonacci search narrows a sorted range using Fibonacci numbers to '
        'pick probe points, using only addition and subtraction (no division) '
        'like binary search.',
    timeComplexity: 'O(log n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final a = _randomArray(n: 16)..sort();
      return _arrayRun(fibonacciSearch(a, a[Random().nextInt(a.length)]));
    },
  ),
  AlgorithmInfo(
    id: 'greedy-best-first',
    name: 'Greedy Best-First',
    category: AlgoCategory.pathfinding,
    blurb: 'Always head toward the goal by heuristic.',
    description:
        'Greedy best-first search expands whichever frontier cell looks closest '
        'to the goal (smallest heuristic). It is fast and direct, but unlike A* '
        'it can return a non-shortest path.',
    timeComplexity: 'O(E log V)',
    spaceComplexity: 'O(V)',
    originalSources: ['AI'],
    create: () => _gridRunOf(greedyBestFirstDemo()),
  ),
  AlgorithmInfo(
    id: 'flood-fill',
    name: 'Flood Fill',
    category: AlgoCategory.pathfinding,
    blurb: 'Spread from a seed to a connected region.',
    description:
        'Flood fill expands from a seed cell to every connected open cell, the '
        'way a paint-bucket tool colours a contiguous area.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    originalSources: ['C++'],
    create: () => _gridRunOf(floodFillDemo()),
  ),
  AlgorithmInfo(
    id: 'lis',
    name: 'Longest Increasing Subsequence',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Longest strictly increasing run (not contiguous).',
    description:
        'The LIS is the longest subsequence whose values strictly increase. The '
        'DP tracks the best run ending at each index, then reconstructs the '
        'subsequence.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _arrayRun(longestIncreasingSubsequence(_randomArray(n: 12, min: 1, max: 40))),
  ),
  AlgorithmInfo(
    id: 'subset-sum',
    name: 'Subset Sum',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Can a subset reach a target sum?',
    description:
        'Subset sum asks whether any subset of the numbers adds up to a target. '
        'The DP table marks each (items, sum) pair reachable, building on '
        'smaller sub-problems.',
    timeComplexity: 'O(n·target)',
    spaceComplexity: 'O(n·target)',
    originalSources: ['C++'],
    create: () => _tableRun(subsetSum()),
  ),
  AlgorithmInfo(
    id: 'rod-cutting',
    name: 'Rod Cutting',
    category: AlgoCategory.dynamicProgramming,
    blurb: 'Maximise revenue from cutting a rod.',
    description:
        'Given prices per length, the rod-cutting DP finds the most valuable '
        'way to cut a rod, computing the best revenue for every length from the '
        'shorter pieces.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _tableRun(rodCutting()),
  ),
  AlgorithmInfo(
    id: 'z-algorithm',
    name: 'Z-Algorithm',
    category: AlgoCategory.strings,
    blurb: 'Match via the Z prefix-length array.',
    description:
        'The Z-algorithm computes, for each position, the length of the longest '
        'substring starting there that matches a prefix. Building it over '
        '"pattern # text" reveals every match in linear time.',
    timeComplexity: 'O(n + m)',
    spaceComplexity: 'O(n + m)',
    originalSources: ['C++'],
    create: () => _stringRun(zSearch()),
  ),
  AlgorithmInfo(
    id: 'newton-sqrt',
    name: "Newton's Square Root",
    category: AlgoCategory.mathematics,
    blurb: 'Converge on a square root by iteration.',
    description:
        'Newton’s method refines a guess g for √n by averaging it with n/g. The '
        'estimate doubles its correct digits each step — quadratic convergence.',
    timeComplexity: 'O(log log n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(newtonSqrt(20 + Random().nextInt(180))),
  ),
  AlgorithmInfo(
    id: 'extended-euclid',
    name: 'Extended Euclid',
    category: AlgoCategory.mathematics,
    blurb: 'GCD plus the Bézout coefficients.',
    description:
        'The extended Euclidean algorithm computes gcd(a, b) along with integers '
        'x and y satisfying a·x + b·y = gcd — the basis of modular inverses.',
    timeComplexity: 'O(log min(a,b))',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () {
      final rng = Random();
      return _arrayRun(extendedEuclid(30 + rng.nextInt(170), 12 + rng.nextInt(90)));
    },
  ),
  AlgorithmInfo(
    id: 'convex-hull',
    name: 'Convex Hull',
    category: AlgoCategory.geometry,
    blurb: 'Smallest polygon enclosing all points.',
    description:
        'The convex hull is the tightest convex polygon containing a set of '
        'points. Andrew’s monotone chain sorts the points and sweeps to build '
        'the lower and upper hulls, popping any concave turn.',
    timeComplexity: 'O(n log n)',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _hullRun(convexHull()),
  ),
  AlgorithmInfo(
    id: 'stooge-sort',
    name: 'Stooge Sort',
    category: AlgoCategory.sorting,
    blurb: 'A recursive sort over overlapping two-thirds.',
    description:
        'Stooge sort swaps the two ends if they are out of order, then '
        'recursively sorts the first two-thirds, the last two-thirds, and the '
        'first two-thirds again. It is famous mainly for its surprisingly bad '
        'O(n^2.71) running time.',
    timeComplexity: 'O(n^2.71)',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _arrayRun(stoogeSort(_randomArray(n: 7))),
  ),
  AlgorithmInfo(
    id: 'binary-exponentiation',
    name: 'Binary Exponentiation',
    category: AlgoCategory.mathematics,
    blurb: 'Compute powers in O(log n) by squaring.',
    description:
        'Exponentiation by squaring reads the exponent’s binary digits: it '
        'squares the base at every step and multiplies it into the result '
        'whenever the current bit is set, computing base^exp in O(log exp) '
        'multiplications.',
    timeComplexity: 'O(log n)',
    spaceComplexity: 'O(1)',
    originalSources: ['C++'],
    create: () => _arrayRun(binaryExponentiation()),
  ),
  AlgorithmInfo(
    id: 'fenwick-tree',
    name: 'Fenwick Tree (BIT)',
    category: AlgoCategory.dataStructures,
    blurb: 'Prefix sums and updates in O(log n).',
    description:
        'A Fenwick tree (binary indexed tree) stores partial sums so that both '
        'a point update and a prefix-sum query touch only O(log n) slots, each '
        'responsible for a range whose length is the lowest set bit of its '
        'index.',
    timeComplexity: 'O(log n) per op',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _arrayRun(fenwickTree()),
  ),
  AlgorithmInfo(
    id: 'tree-inorder',
    name: 'In-order Traversal',
    category: AlgoCategory.trees,
    blurb: 'Visit the node between its subtrees.',
    description:
        'An in-order traversal recurses into the left subtree, visits the node, '
        'then recurses into the right. On a binary search tree this yields the '
        'values in sorted order.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h)',
    originalSources: ['C', 'C++', 'Java'],
    create: () => _treeRun(treeTraversal(_distinctValues(), 'in')),
  ),
  AlgorithmInfo(
    id: 'horspool',
    name: 'Boyer–Moore–Horspool',
    category: AlgoCategory.strings,
    blurb: 'Simplified Boyer–Moore with one shift table.',
    description:
        'Boyer–Moore–Horspool compares the pattern right-to-left and, on a '
        'mismatch, always shifts based on the text character aligned with the '
        'pattern’s last position — a single bad-character table that is simple '
        'and fast in practice.',
    timeComplexity: 'O(n) avg',
    spaceComplexity: 'O(k)',
    originalSources: ['C++'],
    create: () => _stringRun(horspool()),
  ),
  AlgorithmInfo(
    id: 'closest-pair',
    name: 'Closest Pair of Points',
    category: AlgoCategory.geometry,
    blurb: 'Find the two nearest points in a set.',
    description:
        'The closest-pair problem asks for the two points with the smallest '
        'separation. This demo checks every pair and keeps the best so far; the '
        'classic divide-and-conquer algorithm solves it in O(n log n).',
    timeComplexity: 'O(n²) brute',
    spaceComplexity: 'O(n)',
    originalSources: ['C++'],
    create: () => _hullRun(closestPair()),
  ),
  AlgorithmInfo(
    id: 'graham-scan', name: 'Graham Scan', category: AlgoCategory.geometry,
    blurb: 'Convex hull by sorting on polar angle.',
    description: 'The Graham scan sorts the points by polar angle around the lowest point, then sweeps once, popping any point that would make a non-left turn — building the convex hull in O(n log n).',
    timeComplexity: 'O(n log n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _hullRun(grahamScan()),
  ),
  AlgorithmInfo(
    id: 'point-in-polygon', name: 'Point in Polygon', category: AlgoCategory.geometry,
    blurb: 'Ray casting: count edge crossings.',
    description: 'To test whether a point lies inside a polygon, cast a ray and count how many edges it crosses: an odd number means inside, an even number means outside.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () => _hullRun(pointInPolygon()),
  ),

  // ---- Arrays ----
  AlgorithmInfo(
    id: 'array-traversal', name: 'Array Traversal', category: AlgoCategory.arrays,
    blurb: 'Read each element once, left to right.',
    description: 'The most basic array operation: visit every index in order, reading each element exactly once in O(n).',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _arrayRun(arrayTraversal(_randomArray(n: 10))),
  ),
  AlgorithmInfo(
    id: 'array-insertion', name: 'Array Insertion', category: AlgoCategory.arrays,
    blurb: 'Insert a value, shifting the tail right.',
    description: 'Inserting into an array at a position means shifting every later element one slot to the right to make room — O(n) in the worst case.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _arrayRun(arrayInsertion(_randomArray(n: 8))),
  ),
  AlgorithmInfo(
    id: 'array-deletion', name: 'Array Deletion', category: AlgoCategory.arrays,
    blurb: 'Remove a value, shifting the tail left.',
    description: 'Deleting from an array shifts every later element one slot left to close the gap, an O(n) operation.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _arrayRun(arrayDeletion(_randomArray(n: 9))),
  ),
  AlgorithmInfo(
    id: 'contiguous-subarray', name: 'Contiguous Sub-array', category: AlgoCategory.arrays,
    blurb: 'Largest-sum contiguous block (Kadane).',
    description: 'Kadane’s scan keeps a running sum, restarting it whenever it turns negative, to find the contiguous block with the maximum sum in one pass.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C++', 'Python'],
    create: () {
      final rng = Random();
      return _arrayRun(contiguousSubarray([for (var i = 0; i < 12; i++) -8 + rng.nextInt(18)]));
    },
  ),
  AlgorithmInfo(
    id: 'noncontiguous-subarray', name: 'Non-contiguous Sub-array', category: AlgoCategory.arrays,
    blurb: 'Largest-sum subsequence (pick positives).',
    description: 'When elements need not be adjacent, the maximum-sum subsequence is simply every positive element added together.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () {
      final rng = Random();
      return _arrayRun(nonContiguousSubarray([for (var i = 0; i < 12; i++) -6 + rng.nextInt(16)]));
    },
  ),

  AlgorithmInfo(
    id: 'array-reversal', name: 'Array Reversal', category: AlgoCategory.arrays,
    blurb: 'Swap the two ends inward.',
    description: 'Reverse an array in place using two pointers that start at the ends and swap their elements while moving toward the middle.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _arrayRun(arrayReversal(_randomArray(n: 10))),
  ),

  // ---- Lists ----
  AlgorithmInfo(
    id: 'list-traversal', name: 'List Traversal', category: AlgoCategory.lists,
    blurb: 'Follow next pointers to the end.',
    description: 'Traverse a singly linked list by following each node’s next pointer until reaching null.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(listTraversal()),
  ),
  AlgorithmInfo(
    id: 'list-sorted-insert', name: 'List Sorted Insert', category: AlgoCategory.lists,
    blurb: 'Insert while keeping the list ordered.',
    description: 'Walk a sorted linked list until the next value would exceed the new one, then splice the new node in to preserve order.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(listSortedInsert()),
  ),
  AlgorithmInfo(
    id: 'list-search', name: 'List Search', category: AlgoCategory.lists,
    blurb: 'Scan node by node for a value.',
    description: 'Linear search over a linked list: compare each node’s value with the target until found or the list ends.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(listSearch()),
  ),
  AlgorithmInfo(
    id: 'list-insert', name: 'List Insert', category: AlgoCategory.lists,
    blurb: 'Insert a node at a position.',
    description: 'Insert a node at a given position by walking to the predecessor and re-linking pointers — no shifting like an array.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(listInsert()),
  ),
  AlgorithmInfo(
    id: 'list-delete', name: 'List Delete', category: AlgoCategory.lists,
    blurb: 'Unlink a node by value.',
    description: 'Delete a node by finding it and pointing its predecessor past it, releasing the node.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(listDelete()),
  ),
  AlgorithmInfo(
    id: 'list-merge', name: 'List Merge', category: AlgoCategory.lists,
    blurb: 'Merge two sorted lists into one.',
    description: 'Repeatedly take the smaller of the two list heads to build a single sorted list — the merge step of merge sort.',
    timeComplexity: 'O(n + m)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () => _linkedRun(listMerge()),
  ),
  AlgorithmInfo(
    id: 'list-bubble-sort', name: 'List Bubble Sort', category: AlgoCategory.lists,
    blurb: 'Sort a list by swapping node values.',
    description: 'Bubble sort applied to a linked list: repeatedly swap adjacent nodes that are out of order until the list is sorted.',
    timeComplexity: 'O(n²)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () => _linkedRun(listBubbleSort()),
  ),
  AlgorithmInfo(
    id: 'list-reverse', name: 'List Reverse', category: AlgoCategory.lists,
    blurb: 'Flip every next pointer.',
    description: 'Reverse a singly linked list in place by re-pointing each node’s next to its predecessor.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(listReverse()),
  ),
  AlgorithmInfo(
    id: 'multi-list', name: 'Multi-list', category: AlgoCategory.lists,
    blurb: 'Several sub-lists chained together.',
    description: 'A multi-list links several sub-lists into one structure — here their nodes are chained head to tail.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _linkedRun(multiList()),
  ),
  AlgorithmInfo(
    id: 'jagged-linked-list', name: 'Jagged Linked List', category: AlgoCategory.lists,
    blurb: 'Rows of differing length; traverse & add.',
    description: 'A jagged linked list is a list of sub-lists with different lengths. This demo traverses the ragged rows, then adds two rows element-wise.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _linkedRun(jaggedLinkedList()),
  ),
  AlgorithmInfo(
    id: 'list-middle', name: 'List Middle (Slow/Fast)', category: AlgoCategory.lists,
    blurb: 'Tortoise & hare find the middle node.',
    description: 'Two pointers advance through the list, one twice as fast as the other; when the fast one reaches the end, the slow one sits at the middle — one pass, no length needed.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () => _linkedRun(listMiddle()),
  ),

  // ---- Matrices ----
  AlgorithmInfo(
    id: 'matrix-subtract', name: 'Matrix Subtraction', category: AlgoCategory.matrices,
    blurb: 'Subtract two equal-sized matrices.',
    description: 'Matrix subtraction takes two matrices of the same shape and subtracts corresponding entries.',
    timeComplexity: 'O(n²)', spaceComplexity: 'O(n²)', originalSources: ['C', 'C++'],
    create: () => _matrixRun(matrixSubtract()),
  ),
  AlgorithmInfo(
    id: 'sparse-matrix', name: 'Sparse Matrix', category: AlgoCategory.matrices,
    blurb: 'Store only the non-zero entries.',
    description: 'A sparse matrix stores only its non-zero values as (row, column, value) triplets, saving space when most entries are zero.',
    timeComplexity: 'O(nnz)', spaceComplexity: 'O(nnz)', originalSources: ['C++'],
    create: () => _tableRun(sparseMatrix()),
  ),
  AlgorithmInfo(
    id: 'strassen', name: "Strassen's Multiplication", category: AlgoCategory.matrices,
    blurb: 'Multiply 2×2 with 7 products, not 8.',
    description: 'Strassen’s algorithm multiplies matrices using 7 recursive products instead of 8, lowering the exponent to about 2.81.',
    timeComplexity: 'O(n^2.81)', spaceComplexity: 'O(n²)', originalSources: ['C++'],
    create: () => _tableRun(strassen()),
  ),
  AlgorithmInfo(
    id: 'determinant', name: 'Determinant', category: AlgoCategory.matrices,
    blurb: '3×3 determinant by cofactor expansion.',
    description: 'The determinant of a 3×3 matrix via cofactor expansion along the first row, summing signed minors.',
    timeComplexity: 'O(n!)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () => _tableRun(determinant()),
  ),
  AlgorithmInfo(
    id: 'matrix-inversion', name: 'Matrix Inversion', category: AlgoCategory.matrices,
    blurb: 'Invert via Gauss–Jordan on [A | I].',
    description: 'Gauss–Jordan elimination augments A with the identity and row-reduces A to I; the identity side becomes A⁻¹.',
    timeComplexity: 'O(n³)', spaceComplexity: 'O(n²)', originalSources: ['C++'],
    create: () => _tableRun(matrixInversion()),
  ),

  AlgorithmInfo(
    id: 'matrix-transpose', name: 'Matrix Transpose', category: AlgoCategory.matrices,
    blurb: 'Reflect a matrix across its diagonal.',
    description: 'The transpose turns rows into columns by swapping each entry (i, j) with (j, i); for a square matrix this can be done in place across the main diagonal.',
    timeComplexity: 'O(n²)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _tableRun(matrixTranspose()),
  ),

  // ---- Stacks & Queues ----
  AlgorithmInfo(
    id: 'circular-queue', name: 'Circular Queue', category: AlgoCategory.stacksQueues,
    blurb: 'A ring buffer that reuses freed slots.',
    description: 'A circular queue stores elements in a fixed buffer whose head and tail wrap around, reusing slots freed at the front without shifting.',
    timeComplexity: 'O(1) per op', spaceComplexity: 'O(capacity)', originalSources: ['C', 'C++'],
    create: () => _sequenceRun(circularQueue()),
  ),
  AlgorithmInfo(
    id: 'linked-stack', name: 'Linked Stack', category: AlgoCategory.stacksQueues,
    blurb: 'A stack backed by a linked list.',
    description: 'A linked stack pushes and pops at the list head, giving O(1) operations without a fixed capacity.',
    timeComplexity: 'O(1) per op', spaceComplexity: 'O(n)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(linkedStack()),
  ),
  AlgorithmInfo(
    id: 'linked-queue', name: 'Linked Queue', category: AlgoCategory.stacksQueues,
    blurb: 'A queue backed by a linked list.',
    description: 'A linked queue enqueues at the tail and dequeues at the head, both in O(1) with head and tail pointers.',
    timeComplexity: 'O(1) per op', spaceComplexity: 'O(n)', originalSources: ['C', 'C++'],
    create: () => _linkedRun(linkedQueue()),
  ),
  AlgorithmInfo(
    id: 'circular-linked-queue', name: 'Circular Linked Queue', category: AlgoCategory.stacksQueues,
    blurb: 'Tail links back to head for O(1) ends.',
    description: 'A circular linked queue keeps the tail pointing at the head, so a single tail pointer reaches both ends in O(1).',
    timeComplexity: 'O(1) per op', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _linkedRun(circularLinkedQueue()),
  ),
  AlgorithmInfo(
    id: 'dll-stack', name: 'Doubly Linked Stack', category: AlgoCategory.stacksQueues,
    blurb: 'A stack built on a doubly linked list.',
    description: 'A doubly linked list used as a stack pushes and pops at the head, while its prev pointers also allow walking back from the top.',
    timeComplexity: 'O(1) per op', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _linkedRun(doublyLinkedStack()),
  ),
  AlgorithmInfo(
    id: 'monotonic-stack', name: 'Monotonic Stack', category: AlgoCategory.stacksQueues,
    blurb: 'A stack kept sorted by popping on push.',
    description: 'A monotonic stack pops every element larger than the incoming value before pushing it, keeping the stack increasing. It solves next-greater/smaller-element problems in O(n).',
    timeComplexity: 'O(n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _sequenceRun(monotonicStack(_randomArray(n: 8))),
  ),

  // ---- Data Types ----
  AlgorithmInfo(
    id: 'ascii-codes', name: 'Character ASCII', category: AlgoCategory.dataTypes,
    blurb: 'Each character is an integer code.',
    description: 'Characters are stored as integer ASCII code points; this reads each character and shows its code.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C'],
    create: () => _textRun(asciiCodes()),
  ),
  AlgorithmInfo(
    id: 'char-identification', name: 'Character Identification', category: AlgoCategory.dataTypes,
    blurb: 'Letter, digit, or symbol?',
    description: 'Classify each character by its code range as a letter, a digit, or a symbol.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C'],
    create: () => _textRun(charIdentification()),
  ),
  AlgorithmInfo(
    id: 'palindrome', name: 'Palindrome Check', category: AlgoCategory.dataTypes,
    blurb: 'Compare characters from both ends.',
    description: 'A string is a palindrome if it reads the same forwards and backwards; compare characters moving inward from both ends.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _textRun(palindromeCheck()),
  ),
  AlgorithmInfo(
    id: 'substring-extraction', name: 'Substring Extraction', category: AlgoCategory.dataTypes,
    blurb: 'Pull out a range of characters.',
    description: 'Extract a substring by selecting the characters in a half-open index range.',
    timeComplexity: 'O(k)', spaceComplexity: 'O(k)', originalSources: ['C', 'C++'],
    create: () => _textRun(substringExtraction()),
  ),
  AlgorithmInfo(
    id: 'string-concatenation', name: 'String Concatenation', category: AlgoCategory.dataTypes,
    blurb: 'Append one string onto another.',
    description: 'Concatenation joins two strings by copying the second onto the end of the first.',
    timeComplexity: 'O(n + m)', spaceComplexity: 'O(n + m)', originalSources: ['C', 'C++'],
    create: () => _textRun(stringConcatenation()),
  ),
  AlgorithmInfo(
    id: 'vowel-count', name: 'Vowel Count', category: AlgoCategory.dataTypes,
    blurb: 'Tally the vowels in a string.',
    description: 'Scan a string and count how many of its characters are vowels.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _textRun(vowelCount()),
  ),

  // ---- Hash table variants ----
  AlgorithmInfo(
    id: 'hash-quadratic', name: 'Quadratic Probing', category: AlgoCategory.dataStructures,
    blurb: 'Open addressing with 1², 2², 3² steps.',
    description: 'Quadratic probing resolves collisions by stepping ahead by increasing squares (1², 2², 3², …), which scatters clustered keys better than linear probing.',
    timeComplexity: 'O(1) avg', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _hashRun(hashQuadraticProbing()),
  ),
  AlgorithmInfo(
    id: 'hash-chaining', name: 'Separate Chaining', category: AlgoCategory.dataStructures,
    blurb: 'Each bucket holds a linked list of keys.',
    description: 'Separate chaining stores all keys that hash to the same bucket in a linked list, so the table never fills up and collisions just lengthen a chain.',
    timeComplexity: 'O(1 + α)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _chainHashRun(hashSeparateChaining()),
  ),
  AlgorithmInfo(
    id: 'hash-chaining-avl', name: 'Chaining with AVL Buckets', category: AlgoCategory.dataStructures,
    blurb: 'Balanced buckets keep long chains fast.',
    description: 'When buckets can grow large, backing each with a balanced (AVL) tree keeps lookups within a bucket O(log m) instead of O(m). Shown here as each bucket\'s sorted in-order keys.',
    timeComplexity: 'O(log m)/bucket', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _chainHashRun(hashChainingAvl()),
  ),

  // ---- Trees & Heaps ----
  AlgorithmInfo(
    id: 'bst-search', name: 'BST Search', category: AlgoCategory.trees,
    blurb: 'Follow the comparison path to a value.',
    description: 'Searching a binary search tree compares the target at each node and descends left or right, halving the remaining tree on a balanced shape.',
    timeComplexity: 'O(h)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () {
      final v = _distinctValues();
      return _treeRun(bstSearch(v, v[Random().nextInt(v.length)]));
    },
  ),
  AlgorithmInfo(
    id: 'bst-smallest', name: 'BST Minimum', category: AlgoCategory.trees,
    blurb: 'Walk left to the smallest value.',
    description: 'The minimum of a BST is found by following left children until there are none.',
    timeComplexity: 'O(h)', spaceComplexity: 'O(1)', originalSources: ['C', 'C++'],
    create: () => _treeRun(bstSmallest(_distinctValues())),
  ),
  AlgorithmInfo(
    id: 'bst-height', name: 'BST Height', category: AlgoCategory.trees,
    blurb: 'Length of the longest root-to-leaf path.',
    description: 'The height of a tree is the number of nodes on its longest root-to-leaf path — what bounds every search and traversal.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(h)', originalSources: ['C', 'C++'],
    create: () => _treeRun(bstHeight(_distinctValues())),
  ),
  AlgorithmInfo(
    id: 'bst-delete', name: 'BST Deletion', category: AlgoCategory.trees,
    blurb: 'Remove a node (leaf / one / two children).',
    description: 'Deleting from a BST handles three cases: a leaf is removed outright, a one-child node is spliced out, and a two-child node is replaced by its in-order successor.',
    timeComplexity: 'O(h)', spaceComplexity: 'O(1)', originalSources: ['C++'],
    create: () {
      final v = _distinctValues();
      return _treeRun(bstDelete(v, v[Random().nextInt(v.length)]));
    },
  ),
  AlgorithmInfo(
    id: 'root-to-leaf', name: 'Root-to-Leaf Paths', category: AlgoCategory.trees,
    blurb: 'Enumerate every path to a leaf.',
    description: 'A depth-first walk lists every root-to-leaf path of a tree — the basis of path-sum and serialization problems.',
    timeComplexity: 'O(n)', spaceComplexity: 'O(h)', originalSources: ['C++'],
    create: () => _treeRun(rootToLeaf(_distinctValues())),
  ),
  AlgorithmInfo(
    id: 'kary-heap', name: 'k-ary Heap', category: AlgoCategory.trees,
    blurb: 'A heap where each node has k children.',
    description: 'A k-ary heap generalises the binary heap: each node has up to k children, trading shallower trees for more comparisons per sift.',
    timeComplexity: 'O(log_k n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _gtreeRun(karyHeap()),
  ),
  AlgorithmInfo(
    id: 'b-tree', name: 'B-Tree', category: AlgoCategory.trees,
    blurb: 'Multi-key nodes that split when full.',
    description: 'A B-tree keeps several keys per node and splits a full node, promoting its median to the parent. All leaves stay at the same depth — ideal for disk-backed indexes.',
    timeComplexity: 'O(log n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _gtreeRun(bTree()),
  ),
  AlgorithmInfo(
    id: 'red-black-tree', name: 'Red-Black Tree', category: AlgoCategory.trees,
    blurb: 'Self-balancing BST via colours & rotations.',
    description: 'A red-black tree colours nodes red or black and enforces rules (no red-red edges; equal black-heights) using recolours and rotations after each insert, guaranteeing O(log n) height.',
    timeComplexity: 'O(log n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _gtreeRun(redBlackTree()),
  ),
  AlgorithmInfo(
    id: 'binomial-heap', name: 'Binomial Heap', category: AlgoCategory.trees,
    blurb: 'A forest of binomial trees merged by order.',
    description: 'A binomial heap is a forest of binomial trees, at most one of each order. Inserting links equal-order trees with a carry, mirroring binary addition.',
    timeComplexity: 'O(log n)', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _gtreeRun(binomialHeap()),
  ),
  AlgorithmInfo(
    id: 'interval-tree', name: 'Interval Tree', category: AlgoCategory.trees,
    blurb: 'BST of intervals augmented with max endpoint.',
    description: 'An interval tree is a BST keyed by interval start, with each node storing the maximum endpoint in its subtree so overlap queries can prune whole branches.',
    timeComplexity: 'O(log n) query', spaceComplexity: 'O(n)', originalSources: ['C++'],
    create: () => _gtreeRun(intervalTree()),
  ),

  // ---- AI ----
  AlgorithmInfo(
    id: 'minimax', name: 'Minimax', category: AlgoCategory.ai,
    blurb: 'Optimal play for two-player zero-sum games.',
    description: 'Minimax explores a game tree assuming both players play optimally: the maximiser picks the largest child value, the minimiser the smallest, propagating values up to choose the best move.',
    timeComplexity: 'O(b^d)', spaceComplexity: 'O(b·d)', originalSources: ['AI'],
    create: () => _gtreeRun(minimax()),
  ),
  AlgorithmInfo(
    id: 'alpha-beta', name: 'Alpha–Beta Pruning', category: AlgoCategory.ai,
    blurb: 'Minimax that skips irrelevant branches.',
    description: 'Alpha–Beta keeps bounds (α, β) on the achievable score and prunes any branch that cannot influence the final decision, reaching the same answer as minimax with far fewer evaluations.',
    timeComplexity: 'O(b^(d/2)) best', spaceComplexity: 'O(b·d)', originalSources: ['AI'],
    create: () => _gtreeRun(alphaBeta()),
  ),
  AlgorithmInfo(
    id: 'mcts', name: 'Monte-Carlo Tree Search', category: AlgoCategory.ai,
    blurb: 'Select, expand, simulate, back-propagate.',
    description: 'MCTS builds a search tree by repeatedly selecting a promising node, expanding it, running a random rollout, and back-propagating the result as wins/visits — the engine behind modern game AIs.',
    timeComplexity: 'O(iterations)', spaceComplexity: 'O(nodes)', originalSources: ['AI'],
    create: () => _gtreeRun(monteCarlo()),
  ),
  AlgorithmInfo(
    id: 'ucs', name: 'Uniform Cost Search', category: AlgoCategory.ai,
    blurb: 'Expand the cheapest frontier node first.',
    description: 'Uniform Cost Search expands the frontier node with the smallest cumulative path cost g, guaranteeing an optimal path on non-negative edge weights — Dijkstra framed as a search.',
    timeComplexity: 'O(E log V)', spaceComplexity: 'O(V)', originalSources: ['AI'],
    create: () => _gtreeRun(uniformCostSearch()),
  ),
];

Map<AlgoCategory, List<AlgorithmInfo>> get catalogByCategory {
  final map = <AlgoCategory, List<AlgorithmInfo>>{};
  for (final algo in catalog) {
    map.putIfAbsent(algo.category, () => []).add(algo);
  }
  return map;
}
