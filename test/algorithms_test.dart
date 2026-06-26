import 'package:algoscope/algorithms/ai.dart';
import 'package:algoscope/algorithms/arrays.dart';
import 'package:algoscope/algorithms/backtracking.dart';
import 'package:algoscope/algorithms/datastructures.dart';
import 'package:algoscope/algorithms/datatypes.dart';
import 'package:algoscope/algorithms/dynamic.dart';
import 'package:algoscope/algorithms/geometry.dart';
import 'package:algoscope/algorithms/graphs.dart';
import 'package:algoscope/algorithms/heaps_trees.dart';
import 'package:algoscope/algorithms/lists.dart';
import 'package:algoscope/algorithms/mathematics.dart';
import 'package:algoscope/algorithms/optimization.dart';
import 'package:algoscope/models/frames.dart';
import 'package:algoscope/algorithms/pathfinding.dart';
import 'package:algoscope/algorithms/searching.dart';
import 'package:algoscope/algorithms/sorting.dart';
import 'package:algoscope/algorithms/strings.dart';
import 'package:algoscope/algorithms/tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final input = [5, 2, 9, 1, 7, 3, 8, 4, 6];
  final expected = [...input]..sort();

  group('sorts produce a sorted final frame', () {
    for (final entry in {
      'bubble': bubbleSort,
      'insertion': insertionSort,
      'selection': selectionSort,
      'merge': mergeSort,
      'quick': quickSort,
      'heap': heapSort,
      'shell': shellSort,
      'cocktail': cocktailSort,
      'comb': combSort,
      'gnome': gnomeSort,
      'radix': radixSort,
      'counting': countingSort,
      'pancake': pancakeSort,
      'cycle': cycleSort,
      'bucket': bucketSort,
      'odd-even': oddEvenSort,
      'pigeonhole': pigeonholeSort,
    }.entries) {
      test(entry.key, () {
        final frames = entry.value(input);
        expect(frames.last.values, expected);
        // No frame index ever escapes the array bounds.
        for (final f in frames) {
          for (final i in {...f.comparing, ...f.active, ...f.done}) {
            expect(i, inInclusiveRange(0, input.length - 1));
          }
        }
      });
    }
  });

  test('binary search finds an existing value', () {
    final a = [...expected];
    final frames = binarySearch(a, 7);
    expect(frames.last.done, contains(a.indexOf(7)));
  });

  test('linear search finds an existing value', () {
    final frames = linearSearch(input, 8);
    expect(frames.last.done, contains(input.indexOf(8)));
  });

  test('bst in-order traversal is sorted', () {
    final frames = bstDemo([5, 3, 8, 1, 4, 7, 9]);
    expect(frames.last.output, [1, 3, 4, 5, 7, 8, 9]);
  });

  test('a* reaches the goal', () {
    final run = astarDemo(seed: 42);
    expect(run.frames.last.path.isNotEmpty, isTrue);
    expect(run.frames.last.path.last, run.goal);
  });

  test('n-queens finds a valid solution for n=8', () {
    final frames = nQueens(8);
    final solved = frames.lastWhere((f) => f.solved);
    final q = solved.queens;
    expect(q.every((c) => c >= 0), isTrue);
    for (var r1 = 0; r1 < 8; r1++) {
      for (var r2 = r1 + 1; r2 < 8; r2++) {
        expect(q[r1] == q[r2], isFalse);
        expect((r1 - r2).abs() == (q[r1] - q[r2]).abs(), isFalse);
      }
    }
  });

  test('hanoi solves in 2^n - 1 moves', () {
    final frames = hanoi(4);
    final moves = frames.where((f) => f.movingDisk != null).length;
    expect(moves, 15);
    expect(frames.last.pegs[2].length, 4);
  });

  test('interpolation search finds an existing value', () {
    final a = [...expected];
    final frames = interpolationSearch(a, 8);
    expect(frames.last.done, contains(a.indexOf(8)));
  });

  test('quickselect returns the k-th smallest value', () {
    final sorted = [...expected];
    for (var k = 1; k <= input.length; k++) {
      final frames = quickSelect(input, k);
      final answerIdx = frames.last.done.last;
      expect(frames.last.values[answerIdx], sorted[k - 1]);
    }
  });

  group('grid searches reach the goal', () {
    for (final entry in {
      'bfs': bfsDemo,
      'dfs': dfsDemo,
      'dijkstra': dijkstraDemo,
    }.entries) {
      test(entry.key, () {
        final run = entry.value(seed: 7);
        expect(run.frames.last.path.isNotEmpty, isTrue);
        expect(run.frames.last.path.first, run.start);
        expect(run.frames.last.path.last, run.goal);
        // Every path step is 4-adjacent and never a wall.
        final path = run.frames.last.path;
        for (var i = 0; i < path.length; i++) {
          expect(run.walls.contains(path[i]), isFalse);
          if (i > 0) {
            final a = path[i - 1], b = path[i];
            final dr = (a ~/ run.cols - b ~/ run.cols).abs();
            final dc = (a % run.cols - b % run.cols).abs();
            expect(dr + dc, 1);
          }
        }
      });
    }
  });

  test('bfs finds a shortest path (no longer than dfs)', () {
    final bfs = bfsDemo(seed: 3).frames.last.path.length;
    final dfs = dfsDemo(seed: 3).frames.last.path.length;
    expect(bfs, lessThanOrEqualTo(dfs));
  });

  test('rat in a maze reaches the exit', () {
    final run = ratInMaze(seed: 11);
    expect(run.frames.last.path.isNotEmpty, isTrue);
    expect(run.frames.last.path.last, run.goal);
  });

  test("knight's tour visits every square exactly once", () {
    final frames = knightsTour(n: 8);
    final last = frames.last;
    expect(last.solved, isTrue);
    final orders = last.board.toList()..sort();
    expect(orders, [for (var i = 1; i <= 64; i++) i]);
  });

  test('0/1 knapsack computes the optimal value', () {
    // Items (w,v): (2,3)(3,4)(4,5)(5,6), capacity 8 → best is {2,3}+{4,5}? = 10.
    final frames = knapsack();
    final last = frames.last;
    expect(last.cells[last.activeR!][last.activeC!], 10);
  });

  test('sieve finds exactly the primes up to 30', () {
    final frames = sieve(maxN: 30);
    final primes = frames.last.primes.toList()..sort();
    expect(primes, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]);
  });

  test('pascal rows are binomial and sum to powers of two', () {
    final last = pascalsTriangle(numRows: 6).last;
    expect(last.rows[4], [1, 4, 6, 4, 1]);
    for (var r = 0; r < last.rows.length; r++) {
      expect(last.rows[r].reduce((a, b) => a + b), 1 << r);
    }
  });

  test('collatz reaches 1', () {
    final frames = collatz(27);
    expect(frames.last.values.last, 1);
  });

  test('fibonacci produces the expected sequence', () {
    final frames = fibonacci(count: 10);
    expect(frames.last.values, [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]);
  });

  test('factorial computes the running product', () {
    final frames = factorial(6);
    expect(frames.last.values.last, 720);
    expect(frames.last.values, [1, 1, 2, 6, 24, 120, 720]);
  });

  group('tree traversals over a known BST', () {
    final values = [5, 3, 8, 1, 4, 7, 9];
    test('pre-order', () {
      expect(treeTraversal(values, 'pre').last.output, [5, 3, 1, 4, 8, 7, 9]);
    });
    test('post-order', () {
      expect(treeTraversal(values, 'post').last.output, [1, 4, 3, 7, 9, 8, 5]);
    });
    test('level-order', () {
      expect(treeTraversal(values, 'level').last.output, [5, 3, 8, 1, 4, 7, 9]);
    });
  });

  test('kadane finds the maximum subarray sum', () {
    final frames = kadane([-2, 1, -3, 4, -1, 2, 1, -5, 4]);
    // best subarray [4,-1,2,1] = 6
    final last = frames.last;
    expect(last.done.map((i) => last.values[i]).reduce((a, b) => a + b), 6);
  });

  test('floyd-warshall computes all-pairs shortest distances', () {
    final last = floydWarshall().last;
    // A→C goes A→B→C = 3+2 = 5; A→D = A→B→C→D = 6.
    expect(last.cells[0][2], 5);
    expect(last.cells[0][3], 6);
    // No self-distance exceeds 0.
    for (var i = 0; i < 4; i++) {
      expect(last.cells[i][i], 0);
    }
  });

  test('fractional knapsack fills greedily by ratio', () {
    final last = fractionalKnapsack().last;
    expect(last.caption, contains('total value'));
  });

  int mstWeight(GraphRun run) => run.edges
      .where((e) => run.frames.last.treeEdges.contains(e.key))
      .fold<int>(0, (s, e) => s + e.w);

  test("prim's builds a spanning tree of V-1 edges", () {
    final run = primDemo();
    final last = run.frames.last;
    expect(last.inTree.length, run.nodeLabels.length);
    expect(last.treeEdges.length, run.nodeLabels.length - 1);
    expect(mstWeight(run), 18);
  });

  test("kruskal's finds the same minimum spanning weight", () {
    final run = kruskalDemo();
    expect(run.frames.last.treeEdges.length, run.nodeLabels.length - 1);
    expect(mstWeight(run), 18);
  });

  test('topological sort orders every edge source before its target', () {
    final run = topologicalSort();
    final order = run.frames.last.order;
    expect(order.length, run.nodeLabels.length);
    final position = {for (var i = 0; i < order.length; i++) order[i]: i};
    for (final e in run.edges) {
      expect(position[e.a]!, lessThan(position[e.b]!),
          reason: 'edge ${e.a}->${e.b} must respect the order');
    }
  });

  test('matrix multiplication computes the product', () {
    final last = matrixMultiply().last;
    // [[1,2,3],[4,5,6]] × [[7,8],[9,10],[11,12]] = [[58,64],[139,154]].
    expect(last.c, [
      [58, 64],
      [139, 154],
    ]);
  });

  test('matrix addition adds element-wise', () {
    final last = matrixAdd().last;
    expect(last.c, [
      [7, 7, 7],
      [7, 7, 7],
    ]);
  });

  test('base conversion to binary is correct', () {
    final last = baseConversion(20, base: 2).last;
    expect(last.caption, contains('10100')); // 20 = 10100₂
  });

  group('new searches find an existing value', () {
    final a = [...expected];
    test('jump', () => expect(jumpSearch(a, 8).last.done, contains(a.indexOf(8))));
    test('ternary', () => expect(ternarySearch(a, 8).last.done, contains(a.indexOf(8))));
    test('exponential', () => expect(exponentialSearch(a, 8).last.done, contains(a.indexOf(8))));
  });

  test('lcs computes the correct length', () {
    // LCS of AGCAT and GAC is 2 (e.g. "GA" or "AC").
    final last = lcs('AGCAT', 'GAC').last;
    expect(last.cells[5][3], 2);
  });

  test('edit distance kitten→sitting is 3', () {
    final last = editDistance('kitten', 'sitting').last;
    expect(last.cells[6][7], 3);
  });

  test('coin change finds the fewest coins', () {
    // amount 8 with {1,3,4} → 4+4 = 2 coins.
    final last = coinChange([1, 3, 4], 8).last;
    expect(last.cells[0][8], 2);
  });

  test('graph colouring uses no edge with equal endpoints', () {
    final run = graphColoring();
    final colors = run.frames.last.colors;
    for (final e in run.edges) {
      expect(colors[e.a] == colors[e.b], isFalse);
    }
  });

  test('cycle detection reports the cycle', () {
    expect(cycleDetection().frames.last.caption, contains('cycle'));
  });

  group('string matching finds the pattern', () {
    test('naive', () {
      final last = naiveSearch('ABABACABAB', 'ABABA').last;
      expect(last.found, isNotEmpty);
    });
    test('kmp', () {
      final last = kmpSearch('ABABACABAB', 'ABABA').last;
      expect(last.found, isNotEmpty);
    });
  });

  test('euclidean gcd is correct', () {
    expect(gcd(48, 36).last.values.first, 12);
    expect(gcd(17, 5).last.values.first, 1);
  });

  test('bellman-ford computes stable shortest distances', () {
    final run = bellmanFord();
    final dist = run.frames.last.dist;
    expect(dist[0], 0);
    // No edge can still be relaxed (distances are final).
    for (final e in run.edges) {
      if (dist[e.a]! < (1 << 28)) {
        expect(dist[e.a]! + e.w >= dist[e.b]!, isTrue, reason: 'edge ${e.a}->${e.b} still relaxable');
      }
    }
  });

  group('extra string matchers find the pattern', () {
    test('boyer-moore', () => expect(boyerMoore('ABAAABCDABC', 'ABC').last.found, isNotEmpty));
    test('rabin-karp', () => expect(rabinKarp('ABABACABAB', 'ABABA').last.found, isNotEmpty));
  });

  test('binary heap keeps the max at the root', () {
    final last = binaryHeapDemo([4, 9, 2, 7, 11, 1, 8]).last;
    final rootValue = last.nodes.firstWhere((n) => n.id == 0).value;
    expect(last.nodes.every((n) => n.value <= rootValue), isTrue);
  });

  test('hash table places every key in an empty slot', () {
    final last = hashLinearProbing(keys: const [27, 18, 29, 28, 39], size: 11).last;
    final placed = last.slots.where((s) => s != -1).toList();
    expect(placed.length, 5);
    expect(placed.toSet().length, 5); // no key lost to a collision
  });

  test('stack is LIFO and queue is FIFO', () {
    expect(stackDemo().any((f) => f.caption.contains('pop')), isTrue);
    expect(queueDemo().any((f) => f.caption.contains('dequeue')), isTrue);
  });

  test('fibonacci search finds an existing value', () {
    final a = [...expected];
    expect(fibonacciSearch(a, 8).last.done, contains(a.indexOf(8)));
  });

  group('extra grid searches reach the goal', () {
    test('greedy best-first', () {
      final run = greedyBestFirstDemo(seed: 5);
      expect(run.frames.last.path.last, run.goal);
    });
    test('flood fill reaches many cells', () {
      final run = floodFillDemo(seed: 5);
      expect(run.frames.last.closed.length, greaterThan(10));
    });
  });

  test('longest increasing subsequence length is correct', () {
    // [10,9,2,5,3,7,101,18] → LIS length 4 (2,3,7,101).
    final last = longestIncreasingSubsequence([10, 9, 2, 5, 3, 7, 101, 18]).last;
    expect(last.done.length, 4);
  });

  test('subset sum detects a reachable target', () {
    expect(subsetSum([3, 4, 5, 2], 9).last.cells[4][9], 1);
    expect(subsetSum([3, 4, 5, 2], 1).last.cells[4][1], 0);
  });

  test('rod cutting maximises revenue', () {
    // Classic prices, length 8 → best revenue 22.
    final last = rodCutting([1, 5, 8, 9, 10, 17, 17, 20], 8).last;
    expect(last.cells[0][8], 22);
  });

  test('z-algorithm finds the pattern', () {
    expect(zSearch('ABABACABAB', 'ABABA').last.found, isNotEmpty);
  });

  test('newton sqrt converges', () {
    final last = newtonSqrt(81).last;
    expect((last.values.last - 9).abs() <= 1, isTrue);
  });

  test('extended euclid yields a correct bezout identity', () {
    expect(extendedEuclid(240, 46).last.values.first, 2); // gcd(240,46)=2
  });

  test('convex hull encloses with a valid polygon', () {
    final last = convexHull().last;
    expect(last.closed, isTrue);
    expect(last.hull.length, greaterThanOrEqualTo(3));
    expect(last.hull.toSet().length, last.hull.length); // no repeats
  });

  test('genetic algorithm evolves to the target', () {
    final frames = geneticAlgorithm(target: 'EVOLVE', seed: 7);
    final last = frames.last;
    // Fitness is monotonic non-decreasing thanks to elitism.
    var prev = 0;
    for (final f in frames) {
      expect(f.fitness[f.best] >= prev, isTrue);
      prev = f.fitness[f.best];
    }
    // It reaches the target.
    expect(last.population[last.best], 'EVOLVE');
    expect(last.fitness[last.best], 'EVOLVE'.length);
  });

  test('ant colony builds a valid tour and improves it', () {
    final frames = antColony(seed: 9);
    final last = frames.last;
    final n = last.cities.length;
    // Final tour visits every city exactly once.
    expect(last.tour.length, n);
    expect(last.tour.toSet().length, n);
    // Best length is finite and no worse than the first proper tour found.
    final firstWithTour = frames.firstWhere((f) => f.tour.isNotEmpty);
    expect(last.bestLength, isNotNull);
    expect(last.bestLength! <= firstWithTour.bestLength!, isTrue);
  });

  test('simulated annealing ends no worse than it started', () {
    final frames = simulatedAnnealing(seed: 4);
    final n = frames.first.cities.length;
    expect(frames.last.tour.length, n);
    expect(frames.last.tour.toSet().length, n);
    expect(frames.last.bestLength! <= frames.first.bestLength!, isTrue);
  });

  test('particle swarm converges toward the peak', () {
    final frames = particleSwarm(seed: 12);
    double gap(SwarmFrame f) {
      final dx = f.bestPos![0] - f.target[0];
      final dy = f.bestPos![1] - f.target[1];
      return dx * dx + dy * dy;
    }

    // Swarm best never moves away from the peak and ends very close to it.
    expect(gap(frames.last) <= gap(frames.first), isTrue);
    expect(gap(frames.last) < 0.01, isTrue);
  });

  test('hill climbing climbs toward the peak', () {
    final frames = hillClimbing(seed: 5);
    double fit(SwarmFrame f) {
      final dx = f.particles.first[0] - f.target[0];
      final dy = f.particles.first[1] - f.target[1];
      return -(dx * dx + dy * dy);
    }

    // Fitness is non-decreasing every step, and improves overall.
    var prev = fit(frames.first);
    for (final f in frames) {
      expect(fit(f) >= prev - 1e-9, isTrue);
      prev = fit(f);
    }
    expect(fit(frames.last) > fit(frames.first), isTrue);
  });

  double swarmGap(SwarmFrame f) {
    final dx = f.bestPos![0] - f.target[0];
    final dy = f.bestPos![1] - f.target[1];
    return dx * dx + dy * dy;
  }

  test('artificial bee colony homes in on the peak', () {
    final frames = artificialBeeColony(seed: 21);
    expect(swarmGap(frames.last) <= swarmGap(frames.first), isTrue);
    expect(swarmGap(frames.last) < 0.02, isTrue);
  });

  test('firefly algorithm gathers at the peak', () {
    final frames = firefly(seed: 31);
    expect(swarmGap(frames.last) <= swarmGap(frames.first), isTrue);
    expect(swarmGap(frames.last) < 0.02, isTrue);
  });

  test('cuckoo search converges on the peak', () {
    final frames = cuckooSearch(seed: 41);
    expect(swarmGap(frames.last) <= swarmGap(frames.first), isTrue);
    expect(swarmGap(frames.last) < 0.02, isTrue);
  });

  test('singly linked list ends without the deleted value', () {
    final last = singlyLinkedList().last;
    final values = [for (final n in last.nodes) n.value];
    expect(values.contains(20), isFalse);
    expect(values.first, 5); // inserted at head
  });

  test('doubly linked list is bidirectional and drops the removed node', () {
    final last = doublyLinkedList().last;
    expect(last.doubly, isTrue);
    expect([for (final n in last.nodes) n.value].contains(20), isFalse);
  });

  test('circular linked list keeps every inserted node', () {
    final last = circularLinkedList().last;
    expect(last.circular, isTrue);
    expect([for (final n in last.nodes) n.value], [1, 2, 3, 4]);
  });

  test('deque pushes and pops from both ends', () {
    final last = dequeDemo().last;
    expect(last.values, isNotEmpty);
  });

  test('priority queue keeps the minimum at the root', () {
    final frames = priorityQueue();
    // After the inserts (before extraction) the root is the global minimum.
    final built = frames.lastWhere((f) => f.nodes.length == 6);
    final root = built.nodes.firstWhere((n) => n.id == 0);
    final allValues = [for (final n in built.nodes) n.value];
    expect(root.value, allValues.reduce((a, b) => a < b ? a : b));
  });

  test('trie stores the inserted words as word-ending nodes', () {
    final last = trieDemo().last;
    // 'cat', 'car', 'card', 'dog' → 4 word-ending nodes.
    expect(last.nodes.where((n) => n.isWord).length, 4);
  });

  test('union-find merges everything into one set', () {
    final run = unionFind();
    // After all unions the final forest has exactly one root (n-1 parent links).
    final last = run.frames.last;
    expect(last.treeEdges.length, run.nodeLabels.length - 1);
  });

  test('avl tree stays balanced (height <= 3 for 6 nodes)', () {
    final frames = avlTree();
    final last = frames.last;
    expect(last.nodes.length, 6);
    // A balanced tree of 6 nodes has height 3 (4 would mean it degenerated).
    final byId = {for (final n in last.nodes) n.id: n};
    int depth(int? id) => id == null || !byId.containsKey(id)
        ? 0
        : 1 + (depth(byId[id]!.left) > depth(byId[id]!.right) ? depth(byId[id]!.left) : depth(byId[id]!.right));
    expect(depth(last.rootId) <= 3, isTrue);
  });

  test('segment tree root holds the total sum', () {
    final last = segmentTree().last;
    final root = last.nodes.firstWhere((n) => n.id == 0);
    expect(root.value, 2 + 1 + 5 + 3 + 4 + 6);
  });

  test('lru cache evicts the least-recently-used key', () {
    final last = lruCache().last;
    // Access pattern 1,2,3,1,4,2 with capacity 3 → final {4,1,2} were kept; 3 evicted.
    expect(last.values.contains(3), isFalse);
    expect(last.values.length, 3);
  });

  test('stooge sort sorts the array', () {
    final last = stoogeSort([5, 2, 9, 1, 7, 3, 8]).last;
    final sorted = [5, 2, 9, 1, 7, 3, 8]..sort();
    expect(last.values, sorted);
  });

  test('binary exponentiation computes the power', () {
    expect(binaryExponentiation(3, 13).last.values.last, 1594323); // 3^13
    expect(binaryExponentiation(2, 10).last.values.last, 1024);
  });

  test('fenwick tree slots cover their power-of-two ranges', () {
    const data = [3, 2, 5, 1, 4, 6];
    final last = fenwickTree(data).last;
    // Slot 4 (1-indexed) covers the first four elements.
    expect(last.values[3], data[0] + data[1] + data[2] + data[3]);
    // Slot 2 covers the first two.
    expect(last.values[1], data[0] + data[1]);
  });

  test('in-order traversal yields sorted values', () {
    final frames = treeTraversal([50, 30, 70, 20, 40, 60, 80], 'in');
    expect(frames.last.output, [20, 30, 40, 50, 60, 70, 80]);
  });

  test('horspool finds the pattern', () {
    final last = horspool().last;
    expect(last.found, isNotEmpty); // 'TOOTH' occurs in the default text
  });

  test('closest pair identifies the nearest two points', () {
    final last = closestPair().last;
    expect(last.hull.length, 2);
    expect(last.hull.toSet(), {3, 4}); // the two adjacent middle points
  });

  test('graham scan builds a valid closed hull', () {
    final last = grahamScan().last;
    expect(last.closed, isTrue);
    expect(last.hull.length, greaterThanOrEqualTo(3));
    expect(last.hull.toSet().length, last.hull.length);
  });
  test('point in polygon detects the inside point', () {
    expect(pointInPolygon().last.caption, contains('inside'));
  });

  // ---- Arrays ----
  test('array insertion grows the array by one', () {
    final last = arrayInsertion([1, 2, 3, 4, 5], at: 2, value: 42).last;
    expect(last.values.length, 6);
    expect(last.values[2], 42);
  });
  test('array deletion shrinks the array by one', () {
    final last = arrayDeletion([1, 2, 3, 4, 5], at: 2).last;
    expect(last.values, [1, 2, 4, 5]);
  });
  test('contiguous subarray finds the max-sum block', () {
    final last = contiguousSubarray([-2, 1, -3, 4, -1, 2, 1, -5, 4]).last;
    // best is [4,-1,2,1] = 6 over indices 3..6
    expect(last.windowLo, 3);
    expect(last.windowHi, 6);
  });
  test('non-contiguous subarray takes the positives', () {
    final last = nonContiguousSubarray([3, -1, 4, -2, 5]).last;
    expect(last.done, {0, 2, 4});
  });

  test('bitonic sort sorts a power-of-two array', () {
    final last = bitonicSort([8, 3, 5, 1, 7, 2, 6, 4]).last;
    expect(last.values, [1, 2, 3, 4, 5, 6, 7, 8]);
  });
  test('prime factorization multiplies back to n', () {
    final last = primeFactorization(360).last;
    expect(last.values.reduce((a, b) => a * b), 360);
  });
  test('list middle finds the centre node', () {
    final last = listMiddle().last;
    final id = last.nodes.indexWhere((n) => n.highlight);
    expect(last.nodes[id].value, 40); // middle of 10..70
  });
  test('monotonic stack stays increasing', () {
    final last = monotonicStack([3, 1, 4, 1, 5, 9, 2, 6]).last;
    for (var i = 1; i < last.values.length; i++) {
      expect(last.values[i] >= last.values[i - 1], isTrue);
    }
  });

  test('bst sort produces a sorted array', () {
    final last = bstSort([5, 2, 9, 1, 7, 3]).last;
    expect(last.values, [1, 2, 3, 5, 7, 9]);
  });
  test('lcm matches a·b / gcd', () {
    expect(lcm(12, 18).last.caption, contains('36'));
  });
  test('jagged linked list ends with the row sum', () {
    final last = jaggedLinkedList().last;
    expect([for (final n in last.nodes) n.value], [5, 6, 7]); // 2+3, 5+1, 1+6
  });
  test('doubly linked stack keeps the top at the head', () {
    final last = doublyLinkedStack().last;
    expect(last.doubly, isTrue);
    expect(last.nodes.first.value, 9); // last pushed
  });

  test('array reversal reverses the array', () {
    final last = arrayReversal([1, 2, 3, 4, 5]).last;
    expect(last.values, [5, 4, 3, 2, 1]);
  });

  // ---- Lists ----
  test('list sorted insert keeps order', () {
    final last = listSortedInsert(value: 25).last;
    final vals = [for (final n in last.nodes) n.value];
    expect(vals, [10, 20, 25, 30, 40]);
  });
  test('list reverse flips the order', () {
    final last = listReverse().last;
    expect([for (final n in last.nodes) n.value], [40, 30, 20, 10]);
  });
  test('list merge interleaves two sorted lists', () {
    final last = listMerge().last;
    expect([for (final n in last.nodes) n.value], [10, 20, 30, 40, 50, 60]);
  });

  // ---- Data types ----
  test('palindrome check accepts a palindrome', () {
    expect(palindromeCheck(text: 'racecar').last.matched.length, 'racecar'.length);
  });
  test('vowel count tallies vowels', () {
    final last = vowelCount(text: 'algorithm').last;
    expect(last.matched.length, 3); // a, o, i
  });

  // ---- Matrices ----
  test('matrix subtraction is element-wise', () {
    final last = matrixSubtract().last;
    expect(last.c[0][0], 9 - 1);
  });
  test('determinant matches the known value', () {
    expect(determinant().last.caption, contains('-306'));
  });
  test('matrix transpose swaps rows and columns', () {
    final last = matrixTranspose().last;
    // Original row 0 was [1,2,3]; after transpose column 0 is [1,2,3].
    expect([last.cells[0][0], last.cells[1][0], last.cells[2][0]], [1, 2, 3]);
  });
  test('matrix inversion clears to identity on the left', () {
    final last = matrixInversion().last;
    // Left 3×3 block is the identity.
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        expect(last.cells[i][j], i == j ? 1 : 0);
      }
    }
  });

  // ---- Trees & heaps ----
  test('bst minimum reaches the smallest value', () {
    final last = bstSmallest([50, 30, 70, 20, 40, 10]).last;
    final id = last.highlight.first;
    final node = last.nodes.firstWhere((n) => n.id == id);
    expect(node.value, 10);
  });
  test('bst deletion removes the value', () {
    final last = bstDelete([50, 30, 70, 20, 40], 30).last;
    expect([for (final n in last.nodes) n.value].contains(30), isFalse);
  });
  test('kary heap keeps the minimum at the root', () {
    final last = karyHeap().last;
    final root = last.nodes.firstWhere((n) => n.id == 0);
    final all = [for (final n in last.nodes) int.tryParse(n.label) ?? 1 << 30];
    expect(int.parse(root.label), all.reduce((a, b) => a < b ? a : b));
  });
  test('red-black tree keeps a black root', () {
    final last = redBlackTree().last;
    expect(last.nodes.firstWhere((n) => n.id == 0).state, GNodeState.black);
  });

  // ---- Hash variants ----
  test('separate chaining places every key in a bucket', () {
    final last = hashSeparateChaining(keys: const [15, 11, 27, 8, 22], size: 7).last;
    final total = last.buckets.fold<int>(0, (s, b) => s + b.length);
    expect(total, 5);
  });

  // ---- AI ----
  test('minimax computes the optimal root value', () {
    expect(minimax().last.caption, contains('3'));
  });
  test('alpha-beta agrees with minimax', () {
    expect(alphaBeta().last.caption, contains('3'));
  });
}
