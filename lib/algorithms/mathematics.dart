import '../models/frames.dart';

/// Sieve of Eratosthenes — repeatedly takes the next unmarked number as a prime
/// and strikes out all of its multiples.
List<NumberGridFrame> sieve({int maxN = 50}) {
  final isComposite = List<bool>.filled(maxN + 1, false);
  final marked = <int>{};
  final primes = <int>{};
  final frames = <NumberGridFrame>[
    NumberGridFrame(maxN: maxN, caption: 'Sieve the numbers 2..$maxN for primes.'),
  ];

  for (var p = 2; p * p <= maxN; p++) {
    if (isComposite[p]) continue;
    primes.add(p);
    frames.add(NumberGridFrame(
      maxN: maxN,
      current: p,
      multiplesOf: p,
      marked: {...marked},
      primes: {...primes},
      caption: '$p is prime — strike out its multiples starting at ${p * p}.',
    ));
    for (var m = p * p; m <= maxN; m += p) {
      if (!isComposite[m]) {
        isComposite[m] = true;
        marked.add(m);
      }
      frames.add(NumberGridFrame(
        maxN: maxN,
        current: m,
        multiplesOf: p,
        marked: {...marked},
        primes: {...primes},
        caption: '$m = $p × ${m ~/ p} is composite.',
      ));
    }
  }
  for (var k = 2; k <= maxN; k++) {
    if (!isComposite[k]) primes.add(k);
  }
  frames.add(NumberGridFrame(
    maxN: maxN,
    marked: {...marked},
    primes: {...primes},
    caption: 'Done — ${primes.length} primes up to $maxN; the rest are composite.',
  ));
  return frames;
}

/// Pascal's triangle — each interior entry is the sum of the two entries above
/// it, built one cell at a time.
List<PascalFrame> pascalsTriangle({int numRows = 8}) {
  final rows = <List<int>>[];
  final frames = <PascalFrame>[];

  List<List<int>> copy() => [for (final r in rows) [...r]];

  for (var r = 0; r < numRows; r++) {
    rows.add(List<int>.filled(r + 1, -1));
    for (var c = 0; c <= r; c++) {
      if (c == 0 || c == r) {
        rows[r][c] = 1;
        frames.add(PascalFrame(
          rows: copy(),
          highlightRow: r,
          highlightCol: c,
          caption: 'The edges of every row are 1.',
        ));
      } else {
        final a = rows[r - 1][c - 1];
        final b = rows[r - 1][c];
        rows[r][c] = a + b;
        frames.add(PascalFrame(
          rows: copy(),
          highlightRow: r,
          highlightCol: c,
          addends: [
            [r - 1, c - 1],
            [r - 1, c],
          ],
          caption: '$a + $b = ${a + b} — the sum of the two cells above.',
        ));
      }
    }
  }
  frames.add(PascalFrame(rows: copy(), caption: 'Pascal’s triangle with $numRows rows.'));
  return frames;
}

