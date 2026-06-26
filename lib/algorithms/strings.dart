import '../models/frames.dart';

/// Naive string matching — try the pattern at every offset, comparing character
/// by character and sliding right by one on the first mismatch.
List<StringMatchFrame> naiveSearch([String text = 'ABABACABAB', String pattern = 'ABABA']) {
  final n = text.length, m = pattern.length;
  final frames = <StringMatchFrame>[];
  for (var i = 0; i <= n - m; i++) {
    final matched = <int>{};
    var j = 0;
    for (; j < m; j++) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: i,
        compareIndex: j,
        matched: {...matched},
        caption: 'Compare text[${i + j}]=${text[i + j]} with pattern[$j]=${pattern[j]}.',
      ));
      if (text[i + j] == pattern[j]) {
        matched.add(j);
      } else {
        frames.add(StringMatchFrame(
          text: text,
          pattern: pattern,
          offset: i,
          mismatch: j,
          matched: {...matched},
          caption: 'Mismatch — slide the pattern right by one.',
        ));
        break;
      }
    }
    if (j == m) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: i,
        matched: {for (var k = 0; k < m; k++) k},
        found: {for (var k = 0; k < m; k++) i + k},
        caption: 'Whole pattern matched at index $i!',
      ));
      return frames;
    }
  }
  frames.add(StringMatchFrame(text: text, pattern: pattern, offset: 0, caption: 'Pattern not found.'));
  return frames;
}

/// Knuth–Morris–Pratt — precompute the longest-prefix-suffix table, then match
/// without ever re-examining text characters, jumping the pattern on mismatch.
List<StringMatchFrame> kmpSearch([String text = 'ABABACABAB', String pattern = 'ABABA']) {
  final n = text.length, m = pattern.length;
  final lps = List<int>.filled(m, 0);
  var len = 0;
  var p = 1;
  while (p < m) {
    if (pattern[p] == pattern[len]) {
      lps[p++] = ++len;
    } else if (len > 0) {
      len = lps[len - 1];
    } else {
      lps[p++] = 0;
    }
  }

  final frames = <StringMatchFrame>[];
  var i = 0, j = 0;
  while (i < n) {
    frames.add(StringMatchFrame(
      text: text,
      pattern: pattern,
      offset: i - j,
      compareIndex: j,
      matched: {for (var k = 0; k < j; k++) k},
      caption: 'Compare text[$i]=${text[i]} with pattern[$j]=${pattern[j]}.',
    ));
    if (text[i] == pattern[j]) {
      i++;
      j++;
      if (j == m) {
        final start = i - j;
        frames.add(StringMatchFrame(
          text: text,
          pattern: pattern,
          offset: start,
          matched: {for (var k = 0; k < m; k++) k},
          found: {for (var k = 0; k < m; k++) start + k},
          caption: 'Whole pattern matched at index $start!',
        ));
        return frames;
      }
    } else if (j > 0) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: i - lps[j - 1],
        mismatch: j,
        matched: {for (var k = 0; k < lps[j - 1]; k++) k},
        caption: 'Mismatch — the prefix table lets us resume at pattern[${lps[j - 1]}].',
      ));
      j = lps[j - 1];
    } else {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: i + 1,
        mismatch: 0,
        caption: 'Mismatch at the start — advance the text by one.',
      ));
      i++;
    }
  }
  frames.add(StringMatchFrame(text: text, pattern: pattern, offset: 0, caption: 'Pattern not found.'));
  return frames;
}

/// Boyer–Moore (bad-character rule) — compares the pattern right-to-left and,
/// on a mismatch, slides the pattern so the offending text character lines up
/// with its last occurrence in the pattern.
List<StringMatchFrame> boyerMoore([String text = 'ABAAABCDABC', String pattern = 'ABC']) {
  final n = text.length, m = pattern.length;
  final last = <String, int>{};
  for (var i = 0; i < m; i++) {
    last[pattern[i]] = i;
  }
  final frames = <StringMatchFrame>[];
  var s = 0;
  while (s <= n - m) {
    var j = m - 1;
    final matched = <int>{};
    while (j >= 0) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: s,
        compareIndex: j,
        matched: {...matched},
        caption: 'Compare right-to-left: text[${s + j}]=${text[s + j]} vs pattern[$j]=${pattern[j]}.',
      ));
      if (text[s + j] == pattern[j]) {
        matched.add(j);
        j--;
      } else {
        final lo = last[text[s + j]] ?? -1;
        final shift = (j - lo) > 1 ? (j - lo) : 1;
        frames.add(StringMatchFrame(
          text: text,
          pattern: pattern,
          offset: s,
          mismatch: j,
          matched: {...matched},
          caption: 'Mismatch — bad-character rule shifts the pattern by $shift.',
        ));
        s += shift;
        break;
      }
    }
    if (j < 0) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: s,
        matched: {for (var k = 0; k < m; k++) k},
        found: {for (var k = 0; k < m; k++) s + k},
        caption: 'Whole pattern matched at index $s!',
      ));
      return frames;
    }
  }
  frames.add(StringMatchFrame(text: text, pattern: pattern, offset: 0, caption: 'Pattern not found.'));
  return frames;
}

