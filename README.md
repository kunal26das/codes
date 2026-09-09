# AlgoScope

A Flutter app that visualizes **216 classic algorithms and data structures** in
action — each one implemented in Dart and animated step by step, wrapped in a
warm, Claude-inspired design system (ivory paper, terracotta accent, editorial
serif headings, light/dark themes).

Every algorithm runs live: tap a card, then **play / pause / step / scrub**
through the frames, change the **speed**, or generate a **new run**. Many demos
vary their inputs; others retain a small example that illustrates a key case.

## What's inside

216 algorithms across 18 categories:

| Category | Count | Examples |
| --- | --- | --- |
| Sorting | 23 | Bubble, Merge, Quick, Heap, Radix, Natural Merge, Binary Insertion, Tournament, … |
| Trees & Heaps | 16 | BST (search/insert/delete/traversals), AVL, Red-Black, B-Tree, Binary/Binomial/k-ary heaps |
| Lists | 14 | Singly / Doubly / Circular / Multi / Jagged, plus all operations |
| Data Structures | 12 | Hash Table, Trie, Union-Find, Deque, Priority Queue, Fenwick, LRU Cache |
| Mathematics | 15 | Sieve, Fibonacci, GCD/LCM, Pascal, Catalan, Derangements, Integer Partitions |
| Dynamic Programming | 22 | Knapsack, LCS, Edit Distance, Matrix Chain, Egg Dropping, Boolean Parenthesization, Weighted Intervals |
| Searching | 9 | Linear, Binary, Interpolation, Jump, Ternary, Exponential, Fibonacci, Quickselect, Equal Range |
| Matrices | 8 | Add, Subtract, Multiply, Strassen, Determinant, Inversion, Transpose, Sparse |
| Stacks & Queues | 12 | Stack, Queue, Next Greater Element, Balanced Brackets, Shunting Yard, Postfix Evaluation |
| Optimization | 8 | Genetic, Ant Colony, PSO, Simulated Annealing, Hill Climbing, Firefly, Cuckoo |
| Graphs | 20 | Prim, Kruskal, Dijkstra, Kosaraju, Tarjan, Bridges, Articulation Points, Eulerian Path, Borůvka, Edmonds–Karp |
| Strings | 9 | KMP, Boyer-Moore, Rabin-Karp, Z-Algorithm, Longest Unique Substring, Run-Length Encoding, Manacher |
| Pathfinding | 6 | A\*, BFS, DFS, Dijkstra, Greedy Best-First, Flood Fill |
| Arrays | 13 | Traversal, Pair Sum, Sliding Window, Dutch Flag, Prefix Sums, Product Except Self, Rainwater, Majority Vote |
| Data Types | 6 | ASCII, Character ID, Palindrome, Substring, Concatenation, Vowel Count |
| Backtracking | 7 | N-Queens, Hanoi, Maze, Knight's Tour, Sudoku, Permutations, Hamiltonian Cycle |
| Geometry | 12 | Convex Hull, Closest Pair, Bresenham, Midpoint Circle, Line/Polygon Clipping, Douglas–Peucker, Bézier, Shoelace, Calipers |
| AI | 4 | Minimax, Alpha-Beta Pruning, Monte-Carlo Tree Search, Uniform Cost Search |

## How it's built

Each algorithm is a pure Dart function that returns a list of immutable *frames*
(snapshots). A shared `VizRun` wraps those frames with a caption and a painter,
so the player screen stays generic. Visualizers combine `CustomPainter`s with
labeled Flutter cells and state tables. Graphs expose their queues, stacks,
distances, lowlinks, or residual flow; sequence algorithms expose pointers and
working buffers; DP tables highlight the cells used by each recurrence.

Dense diagrams provide an overview plus **zoom / fit / pan** controls. Geometry
views distinguish original, working, and result layers over a coordinate grid.
Phone players let long captions grow without squeezing away the visualization.
Displayed complexity describes the algorithm, excluding saved animation frames.

```
lib/
  main.dart              app shell + system light/dark theme
  theme/                 Claude design system (colors + ThemeData)
  models/                frame types, VizRun, algorithm metadata
  algorithms/            pure step-generators, grouped by domain
  visualizers/           painters, labeled traces, tables, zoomable canvases
  widgets/               small shared UI (pills, legend)
  screens/               home catalog + algorithm player
  data/                  catalog + domain-specific additions
test/                    correctness, frame integrity, rendering, and player tests
```

## Running it

```bash
flutter pub get
flutter run -d chrome     # or: macos, windows, linux, or a device id
flutter test              # correctness and visualization tests
flutter analyze
flutter build web --release
```

Requires Flutter 3.44+ with its bundled Dart SDK. If the platform folders aren't
present, run `flutter create .` once to generate them (it leaves `lib/` intact).

The glass renderer is vendored with a small asset-manifest patch so native apps
retain refraction and web builds use its frosted-glass fallback. Flutter 3.44+
is required for platform-specific shader assets. See
[`third_party/liquid_glass_renderer/README.algoscope.md`](third_party/liquid_glass_renderer/README.algoscope.md)
for the patch and update procedure.

### Visualization verification

The catalog rendering suite visits **every generated frame of every algorithm**
at phone and desktop canvas sizes in both light and dark themes. Full-player
checks also seek to the start, middle, finish, and longest caption at portrait,
landscape, desktop, and enlarged-text settings. Navigation, search, playback,
stepping, scrubbing, rerolling, and zoom controls have separate widget coverage.

Algorithm tests compare results with independent brute-force or analytic oracles
and check intermediate state, immutable snapshots, invalid inputs, and degenerate
cases. Examples include reverse-edge cancellation in maximum flow, Sudoku
backtracking, Unicode palindrome searches, and geometry at very small scales or
large coordinate offsets. Tests print the generated-frame count, which varies
with randomized inputs. These checks complement live browser inspection; they do
not imply testing every possible input or physical device.

### Fonts

The app uses Claude's own type system: **Tiempos** for headings, **Copernicus**
for large display text, and **Styrene B** for body and UI. These are licensed
Klim Type Foundry fonts and are not bundled — the theme requests them by family
name first, so they render wherever they're installed or licensed. If you have a
license, drop the files into `assets/fonts/` and uncomment the `fonts:` block in
`pubspec.yaml`. Otherwise the app falls back to the closest open substitutes,
Source Serif 4 (≈ Tiempos) and Hanken Grotesk (≈ Styrene), via `google_fonts`.