/// Collatz conjecture — repeatedly halve even numbers and apply 3n+1 to odd
/// numbers; the sequence is conjectured to always reach 1.
List<ArrayFrame> collatz(int start) {
  final seq = <int>[start];
  final frames = <ArrayFrame>[
    ArrayFrame(values: [...seq], active: {0}, caption: 'Start the sequence at $start.'),
  ];
  var x = start;
  var steps = 0;
  while (x != 1) {
    final prev = x;
    x = x.isEven ? x ~/ 2 : 3 * x + 1;
    seq.add(x);
    steps++;
    frames.add(ArrayFrame(
      values: [...seq],
      active: {seq.length - 1},
      caption: prev.isEven ? '$prev is even → ÷2 = $x.' : '$prev is odd → ×3+1 = $x.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...seq],
    done: {for (var i = 0; i < seq.length; i++) i},
    caption: 'Reached 1 after $steps steps.',
  ));
  return frames;
}

/// Matrix multiplication — fills the product C = A × B one cell at a time, each
/// cell being the dot product of a row of A and a column of B.
List<MatrixFrame> matrixMultiply() {
  const a = [
    [1, 2, 3],
    [4, 5, 6],
  ];
  const b = [
    [7, 8],
    [9, 10],
    [11, 12],
  ];
  final rows = a.length, cols = b[0].length, inner = b.length;
  final c = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  final filled = <int>{};
  List<List<int>> snap() => [for (final r in c) [...r]];

  final frames = <MatrixFrame>[
    MatrixFrame(a: a, b: b, c: snap(), op: '×', caption: 'Multiply A (2×3) by B (3×2).'),
  ];
  for (var i = 0; i < rows; i++) {
    for (var j = 0; j < cols; j++) {
      var sum = 0;
      final parts = <String>[];
      for (var k = 0; k < inner; k++) {
        sum += a[i][k] * b[k][j];
        parts.add('${a[i][k]}·${b[k][j]}');
      }
      c[i][j] = sum;
      filled.add(i * cols + j);
      frames.add(MatrixFrame(
        a: a,
        b: b,
        c: snap(),
        op: '×',
        aRows: {i},
        bCols: {j},
        activeR: i,
        activeC: j,
        filled: {...filled},
        caption: 'C[${i + 1}][${j + 1}] = ${parts.join(' + ')} = $sum.',
      ));
    }
  }
  frames.add(MatrixFrame(a: a, b: b, c: snap(), op: '×', filled: {...filled}, caption: 'Product computed.'));
  return frames;
}

/// Matrix addition — adds A and B element-wise into C.
List<MatrixFrame> matrixAdd() {
  const a = [
    [1, 2, 3],
    [4, 5, 6],
  ];
  const b = [
    [6, 5, 4],
    [3, 2, 1],
  ];
  final rows = a.length, cols = a[0].length;
  final c = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  final filled = <int>{};
  List<List<int>> snap() => [for (final r in c) [...r]];

  final frames = <MatrixFrame>[
    MatrixFrame(a: a, b: b, c: snap(), op: '+', caption: 'Add A and B element by element.'),
  ];
  for (var i = 0; i < rows; i++) {
    for (var j = 0; j < cols; j++) {
      c[i][j] = a[i][j] + b[i][j];
      filled.add(i * cols + j);
      frames.add(MatrixFrame(
        a: a,
        b: b,
        c: snap(),
        op: '+',
        aRows: {i},
        aCols: {j},
        bRows: {i},
        bCols: {j},
        activeR: i,
        activeC: j,
        filled: {...filled},
        caption: 'C[${i + 1}][${j + 1}] = ${a[i][j]} + ${b[i][j]} = ${c[i][j]}.',
      ));
    }
  }
  frames.add(MatrixFrame(a: a, b: b, c: snap(), op: '+', filled: {...filled}, caption: 'Sum computed.'));
  return frames;
}

/// Base conversion — converts a decimal number to [base] by repeated division,
/// reading the remainders bottom-up. Each row is one division step.
List<TableFrame> baseConversion(int n, {int base = 2}) {
  final divs = <List<int>>[]; // [value, remainder, quotient]
  var x = n;
  while (x > 0) {
    divs.add([x, x % base, x ~/ base]);
    x ~/= base;
  }
  if (divs.isEmpty) divs.add([0, 0, 0]);
  final rows = divs.length;
  final colHeader = ['value', 'rem (÷$base)', 'quotient'];
  final rowHeader = [for (var i = 0; i < rows; i++) 'step ${i + 1}'];
  final result = divs.map((d) => d[1]).toList().reversed.join();

  List<List<int>> cells() => [for (final d in divs) [...d]];
  final frames = <TableFrame>[
    TableFrame(
      rows: rows,
      cols: 3,
      cells: cells(),
      rowHeader: rowHeader,
      colHeader: colHeader,
      caption: 'Convert $n to base $base by repeated division.',
    ),
  ];
  final filled = <int>{};
  for (var i = 0; i < rows; i++) {
    for (var c = 0; c < 3; c++) {
      filled.add(i * 3 + c);
    }
    frames.add(TableFrame(
      rows: rows,
      cols: 3,
      cells: cells(),
      rowHeader: rowHeader,
      colHeader: colHeader,
      activeR: i,
      activeC: 1,
      filled: {...filled},
      caption: '${divs[i][0]} ÷ $base = ${divs[i][2]} remainder ${divs[i][1]}.',
    ));
  }
  frames.add(TableFrame(
    rows: rows,
    cols: 3,
    cells: cells(),
    rowHeader: rowHeader,
    colHeader: colHeader,
    filled: {...filled},
    caption: 'Read remainders bottom-up: $n = $result (base $base).',
  ));
  return frames;
}

/// Factorial — n! built up as the running product 1·2·3·…·n.
List<ArrayFrame> factorial(int n) {
  final partials = <int>[1];
  final frames = <ArrayFrame>[
    const ArrayFrame(values: [1], active: {0}, caption: '0! = 1 (the empty product).'),
  ];
  var acc = 1;
  for (var i = 1; i <= n; i++) {
    acc *= i;
    partials.add(acc);
    frames.add(ArrayFrame(
      values: [...partials],
      comparing: {partials.length - 2},
      active: {partials.length - 1},
      caption: '$i! = $i × ${partials[partials.length - 2]} = $acc.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...partials],
    done: {for (var k = 0; k < partials.length; k++) k},
    caption: '$n! = $acc.',
  ));
  return frames;
}

/// Fibonacci series — each number is the sum of the previous two.
List<ArrayFrame> fibonacci({int count = 12}) {
  final f = <int>[0, 1];
  final frames = <ArrayFrame>[
    ArrayFrame(values: [...f], active: {0, 1}, caption: 'Seed with F₀ = 0 and F₁ = 1.'),
  ];
  for (var i = 2; i < count; i++) {
    f.add(f[i - 1] + f[i - 2]);
    frames.add(ArrayFrame(
      values: [...f],
      comparing: {i - 2, i - 1},
      active: {i},
      caption: 'F$i = F${i - 1} + F${i - 2} = ${f[i - 1]} + ${f[i - 2]} = ${f[i]}.',
    ));
  }
  frames.add(ArrayFrame(
    values: [...f],
    done: {for (var i = 0; i < f.length; i++) i},
    caption: 'The first $count Fibonacci numbers.',
  ));
  return frames;
}

/// Euclid's algorithm for the greatest common divisor: repeatedly replace
/// (a, b) with (b, a mod b) until b is 0.
List<ArrayFrame> gcd(int a, int b) {
  final frames = <ArrayFrame>[
    ArrayFrame(values: [a, b], active: {0, 1}, caption: 'Euclid’s algorithm: gcd($a, $b).'),
  ];
  while (b != 0) {
    final r = a % b;
    frames.add(ArrayFrame(values: [a, b], comparing: {0, 1}, caption: '$a mod $b = $r.'));
    a = b;
    b = r;
    frames.add(ArrayFrame(values: [a, b], active: {0, 1}, caption: 'Replace with ($a, $b).'));
  }
  frames.add(ArrayFrame(values: [a, 0], done: {0}, caption: 'b reached 0 — gcd = $a.'));
  return frames;
}

/// Newton's method for the square root of n - repeatedly average a guess with
/// n/guess, which converges quadratically to sqrt(n).
List<ArrayFrame> newtonSqrt([int n = 50]) {
  final guesses = <int>[];
  final frames = <ArrayFrame>[ArrayFrame(values: [n], active: {0}, caption: 'Approximate the square root of $n by Newton iteration.')];
  var x = n.toDouble();
  var prev = 0.0;
  var iter = 0;
  while ((x - prev).abs() > 1e-6 && iter < 12) {
    prev = x;
    x = 0.5 * (x + n / x);
    iter++;
    guesses.add(x.round());
    frames.add(ArrayFrame(values: [...guesses], active: {guesses.length - 1}, caption: 'x <- 0.5 * (x + $n/x) = ${x.toStringAsFixed(3)}.'));
  }
  frames.add(ArrayFrame(values: [...guesses], done: {for (var k = 0; k < guesses.length; k++) k}, caption: 'sqrt($n) is about ${x.toStringAsFixed(4)}.'));
  return frames;
}

/// Extended Euclidean algorithm - finds x, y with a*x + b*y = gcd(a, b).
List<ArrayFrame> extendedEuclid(int a, int b) {
  final frames = <ArrayFrame>[ArrayFrame(values: [a, b], active: {0, 1}, caption: 'Find x, y with a*x + b*y = gcd(a, b).')];
  var oldR = a, r = b;
  var oldS = 1, s = 0;
  var oldT = 0, t = 1;
  while (r != 0) {
    final q = oldR ~/ r;
    frames.add(ArrayFrame(values: [oldR, r], comparing: {0, 1}, caption: 'Quotient $oldR / $r = $q.'));
    var tmp = oldR - q * r;
    oldR = r;
    r = tmp;
    tmp = oldS - q * s;
    oldS = s;
    s = tmp;
    tmp = oldT - q * t;
    oldT = t;
    t = tmp;
    frames.add(ArrayFrame(values: [oldR, r], active: {0, 1}, caption: 'Update remainders and coefficients.'));
  }
  frames.add(ArrayFrame(values: [oldR, 0], done: {0}, caption: 'gcd = $oldR with x = $oldS, y = $oldT.'));
  return frames;
}

/// Binary exponentiation (exponentiation by squaring) computes base^exp in
/// O(log exp) multiplications: read the exponent's bits, squaring the base each
/// step and multiplying it into the result whenever the current bit is set.
List<ArrayFrame> binaryExponentiation([int base = 3, int exp = 13]) {
  final frames = <ArrayFrame>[
    ArrayFrame(values: [base], active: {0}, caption: 'Compute $base^$exp by squaring — exponent in binary is ${exp.toRadixString(2)}.'),
  ];
  var result = 1;
  var b = base;
  var e = exp;
  final results = <int>[];
  while (e > 0) {
    if (e & 1 == 1) {
      result *= b;
      results.add(result);
      frames.add(ArrayFrame(
        values: [...results],
        active: {results.length - 1},
        caption: 'Bit is 1 — multiply result by the current base ($b): result = $result.',
      ));
    }
    b = b * b;
    e >>= 1;
    if (e > 0) {
      frames.add(ArrayFrame(
        values: results.isEmpty ? [base] : [...results],
        caption: 'Square the base → $b, shift the exponent right.',
      ));
    }
  }
  frames.add(ArrayFrame(
    values: results.isEmpty ? [result] : [...results],
    done: {for (var k = 0; k < (results.isEmpty ? 1 : results.length); k++) k},
    caption: '$base^$exp = $result.',
  ));
  return frames;
}

/// Matrix subtraction — subtracts B from A element-wise into C.
List<MatrixFrame> matrixSubtract() {
  const a = [
    [9, 8, 7],
    [6, 5, 4],
  ];
  const b = [
    [1, 2, 3],
    [4, 5, 6],
  ];
  final rows = a.length, cols = a[0].length;
  final c = [for (var i = 0; i < rows; i++) List<int>.filled(cols, 0)];
  final filled = <int>{};
  List<List<int>> snap() => [for (final r in c) [...r]];
  final frames = <MatrixFrame>[
    MatrixFrame(a: a, b: b, c: snap(), op: '−', caption: 'Subtract B from A element by element.'),
  ];
  for (var i = 0; i < rows; i++) {
    for (var j = 0; j < cols; j++) {
      c[i][j] = a[i][j] - b[i][j];
      filled.add(i * cols + j);
      frames.add(MatrixFrame(
        a: a, b: b, c: snap(), op: '−',
        aRows: {i}, aCols: {j}, bRows: {i}, bCols: {j},
        activeR: i, activeC: j, filled: {...filled},
        caption: 'C[${i + 1}][${j + 1}] = ${a[i][j]} − ${b[i][j]} = ${c[i][j]}.',
      ));
    }
  }
  frames.add(MatrixFrame(a: a, b: b, c: snap(), op: '−', filled: {...filled}, caption: 'Difference computed.'));
  return frames;
}

/// Sparse matrix — store only the non-zero entries as (row, col, value) triplets.
List<TableFrame> sparseMatrix() {
  const m = [
    [0, 0, 3, 0],
    [0, 5, 0, 0],
    [0, 0, 0, 7],
    [2, 0, 0, 0],
  ];
  final triplets = <List<int>>[];
  for (var r = 0; r < m.length; r++) {
    for (var c = 0; c < m[r].length; c++) {
      if (m[r][c] != 0) triplets.add([r, c, m[r][c]]);
    }
  }
  const colHeader = ['row', 'col', 'value'];
  List<List<int>> cells(int upto) => [for (var i = 0; i < upto; i++) [...triplets[i]]];
  final frames = <TableFrame>[
    TableFrame(rows: 0, cols: 3, cells: const [], colHeader: colHeader, caption: 'A 4×4 matrix with ${triplets.length} non-zeros — store only those.'),
  ];
  final filled = <int>{};
  for (var i = 0; i < triplets.length; i++) {
    for (var c = 0; c < 3; c++) {
      filled.add(i * 3 + c);
    }
    frames.add(TableFrame(
      rows: i + 1, cols: 3, cells: cells(i + 1), colHeader: colHeader,
      activeR: i, filled: {...filled},
      caption: 'Record value ${triplets[i][2]} at (${triplets[i][0]}, ${triplets[i][1]}).',
    ));
  }
  frames.add(TableFrame(rows: triplets.length, cols: 3, cells: cells(triplets.length), colHeader: colHeader, filled: {...filled}, caption: '${triplets.length} triplets instead of 16 cells.'));
  return frames;
}

/// Strassen's algorithm — multiply two 2×2 matrices with 7 products (M1..M7)
/// instead of 8, the building block of sub-cubic matrix multiplication.
List<TableFrame> strassen() {
  const a = [
    [1, 2],
    [3, 4],
  ];
  const b = [
    [5, 6],
    [7, 8],
  ];
  final m = <int>[
    (a[0][0] + a[1][1]) * (b[0][0] + b[1][1]), // M1
    (a[1][0] + a[1][1]) * b[0][0], // M2
    a[0][0] * (b[0][1] - b[1][1]), // M3
    a[1][1] * (b[1][0] - b[0][0]), // M4
    (a[0][0] + a[0][1]) * b[1][1], // M5
    (a[1][0] - a[0][0]) * (b[0][0] + b[0][1]), // M6
    (a[0][1] - a[1][1]) * (b[1][0] + b[1][1]), // M7
  ];
  const formulas = [
    '(a11+a22)(b11+b22)',
    '(a21+a22)·b11',
    'a11·(b12−b22)',
    'a22·(b21−b11)',
    '(a11+a12)·b22',
    '(a21−a11)(b11+b12)',
    '(a12−a22)(b21+b22)',
  ];
  final rowHeader = [for (var i = 0; i < 7; i++) 'M${i + 1}'];
  List<List<int>> cells(int upto) => [for (var i = 0; i < 7; i++) [i < upto ? m[i] : 0]];
  final frames = <TableFrame>[
    TableFrame(rows: 7, cols: 1, cells: cells(0), rowHeader: rowHeader, colHeader: const ['value'], caption: 'Strassen multiplies 2×2 with only 7 products.'),
  ];
  final filled = <int>{};
  for (var i = 0; i < 7; i++) {
    filled.add(i);
    frames.add(TableFrame(
      rows: 7, cols: 1, cells: cells(i + 1), rowHeader: rowHeader, colHeader: const ['value'],
      activeR: i, filled: {...filled},
      caption: 'M${i + 1} = ${formulas[i]} = ${m[i]}.',
    ));
  }
  final c11 = m[0] + m[3] - m[4] + m[6];
  final c12 = m[2] + m[4];
  final c21 = m[1] + m[3];
  final c22 = m[0] - m[1] + m[2] + m[5];
  frames.add(TableFrame(rows: 7, cols: 1, cells: cells(7), rowHeader: rowHeader, colHeader: const ['value'], filled: {...filled}, caption: 'C = [[$c11, $c12], [$c21, $c22]] from the 7 products.'));
  return frames;
}

/// Determinant of a 3×3 matrix by cofactor expansion along the first row.
List<TableFrame> determinant() {
  const m = [
    [6, 1, 1],
    [4, -2, 5],
    [2, 8, 7],
  ];
  List<List<int>> cells() => [for (final r in m) [...r]];
  final frames = <TableFrame>[
    TableFrame(rows: 3, cols: 3, cells: cells(), caption: 'Determinant by cofactor expansion along the top row.'),
  ];
  final cof = <int>[];
  var det = 0;
  for (var j = 0; j < 3; j++) {
    // Cyclic (Sarrus) expansion along the top row — already sign-correct.
    final c1 = (j + 1) % 3, c2 = (j + 2) % 3;
    final minor = m[1][c1] * m[2][c2] - m[1][c2] * m[2][c1];
    final term = m[0][j] * minor;
    cof.add(term);
    det += term;
    frames.add(TableFrame(
      rows: 3, cols: 3, cells: cells(), activeR: 0, activeC: j,
      caption: '${m[0][j]} × (cofactor $minor) = $term.',
    ));
  }
  frames.add(TableFrame(rows: 3, cols: 3, cells: cells(), caption: 'det = ${cof.join(' + ').replaceAll('+ -', '- ')} = $det.'));
  return frames;
}

/// Matrix inversion by Gauss–Jordan elimination on [A | I]. Uses a unimodular A
/// so every step stays integer.
List<TableFrame> matrixInversion() {
  final aug = [
    [1, 1, 0, 1, 0, 0],
    [0, 1, 1, 0, 1, 0],
    [0, 0, 1, 0, 0, 1],
  ];
  const colHeader = ['', '', '', 'I', '', ''];
  List<List<int>> cells() => [for (final r in aug) [...r]];
  final frames = <TableFrame>[
    TableFrame(rows: 3, cols: 6, cells: cells(), colHeader: colHeader, caption: 'Augment A with the identity, then reduce A to I.'),
  ];
  for (var p = 0; p < 3; p++) {
    for (var r = 0; r < 3; r++) {
      if (r == p) continue;
      final f = aug[r][p];
      if (f != 0) {
        for (var c = 0; c < 6; c++) {
          aug[r][c] -= f * aug[p][c];
        }
        frames.add(TableFrame(rows: 3, cols: 6, cells: cells(), colHeader: colHeader, activeR: r, activeC: p, caption: 'R$r ← R$r − $f·R$p to clear column $p.'));
      }
    }
  }
  frames.add(TableFrame(rows: 3, cols: 6, cells: cells(), colHeader: colHeader, filled: {for (var i = 0; i < 18; i++) i}, caption: 'Left side is I; the right side is A⁻¹.'));
  return frames;
}

/// Matrix transpose — reflect a square matrix across its main diagonal by
/// swapping entries (i, j) and (j, i).
List<TableFrame> matrixTranspose() {
  final m = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ];
  final n = m.length;
  List<List<int>> cells() => [for (final r in m) [...r]];
  final frames = <TableFrame>[
    TableFrame(rows: n, cols: n, cells: cells(), caption: 'Transpose: reflect entries across the main diagonal.'),
  ];
  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      final t = m[i][j];
      m[i][j] = m[j][i];
      m[j][i] = t;
      frames.add(TableFrame(
        rows: n, cols: n, cells: cells(), activeR: i, activeC: j,
        refs: {j * n + i},
        caption: 'Swap (${i + 1},${j + 1}) ↔ (${j + 1},${i + 1}).',
      ));
    }
  }
  frames.add(TableFrame(rows: n, cols: n, cells: cells(), filled: {for (var k = 0; k < n * n; k++) k}, caption: 'Transposed — rows became columns.'));
  return frames;
}

