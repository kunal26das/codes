# AlgoScope

A Flutter app that visualizes **158 classic algorithms and data structures** in
action — each one implemented in Dart and animated step by step, wrapped in a
warm, Claude-inspired design system (ivory paper, terracotta accent, editorial
serif headings, light/dark themes).

Every algorithm runs live: tap a card, then **play / pause / step / scrub**
through the frames, change the **speed**, or roll a **new random input**.

## What's inside

158 algorithms across 18 categories:

| Category | Count | Examples |
| --- | --- | --- |
| Sorting | 20 | Bubble, Merge, Quick, Heap, Radix, Counting, Shell, Bucket, … |
| Trees & Heaps | 16 | BST (search/insert/delete/traversals), AVL, Red-Black, B-Tree, Binary/Binomial/k-ary heaps |
| Lists | 14 | Singly / Doubly / Circular / Multi / Jagged, plus all operations |
| Data Structures | 12 | Hash Table, Trie, Union-Find, Deque, Priority Queue, Fenwick, LRU Cache |
| Mathematics | 12 | Sieve, Fibonacci, GCD/LCM, Pascal, Collatz, Binary Exponentiation |
| Dynamic Programming | 10 | Knapsack, LCS, Edit Distance, Coin Change, LIS, Subset Sum, Rod Cutting |
| Searching | 8 | Linear, Binary, Interpolation, Jump, Ternary, Exponential, Fibonacci, Quickselect |
| Matrices | 8 | Add, Subtract, Multiply, Strassen, Determinant, Inversion, Transpose, Sparse |
| Stacks & Queues | 8 | Stack, Queue, Circular/Linked variants, Monotonic Stack |
| Optimization | 8 | Genetic, Ant Colony, PSO, Simulated Annealing, Hill Climbing, Firefly, Cuckoo |
| Graphs | 6 | Prim, Kruskal, Bellman-Ford, Topological Sort, Cycle Detection, Graph Colouring |
| Strings | 6 | Naive, KMP, Boyer-Moore, Rabin-Karp, Z-Algorithm, Horspool |
| Pathfinding | 6 | A\*, BFS, DFS, Dijkstra, Greedy Best-First, Flood Fill |
| Arrays | 6 | Traversal, Insertion, Deletion, Reversal, Contiguous / Non-contiguous sub-array |
| Data Types | 6 | ASCII, Character ID, Palindrome, Substring, Concatenation, Vowel Count |
| Backtracking | 4 | N-Queens, Tower of Hanoi, Rat in a Maze, Knight's Tour |
| Geometry | 4 | Convex Hull, Closest Pair, Graham Scan, Point in Polygon |
| AI | 4 | Minimax, Alpha-Beta Pruning, Monte-Carlo Tree Search, Uniform Cost Search |

## How it's built

Each algorithm is a pure Dart function that returns a list of immutable *frames*
(snapshots). A shared `VizRun` wraps those frames with a caption and a painter,
so the player screen stays generic. Visualizers are `CustomPainter`s, so they
scale crisply on phone, web, and desktop.

```
lib/
  main.dart              app shell + light/dark theme toggle
  theme/                 Claude design system (colors + ThemeData)
  models/                frame types, VizRun, algorithm metadata
  algorithms/            pure step-generators, grouped by domain
  visualizers/           CustomPainters (bars, tree, grid, board, hanoi, …)
  widgets/               small shared UI (pills, legend)
  screens/               home catalog + algorithm player
  data/catalog.dart      wires algorithms → metadata → visualizers
test/                    logic tests for the algorithms
```

## Running it

```bash
flutter pub get
flutter run -d chrome     # or: macos, windows, linux, or a device id
flutter test              # run the algorithm logic tests
```

Requires Flutter 3.27+ (Dart 3.6+). If the platform folders aren't present, run
`flutter create .` once to generate them (it leaves `lib/` intact).

### Fonts

The app uses Claude's own type system: **Tiempos** for headings, **Copernicus**
for large display text, and **Styrene B** for body and UI. These are licensed
Klim Type Foundry fonts and are not bundled — the theme requests them by family
name first, so they render wherever they're installed or licensed. If you have a
license, drop the files into `assets/fonts/` and uncomment the `fonts:` block in
`pubspec.yaml`. Otherwise the app falls back to the closest open substitutes,
Source Serif 4 (≈ Tiempos) and Hanken Grotesk (≈ Styrene), via `google_fonts`.
