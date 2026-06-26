import 'dart:math';

import '../models/frames.dart';

/// A genetic algorithm that evolves a random population of strings toward a
/// [target] phrase: fitness counts matching characters, then tournament
/// selection, single-point crossover, and mutation breed each new generation.
/// Elitism keeps the best candidate, so fitness never regresses.
List<GeneticFrame> geneticAlgorithm({String target = 'EVOLVE', int seed = 7}) {
  final rng = Random(seed);
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ ';
  final l = target.length;
  const popSize = 16;
  const mutationRate = 0.08;
  const maxGenerations = 400;

  String randomIndividual() =>
      String.fromCharCodes([for (var i = 0; i < l; i++) chars.codeUnitAt(rng.nextInt(chars.length))]);

  int fitnessOf(String s) {
    var f = 0;
    for (var i = 0; i < l; i++) {
      if (s[i] == target[i]) f++;
    }
    return f;
  }

  String mutate(String s) {
    final units = s.codeUnits.toList();
    for (var i = 0; i < l; i++) {
      if (rng.nextDouble() < mutationRate) units[i] = chars.codeUnitAt(rng.nextInt(chars.length));
    }
    return String.fromCharCodes(units);
  }

  String crossover(String a, String b) {
    final cut = rng.nextInt(l);
    return a.substring(0, cut) + b.substring(cut);
  }

  var population = [for (var i = 0; i < popSize; i++) randomIndividual()];
  final frames = <GeneticFrame>[];

  GeneticFrame buildFrame(int gen) {
    final fitness = [for (final ind in population) fitnessOf(ind)];
    var best = 0;
    for (var i = 1; i < population.length; i++) {
      if (fitness[i] > fitness[best]) best = i;
    }
    final caption = fitness[best] == l
        ? 'Generation $gen — solved! "${population[best]}".'
        : 'Generation $gen — fittest "${population[best]}" matches ${fitness[best]}/$l.';
    return GeneticFrame(
      target: target,
      population: [...population],
      fitness: fitness,
      best: best,
      generation: gen,
      caption: caption,
    );
  }

  var gen = 0;
  frames.add(buildFrame(gen));

  while (gen < maxGenerations) {
    final fitness = [for (final ind in population) fitnessOf(ind)];
    var best = 0;
    for (var i = 1; i < popSize; i++) {
      if (fitness[i] > fitness[best]) best = i;
    }
    if (fitness[best] == l) break;

    String tournament() {
      final a = rng.nextInt(popSize), b = rng.nextInt(popSize);
      return fitness[a] >= fitness[b] ? population[a] : population[b];
    }

    final next = <String>[population[best]]; // elitism
    while (next.length < popSize) {
      next.add(mutate(crossover(tournament(), tournament())));
    }
    population = next;
    gen++;
    frames.add(buildFrame(gen));
  }

  return frames;
}

// A fixed ring-ish scatter of "cities" (normalized 0..1) shared by the tour
// optimisers so their visualizations stay comparable.
const _cities = <List<double>>[
  [0.20, 0.25],
  [0.50, 0.15],
  [0.80, 0.22],
  [0.88, 0.55],
  [0.72, 0.82],
  [0.42, 0.88],
  [0.15, 0.70],
  [0.32, 0.50],
  [0.62, 0.45],
  [0.55, 0.68],
];

double _dist(List<List<double>> cs, int i, int j) {
  final dx = cs[i][0] - cs[j][0];
  final dy = cs[i][1] - cs[j][1];
  return sqrt(dx * dx + dy * dy);
}

double _tourLength(List<List<double>> cs, List<int> tour) {
  var s = 0.0;
  for (var k = 0; k < tour.length; k++) {
    s += _dist(cs, tour[k], tour[(k + 1) % tour.length]);
  }
  return s;
}

List<List<double>> _copyMatrix(List<List<double>> m) => [for (final row in m) [...row]];