/// Least common multiple — computed from the GCD via lcm(a, b) = a·b / gcd(a, b),
/// with the GCD found by the Euclidean algorithm.
List<ArrayFrame> lcm(int a, int b) {
  final frames = <ArrayFrame>[ArrayFrame(values: [a, b], active: {0, 1}, caption: 'lcm($a, $b) = a·b / gcd(a, b).')];
  var x = a, y = b;
  while (y != 0) {
    frames.add(ArrayFrame(values: [x, y], comparing: {0, 1}, caption: 'gcd step: $x mod $y = ${x % y}.'));
    final t = y;
    y = x % y;
    x = t;
  }
  final g = x;
  final result = a ~/ g * b;
  frames.add(ArrayFrame(values: [g], active: {0}, caption: 'gcd($a, $b) = $g.'));
  frames.add(ArrayFrame(values: [result], done: {0}, caption: 'lcm = $a × $b / $g = $result.'));
  return frames;
}

/// Prime factorization by trial division — repeatedly divide out the smallest
/// factor until the remainder is 1.
List<ArrayFrame> primeFactorization(int n) {
  final factors = <int>[];
  final frames = <ArrayFrame>[ArrayFrame(values: [n], active: {0}, caption: 'Factorize $n by dividing out primes from 2 up.')];
  var x = n;
  for (var d = 2; d * d <= x; d++) {
    while (x % d == 0) {
      factors.add(d);
      x ~/= d;
      frames.add(ArrayFrame(values: [...factors], active: {factors.length - 1}, caption: '$d divides — factor out; remainder $x.'));
    }
  }
  if (x > 1) {
    factors.add(x);
    frames.add(ArrayFrame(values: [...factors], active: {factors.length - 1}, caption: 'Remainder $x is prime — it is the last factor.'));
  }
  frames.add(ArrayFrame(values: [...factors], done: {for (var k = 0; k < factors.length; k++) k}, caption: '$n = ${factors.join(' × ')}.'));
  return frames;
}