/// Rabin–Karp — compares a rolling hash of each text window against the
/// pattern's hash, verifying character-by-character only on a hash collision.
List<StringMatchFrame> rabinKarp([String text = 'ABABACABAB', String pattern = 'ABABA']) {
  final n = text.length, m = pattern.length;
  const base = 256, mod = 101;
  int hash(String s, int start, int len) {
    var x = 0;
    for (var i = 0; i < len; i++) {
      x = (x * base + s.codeUnitAt(start + i)) % mod;
    }
    return x;
  }

  final ph = hash(pattern, 0, m);
  final frames = <StringMatchFrame>[];
  for (var s = 0; s <= n - m; s++) {
    final th = hash(text, s, m);
    frames.add(StringMatchFrame(
      text: text,
      pattern: pattern,
      offset: s,
      matched: {for (var k = 0; k < m; k++) k},
      caption: 'Window [$s, ${s + m - 1}] hash $th vs pattern hash $ph.',
    ));
    if (th == ph) {
      var ok = true;
      for (var k = 0; k < m; k++) {
        if (text[s + k] != pattern[k]) {
          ok = false;
          frames.add(StringMatchFrame(text: text, pattern: pattern, offset: s, mismatch: k, caption: 'Hashes match but characters differ at $k — spurious hit.'));
          break;
        }
      }
      if (ok) {
        frames.add(StringMatchFrame(
          text: text,
          pattern: pattern,
          offset: s,
          matched: {for (var k = 0; k < m; k++) k},
          found: {for (var k = 0; k < m; k++) s + k},
          caption: 'Hashes match and characters confirm — found at index $s!',
        ));
        return frames;
      }
    } else {
      frames.add(StringMatchFrame(text: text, pattern: pattern, offset: s, caption: 'Hashes differ — no match here.'));
    }
  }
  frames.add(StringMatchFrame(text: text, pattern: pattern, offset: 0, caption: 'Pattern not found.'));
  return frames;
}

/// Z-algorithm matching - builds the Z-array of "pattern # text"; any position
/// whose Z-value equals the pattern length marks a full match.
List<StringMatchFrame> zSearch([String text = 'ABABACABAB', String pattern = 'ABABA']) {
  final m = pattern.length;
  final s = '$pattern#$text';
  final n = s.length;
  final z = List<int>.filled(n, 0);
  var l = 0, r = 0;
  for (var i = 1; i < n; i++) {
    if (i < r) z[i] = (r - i) < z[i - l] ? (r - i) : z[i - l];
    while (i + z[i] < n && s[z[i]] == s[i + z[i]]) {
      z[i]++;
    }
    if (i + z[i] > r) {
      l = i;
      r = i + z[i];
    }
  }
  final frames = <StringMatchFrame>[];
  for (var i = 0; i < text.length; i++) {
    final zi = z[m + 1 + i];
    final matchedLen = zi > m ? m : zi;
    frames.add(StringMatchFrame(
      text: text,
      pattern: pattern,
      offset: i,
      matched: {for (var k = 0; k < matchedLen; k++) k},
      compareIndex: matchedLen < m ? matchedLen : null,
      caption: 'At index $i the pattern matches $matchedLen character(s) (Z = $zi).',
    ));
    if (zi >= m) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: i,
        matched: {for (var k = 0; k < m; k++) k},
        found: {for (var k = 0; k < m; k++) i + k},
        caption: 'Z equals $m here - full match at index $i!',
      ));
      return frames;
    }
  }
  frames.add(StringMatchFrame(text: text, pattern: pattern, offset: 0, caption: 'Pattern not found.'));
  return frames;
}

/// Boyer–Moore–Horspool — a simpler Boyer–Moore variant that always shifts the
/// pattern based on the text character currently aligned with the pattern's last
/// position, using a single bad-character table.
List<StringMatchFrame> horspool([String text = 'TRUSTHARDTOOTHBRUSHES', String pattern = 'TOOTH']) {
  final n = text.length, m = pattern.length;
  final shift = <String, int>{};
  for (var i = 0; i < m - 1; i++) {
    shift[pattern[i]] = m - 1 - i;
  }
  final frames = <StringMatchFrame>[];
  var s = 0;
  while (s <= n - m) {
    var j = m - 1;
    final matched = <int>{};
    while (j >= 0) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: s,
        compareIndex: j,
        matched: {...matched},
        caption: 'Compare right-to-left: text[${s + j}]=${text[s + j]} vs pattern[$j]=${pattern[j]}.',
      ));
      if (text[s + j] == pattern[j]) {
        matched.add(j);
        j--;
      } else {
        break;
      }
    }
    if (j < 0) {
      frames.add(StringMatchFrame(
        text: text,
        pattern: pattern,
        offset: s,
        matched: {for (var k = 0; k < m; k++) k},
        found: {for (var k = 0; k < m; k++) s + k},
        caption: 'Whole pattern matched at index $s!',
      ));
      return frames;
    }
    final c = text[s + m - 1];
    final sh = shift[c] ?? m;
    frames.add(StringMatchFrame(
      text: text,
      pattern: pattern,
      offset: s,
      mismatch: j,
      matched: {...matched},
      caption: 'Mismatch — shift by $sh using the last aligned char "$c".',
    ));
    s += sh;
  }
  frames.add(StringMatchFrame(text: text, pattern: pattern, offset: 0, caption: 'Pattern not found.'));
  return frames;
}