/// Ant Colony Optimization on a small travelling-salesman instance ("ant farm
/// colony"). Each iteration a swarm of ants builds tours, biased toward edges
/// with more pheromone and shorter length; pheromone then evaporates and is
/// reinforced along the tours the ants took. Good edges accumulate scent, so the
/// colony collectively converges on a short tour.
List<TspFrame> antColony({int seed = 9}) {
  final rng = Random(seed);
  final cities = _cities;
  final n = cities.length;
  const ants = 14;
  const iterations = 24;
  const alpha = 1.0; // pheromone influence
  const beta = 4.0; // distance influence
  const evaporation = 0.45;
  const q = 2.0; // pheromone deposited per tour

  var pheromone = [for (var i = 0; i < n; i++) List<double>.filled(n, 1.0)];

  List<int>? bestTour;
  var bestLen = double.infinity;

  final frames = <TspFrame>[
    TspFrame(
      cities: cities,
      pheromone: _copyMatrix(pheromone),
      caption: 'Ants wander the cities; pheromone (faint lines) marks the trails they reinforce.',
    ),
  ];

  for (var it = 0; it < iterations; it++) {
    final deposit = [for (var i = 0; i < n; i++) List<double>.filled(n, 0.0)];

    for (var a = 0; a < ants; a++) {
      final visited = <bool>[for (var i = 0; i < n; i++) false];
      var current = rng.nextInt(n);
      visited[current] = true;
      final tour = <int>[current];

      while (tour.length < n) {
        var total = 0.0;
        final weight = List<double>.filled(n, 0.0);
        for (var j = 0; j < n; j++) {
          if (!visited[j]) {
            final w = pow(pheromone[current][j], alpha) * pow(1.0 / _dist(cities, current, j), beta);
            weight[j] = w.toDouble();
            total += weight[j];
          }
        }
        var pick = rng.nextDouble() * total;
        var next = -1;
        for (var j = 0; j < n; j++) {
          if (!visited[j]) {
            pick -= weight[j];
            if (pick <= 0) {
              next = j;
              break;
            }
            next = j; // fallback to the last eligible city
          }
        }
        visited[next] = true;
        tour.add(next);
        current = next;
      }

      final len = _tourLength(cities, tour);
      if (len < bestLen) {
        bestLen = len;
        bestTour = [...tour];
      }
      for (var k = 0; k < n; k++) {
        final i = tour[k], j = tour[(k + 1) % n];
        deposit[i][j] += q / len;
        deposit[j][i] += q / len;
      }
    }

    pheromone = [
      for (var i = 0; i < n; i++)
        [for (var j = 0; j < n; j++) pheromone[i][j] * (1 - evaporation) + deposit[i][j]]
    ];

    frames.add(TspFrame(
      cities: cities,
      pheromone: _copyMatrix(pheromone),
      tour: [...?bestTour],
      bestLength: bestLen,
      caption: 'Iteration ${it + 1}: shortest tour so far is ${bestLen.toStringAsFixed(2)}.',
    ));
  }

  frames.add(TspFrame(
    cities: cities,
    pheromone: _copyMatrix(pheromone),
    tour: [...?bestTour],
    bestLength: bestLen,
    caption: 'The colony converged on a tour of length ${bestLen.toStringAsFixed(2)}.',
  ));
  return frames;
}

/// Simulated annealing on the same travelling-salesman instance. It starts from
/// a random tour and proposes 2-opt segment reversals; an improving move is
/// always taken, while a worsening move is accepted with probability
/// exp(-Δ/T). The "temperature" T cools geometrically, so the search explores
/// wildly when hot and settles into a local optimum as it freezes.
List<TspFrame> simulatedAnnealing({int seed = 4}) {
  final rng = Random(seed);
  final cities = _cities;
  final n = cities.length;

  var current = [for (var i = 0; i < n; i++) i]..shuffle(rng);
  var currentLen = _tourLength(cities, current);
  var best = [...current];
  var bestLen = currentLen;

  var t = 1.0;
  const cooling = 0.96;
  const steps = 160;

  final frames = <TspFrame>[
    TspFrame(
      cities: cities,
      tour: [...current],
      bestLength: currentLen,
      caption: 'Start from a random tour (length ${currentLen.toStringAsFixed(2)}); accept worse moves while hot.',
    ),
  ];

  for (var s = 0; s < steps; s++) {
    var i = rng.nextInt(n);
    var j = rng.nextInt(n);
    if (i == j) {
      t *= cooling;
      continue;
    }
    if (i > j) {
      final tmp = i;
      i = j;
      j = tmp;
    }
    final cand = [...current];
    var lo = i, hi = j;
    while (lo < hi) {
      final tmp = cand[lo];
      cand[lo] = cand[hi];
      cand[hi] = tmp;
      lo++;
      hi--;
    }
    final candLen = _tourLength(cities, cand);
    final delta = candLen - currentLen;
    if (delta < 0 || rng.nextDouble() < exp(-delta / t)) {
      current = cand;
      currentLen = candLen;
      if (currentLen < bestLen) {
        bestLen = currentLen;
        best = [...current];
      }
    }
    t *= cooling;

    if (s % 4 == 0) {
      frames.add(TspFrame(
        cities: cities,
        tour: [...current],
        bestLength: bestLen,
        caption: 'T=${t.toStringAsFixed(3)} — current ${currentLen.toStringAsFixed(2)}, best ${bestLen.toStringAsFixed(2)}.',
      ));
    }
  }

  frames.add(TspFrame(
    cities: cities,
    tour: [...best],
    bestLength: bestLen,
    caption: 'Cooled to a tour of length ${bestLen.toStringAsFixed(2)}.',
  ));
  return frames;
}

// The optimum of the swarm landscape: fitness is highest at this peak.
const _peak = <double>[0.72, 0.32];

double _swarmFitness(double x, double y) {
  final dx = x - _peak[0];
  final dy = y - _peak[1];
  return -(dx * dx + dy * dy); // maximised (→ 0) at the peak
}

/// Particle Swarm Optimization over a 2-D fitness landscape with a single peak.
/// Each particle remembers its own best spot and is pulled toward both it and
/// the swarm's global best, with inertia carrying its velocity forward. The
/// flock drifts, spreads, and then converges on the optimum.
List<SwarmFrame> particleSwarm({int seed = 12}) {
  final rng = Random(seed);
  const n = 18;
  const iterations = 36;
  const w = 0.6; // inertia
  const c1 = 1.4; // cognitive (personal best) pull
  const c2 = 1.4; // social (global best) pull

  final pos = [for (var i = 0; i < n; i++) [rng.nextDouble(), rng.nextDouble()]];
  final vel = [for (var i = 0; i < n; i++) [(rng.nextDouble() - 0.5) * 0.1, (rng.nextDouble() - 0.5) * 0.1]];
  final pbest = [for (final p in pos) [...p]];
  final pbestFit = [for (final p in pos) _swarmFitness(p[0], p[1])];

  var gbest = [...pos[0]];
  var gbestFit = pbestFit[0];
  for (var i = 1; i < n; i++) {
    if (pbestFit[i] > gbestFit) {
      gbestFit = pbestFit[i];
      gbest = [...pos[i]];
    }
  }

  final frames = <SwarmFrame>[
    SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: [...gbest],
      caption: 'A swarm of particles scatters across the landscape, hunting for the peak.',
    ),
  ];

  for (var it = 0; it < iterations; it++) {
    for (var i = 0; i < n; i++) {
      for (var d = 0; d < 2; d++) {
        final r1 = rng.nextDouble(), r2 = rng.nextDouble();
        vel[i][d] = w * vel[i][d] + c1 * r1 * (pbest[i][d] - pos[i][d]) + c2 * r2 * (gbest[d] - pos[i][d]);
        pos[i][d] = (pos[i][d] + vel[i][d]).clamp(0.0, 1.0).toDouble();
      }
      final f = _swarmFitness(pos[i][0], pos[i][1]);
      if (f > pbestFit[i]) {
        pbestFit[i] = f;
        pbest[i] = [...pos[i]];
        if (f > gbestFit) {
          gbestFit = f;
          gbest = [...pos[i]];
        }
      }
    }
    frames.add(SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: [...gbest],
      caption: 'Iteration ${it + 1}: the swarm best sits ${sqrt(-gbestFit).toStringAsFixed(3)} from the peak.',
    ));
  }

  frames.add(SwarmFrame(
    particles: _copyMatrix(pos),
    target: _peak,
    bestPos: [...gbest],
    caption: 'The swarm has converged on the peak.',
  ));
  return frames;
}

/// Hill climbing: a single searcher that always steps to the best uphill
/// neighbour and stops when no neighbour is higher. On this single-peak
/// landscape it marches straight to the optimum; on a bumpy one it would get
/// stuck in the nearest local maximum.
List<SwarmFrame> hillClimbing({int seed = 5}) {
  final rng = Random(seed);
  var x = rng.nextDouble();
  var y = rng.nextDouble();
  const step = 0.045;

  final frames = <SwarmFrame>[
    SwarmFrame(
      particles: [[x, y]],
      target: _peak,
      bestPos: [x, y],
      caption: 'Drop the climber somewhere random — it will only ever step uphill.',
    ),
  ];

  for (var s = 0; s < 80; s++) {
    var bx = x, by = y;
    var bf = _swarmFitness(x, y);
    var moved = false;
    for (final d in const [
      [step, 0.0],
      [-step, 0.0],
      [0.0, step],
      [0.0, -step],
    ]) {
      final nx = (x + d[0]).clamp(0.0, 1.0).toDouble();
      final ny = (y + d[1]).clamp(0.0, 1.0).toDouble();
      final f = _swarmFitness(nx, ny);
      if (f > bf) {
        bf = f;
        bx = nx;
        by = ny;
        moved = true;
      }
    }
    if (!moved) {
      frames.add(SwarmFrame(
        particles: [[x, y]],
        target: _peak,
        bestPos: [x, y],
        caption: 'No higher neighbour — a local optimum has been reached.',
      ));
      return frames;
    }
    x = bx;
    y = by;
    frames.add(SwarmFrame(
      particles: [[x, y]],
      target: _peak,
      bestPos: [x, y],
      caption: 'Step ${s + 1}: climb to the highest neighbouring point.',
    ));
  }

  frames.add(SwarmFrame(
    particles: [[x, y]],
    target: _peak,
    bestPos: [x, y],
    caption: 'Hill climbing finished near the peak.',
  ));
  return frames;
}

double _clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

// A standard normal sample via the Box–Muller transform.
double _gauss(Random rng) {
  final u1 = rng.nextDouble().clamp(1e-9, 1.0);
  final u2 = rng.nextDouble();
  return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}

List<double> _bestOf(List<List<double>> pos, List<double> fit) {
  var bi = 0;
  for (var i = 1; i < fit.length; i++) {
    if (fit[i] > fit[bi]) bi = i;
  }
  return [...pos[bi]];
}

/// Artificial Bee Colony: food sources (candidate solutions) are improved by
/// three kinds of bee. Employed bees tweak their own source; onlooker bees
/// crowd toward the richer sources (chosen by a fitness-weighted roulette);
/// and a scout abandons any source that stops improving, replacing it with a
/// fresh random one. The colony steadily uncovers the peak.
List<SwarmFrame> artificialBeeColony({int seed = 21}) {
  final rng = Random(seed);
  const n = 16;
  const iterations = 38;
  const limit = 8;

  final pos = [for (var i = 0; i < n; i++) [rng.nextDouble(), rng.nextDouble()]];
  final fit = [for (final p in pos) _swarmFitness(p[0], p[1])];
  final trials = List<int>.filled(n, 0);

  // ABC's positive fitness transform (raw fitness here is ≤ 0).
  double value(double f) => f >= 0 ? 1 + f : 1 / (1 - f);

  List<double> neighbour(int i) {
    var k = rng.nextInt(n);
    while (k == i) {
      k = rng.nextInt(n);
    }
    final d = rng.nextInt(2);
    final phi = rng.nextDouble() * 2 - 1;
    final cand = [...pos[i]];
    cand[d] = _clamp01(pos[i][d] + phi * (pos[i][d] - pos[k][d]));
    return cand;
  }

  void tryAt(int i) {
    final cand = neighbour(i);
    final cf = _swarmFitness(cand[0], cand[1]);
    if (cf > fit[i]) {
      pos[i] = cand;
      fit[i] = cf;
      trials[i] = 0;
    } else {
      trials[i]++;
    }
  }

  final frames = <SwarmFrame>[
    SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: _bestOf(pos, fit),
      caption: 'Scout out random food sources; bees will refine the richest ones.',
    ),
  ];

  for (var it = 0; it < iterations; it++) {
    // Employed bees.
    for (var i = 0; i < n; i++) {
      tryAt(i);
    }
    // Onlooker bees: roulette selection by transformed fitness.
    var total = 0.0;
    final vals = [for (final f in fit) value(f)];
    for (final v in vals) {
      total += v;
    }
    for (var o = 0; o < n; o++) {
      var pick = rng.nextDouble() * total;
      var i = 0;
      for (var j = 0; j < n; j++) {
        pick -= vals[j];
        if (pick <= 0) {
          i = j;
          break;
        }
        i = j;
      }
      tryAt(i);
    }
    // Scout bee: abandon the most-exhausted source if it is past the limit.
    for (var i = 0; i < n; i++) {
      if (trials[i] > limit) {
        pos[i] = [rng.nextDouble(), rng.nextDouble()];
        fit[i] = _swarmFitness(pos[i][0], pos[i][1]);
        trials[i] = 0;
      }
    }
    final best = _bestOf(pos, fit);
    frames.add(SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: best,
      caption: 'Cycle ${it + 1}: bees cluster on the richest source so far.',
    ));
  }

  frames.add(SwarmFrame(
    particles: _copyMatrix(pos),
    target: _peak,
    bestPos: _bestOf(pos, fit),
    caption: 'The bee colony settled on the richest food source.',
  ));
  return frames;
}

/// Firefly Algorithm: every firefly glows in proportion to its fitness and is
/// drawn toward brighter neighbours, with attractiveness fading over distance
/// (β = β₀·e^(−γr²)) plus a shrinking random jitter. Brighter fireflies pull the
/// swarm together until the whole flight gathers at the brightest point.
List<SwarmFrame> firefly({int seed = 31}) {
  final rng = Random(seed);
  const n = 16;
  const iterations = 38;
  const beta0 = 1.0;
  const gamma = 6.0;
  var alpha = 0.22; // random-walk scale, annealed each step

  final pos = [for (var i = 0; i < n; i++) [rng.nextDouble(), rng.nextDouble()]];

  double brightness(List<double> p) => _swarmFitness(p[0], p[1]);

  final frames = <SwarmFrame>[
    SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: _bestOf(pos, [for (final p in pos) brightness(p)]),
      caption: 'Fireflies glow by fitness; dimmer ones drift toward brighter ones.',
    ),
  ];

  for (var it = 0; it < iterations; it++) {
    final bright = [for (final p in pos) brightness(p)];
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if (bright[j] > bright[i]) {
          final dx = pos[i][0] - pos[j][0];
          final dy = pos[i][1] - pos[j][1];
          final r2 = dx * dx + dy * dy;
          final beta = beta0 * exp(-gamma * r2);
          for (var d = 0; d < 2; d++) {
            pos[i][d] = _clamp01(
              pos[i][d] + beta * (pos[j][d] - pos[i][d]) + alpha * (rng.nextDouble() - 0.5),
            );
          }
        }
      }
    }
    alpha *= 0.96;
    final best = _bestOf(pos, [for (final p in pos) brightness(p)]);
    frames.add(SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: best,
      caption: 'Flight ${it + 1}: fireflies gather toward the brightest glow.',
    ));
  }

  frames.add(SwarmFrame(
    particles: _copyMatrix(pos),
    target: _peak,
    bestPos: _bestOf(pos, [for (final p in pos) brightness(p)]),
    caption: 'The swarm has assembled at the brightest point.',
  ));
  return frames;
}

/// Cuckoo Search: each cuckoo lays an egg (a new solution) by taking a
/// heavy-tailed Lévy flight from an existing nest. If the egg is better than a
/// randomly chosen nest, it takes over. After each round a fraction of the worst
/// nests are abandoned and rebuilt at random — keeping exploration alive while
/// the best nests survive toward the optimum.
List<SwarmFrame> cuckooSearch({int seed = 41}) {
  final rng = Random(seed);
  const n = 15;
  const iterations = 40;
  const pa = 0.25; // fraction of nests abandoned each round
  const beta = 1.5;
  const sigma = 0.6966; // Mantegna constant for β = 1.5

  double levy() {
    final u = _gauss(rng) * sigma;
    final v = _gauss(rng);
    return u / pow(v.abs() + 1e-12, 1 / beta);
  }

  final pos = [for (var i = 0; i < n; i++) [rng.nextDouble(), rng.nextDouble()]];
  final fit = [for (final p in pos) _swarmFitness(p[0], p[1])];

  final frames = <SwarmFrame>[
    SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: _bestOf(pos, fit),
      caption: 'Each nest holds a solution; cuckoos drop better eggs via Lévy flights.',
    ),
  ];

  for (var it = 0; it < iterations; it++) {
    final best = _bestOf(pos, fit);
    // Lay a cuckoo egg from each nest and try to displace a random nest.
    for (var i = 0; i < n; i++) {
      final cand = [
        for (var d = 0; d < 2; d++) _clamp01(pos[i][d] + 0.04 * levy() * (pos[i][d] - best[d]))
      ];
      final cf = _swarmFitness(cand[0], cand[1]);
      final j = rng.nextInt(n);
      if (cf > fit[j]) {
        pos[j] = cand;
        fit[j] = cf;
      }
    }
    // Abandon the worst pa-fraction of nests, rebuilding them at random.
    final order = [for (var i = 0; i < n; i++) i]..sort((a, b) => fit[a].compareTo(fit[b]));
    final abandon = (n * pa).round();
    for (var k = 0; k < abandon; k++) {
      final i = order[k];
      pos[i] = [rng.nextDouble(), rng.nextDouble()];
      fit[i] = _swarmFitness(pos[i][0], pos[i][1]);
    }
    frames.add(SwarmFrame(
      particles: _copyMatrix(pos),
      target: _peak,
      bestPos: _bestOf(pos, fit),
      caption: 'Round ${it + 1}: better eggs survive; the worst nests are abandoned.',
    ));
  }

  frames.add(SwarmFrame(
    particles: _copyMatrix(pos),
    target: _peak,
    bestPos: _bestOf(pos, fit),
    caption: 'The best nests converged on the optimum.',
  ));
  return frames;
}
