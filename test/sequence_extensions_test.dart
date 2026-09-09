import 'dart:math';

import 'package:algoscope/algorithms/sequence_extensions.dart';
import 'package:algoscope/data/sequence_catalog.dart';
import 'package:algoscope/models/sequence_trace.dart';
import 'package:algoscope/visualizers/sequence_trace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> ints(List<SequenceTrace> frames) =>
    frames.last.output.map(int.parse).toList();

void validFrames(List<SequenceTrace> frames) {
  expect(frames.length, greaterThanOrEqualTo(2));
  expect(frames.last.result, isNotEmpty);
  for (final frame in frames) {
    expect(frame.caption, isNotEmpty);
    for (final row in frame.rows) {
      for (final index in [
        ...row.pointers.values,
        ...row.active,
        ...row.done,
      ]) {
        expect(
          index,
          inInclusiveRange(0, row.values.length - 1),
          reason: frame.caption,
        );
      }
      expect(row.rangeStart == null, row.rangeEnd == null);
      if (row.rangeStart != null) {
        expect(row.rangeStart, inInclusiveRange(0, row.values.length - 1));
        expect(
          row.rangeEnd,
          inInclusiveRange(row.rangeStart!, row.values.length - 1),
        );
      }
    }
  }
}

Map<String, List<SequenceTrace>> examples() => {
  'pair': twoPointerPairSum([-2, 0, 1, 3, 4, 8], 6),
  'window': maxWindowSum([2, -4, 3, 8, -1, 2, 4, 0], 3),
  'unique': longestUniqueWindow('abcaefbg'),
  'flag': dutchFlag([2, 0, 1, 2, 1, 0, 2, 0]),
  'prefix': prefixRangeSum([2, -4, 3, 8, -1, 2, 4, 0], 2, 5),
  'product': productExceptSelf([1, 2, 0, 4, 5, -2]),
  'water': trappedRainwater([3, 0, 2, 0, 4, 1, 2, 3]),
  'vote': majorityVote([2, 2, 1, 1, 2, 2, 2]),
  'greater': nextGreaterElements([4, 1, 7, 5, 8, 2]),
  'brackets': balancedBrackets('{[()]}()'),
  'shunting': shuntingYard('(8-3)*(2+1)'),
  'postfix': evaluatePostfix(['8', '3', '-', '2', '1', '+', '*']),
  'encoding': runLengthEncode('aaabbccccd'),
  'palindrome': manacherPalindrome('abacaba'),
  'range': equalRangeSearch([1, 2, 2, 2, 3, 5, 7], 2),
  'natural': naturalMergeSort([2, 4, 1, 3, 0, 5, 2, 1]),
  'insertion': binaryInsertionSort([2, 4, 1, 3, 0, 5, 2, 1]),
  'tournament': tournamentSort([2, 4, 1, 3, 0, 5]),
};

void main() {
  test('three new sorts preserve input and match a sorting oracle', () {
    final rng = Random(902);
    final samples = <List<int>>[
      [],
      [5],
      [2, 2, 2],
      [1, 2, 3],
      [5, 4, 3, 2, 1],
      for (var i = 0; i < 40; i++)
        List.generate(rng.nextInt(10), (_) => rng.nextInt(15) - 7),
    ];
    for (final input in samples) {
      final original = [...input], sorted = [...input]..sort();
      for (final sort in [
        naturalMergeSort,
        binaryInsertionSort,
        tournamentSort,
      ]) {
        final frames = sort(input);
        expect(ints(frames), sorted);
        expect(input, original);
        validFrames(frames);
      }
    }
  });

  test('array traces agree with independent exhaustive results', () {
    final rng = Random(61);
    for (var repeat = 0; repeat < 40; repeat++) {
      final a = List.generate(8, (_) => rng.nextInt(13) - 6);
      final sorted = [...a]..sort(), target = rng.nextInt(20) - 10;
      final pair = twoPointerPairSum(sorted, target);
      final exists = [
        for (var i = 0; i < a.length; i++)
          for (var j = i + 1; j < a.length; j++) a[i] + a[j],
      ].contains(target);
      expect(pair.last.output.isNotEmpty, exists);
      if (exists) expect(ints(pair).reduce((x, y) => x + y), target);
      final window = maxWindowSum(a, 3);
      expect(ints(window), [
        [
          for (var start = 0; start <= a.length - 3; start++)
            a.skip(start).take(3).reduce((x, y) => x + y),
        ].reduce(max),
      ]);
      final prefix = prefixRangeSum(a, 1, 5);
      expect(ints(prefix), [a.sublist(1, 6).reduce((x, y) => x + y)]);
      final product = productExceptSelf(a);
      expect(ints(product), [
        for (var i = 0; i < a.length; i++)
          [
            for (var j = 0; j < a.length; j++)
              if (i != j) a[j],
          ].fold(1, (x, y) => x * y),
      ]);
      final greater = nextGreaterElements(a);
      expect(greater.last.output, [
        for (var i = 0; i < a.length; i++)
          a.skip(i + 1).where((v) => v > a[i]).isEmpty
              ? '—'
              : '${a.skip(i + 1).firstWhere((v) => v > a[i])}',
      ]);
      final range = equalRangeSearch(sorted, target);
      expect(ints(range), [
        sorted.where((v) => v < target).length,
        sorted.where((v) => v <= target).length,
      ]);
      final vote = majorityVote(a);
      final majorities = a
          .toSet()
          .where((v) => a.where((x) => x == v).length > a.length ~/ 2)
          .toList();
      expect(ints(vote), majorities);
      final heights = a.map((x) => x.abs()).toList();
      final water = trappedRainwater(heights);
      final expectedWater = [
        for (var i = 0; i < heights.length; i++)
          min(heights.take(i + 1).reduce(max), heights.skip(i).reduce(max)) -
              heights[i],
      ].reduce((x, y) => x + y);
      expect(ints(water), [expectedWater]);
      final flags = a.map((x) => x.abs() % 3).toList();
      final partition = dutchFlag(flags);
      expect(ints(partition), [...flags]..sort());
      for (final frames in [
        pair,
        window,
        prefix,
        product,
        greater,
        range,
        vote,
        water,
        partition,
      ]) {
        validFrames(frames);
      }
    }
  });

  test(
    'string windows and palindrome radii agree with exhaustive substrings',
    () {
      final rng = Random(77);
      for (final text in [
        '',
        'a',
        'abba',
        'babad',
        'a·a',
        '😀a😀',
        for (var repeat = 0; repeat < 40; repeat++)
          List.generate(rng.nextInt(10), (_) => 'abc'[rng.nextInt(3)]).join(),
      ]) {
        final chars = text.runes.toList();
        var unique = <int>[], palindrome = <int>[];
        for (var start = 0; start < chars.length; start++) {
          for (var end = start + 1; end <= chars.length; end++) {
            final sub = chars.sublist(start, end);
            if (sub.toSet().length == sub.length &&
                sub.length > unique.length) {
              unique = sub;
            }
            if (sub.join(',') == sub.reversed.join(',') &&
                sub.length > palindrome.length) {
              palindrome = sub;
            }
          }
        }
        final uniqueFrames = longestUniqueWindow(text),
            palindromeFrames = manacherPalindrome(text);
        expect(uniqueFrames.last.output, [String.fromCharCodes(unique)]);
        expect(palindromeFrames.last.output, [
          String.fromCharCodes(palindrome),
        ]);
        validFrames(uniqueFrames);
        validFrames(palindromeFrames);
        final encoded = runLengthEncode(text);
        final decoded = encoded.last.output.map((run) {
          final colon = run.lastIndexOf(':');
          return List.filled(
            int.parse(run.substring(colon + 1)),
            run.substring(0, colon),
          ).join();
        }).join();
        expect(decoded, text);
        validFrames(encoded);
      }
    },
  );

  test('stack expressions preserve nesting, precedence and operand order', () {
    for (final text in ['', '()[]{}', '{a[b(c)]}', '(())']) {
      expect(balancedBrackets(text).last.output, ['true']);
    }
    for (final text in ['(', ')', '([)]', '(()', '{]']) {
      expect(balancedBrackets(text).last.output, ['false']);
    }
    for (final (infix, postfix, value) in [
      ('3+4*2', ['3', '4', '2', '*', '+'], '11'),
      ('(8-3)*(2+1)', ['8', '3', '-', '2', '1', '+', '*'], '15'),
      ('2^3^2', ['2', '3', '2', '^', '^'], '512'),
      ('9/(3-1)+4', ['9', '3', '1', '-', '/', '4', '+'], '8.5'),
      ('10-4-2', ['10', '4', '-', '2', '-'], '4'),
    ]) {
      final conversion = shuntingYard(infix),
          evaluation = evaluatePostfix(postfix);
      expect(conversion.last.output, postfix);
      expect(evaluation.last.output, [value]);
      validFrames(conversion);
      validFrames(evaluation);
    }
    for (final bad in ['2+', '(2+3', '2+3)', '2**3', '2(3)', '2@3']) {
      expect(() => shuntingYard(bad), throwsArgumentError);
    }
    for (final bad in <List<String>>[
      [],
      ['1', '2'],
      ['+'],
      ['3', '0', '/'],
      ['2', 'x', '+'],
    ]) {
      expect(() => evaluatePostfix(bad), throwsArgumentError);
    }
  });

  test('empty cases and invalid domains have explicit behavior', () {
    expect(twoPointerPairSum([], 1).last.output, isEmpty);
    expect(equalRangeSearch([], 1).last.output, ['0', '0']);
    expect(productExceptSelf([]).last.output, isEmpty);
    expect(productExceptSelf([9]).last.output, ['1']);
    expect(trappedRainwater([]).last.output, ['0']);
    expect(majorityVote([]).last.output, isEmpty);
    expect(nextGreaterElements([]).last.output, isEmpty);
    expect(() => maxWindowSum([1], 0), throwsArgumentError);
    expect(() => maxWindowSum([], 1), throwsArgumentError);
    expect(() => prefixRangeSum([1], 0, 1), throwsArgumentError);
    expect(() => dutchFlag([3]), throwsArgumentError);
    expect(() => trappedRainwater([-1]), throwsArgumentError);
    expect(() => twoPointerPairSum([2, 1], 3), throwsArgumentError);
    expect(() => equalRangeSearch([2, 1], 1), throwsArgumentError);
  });

  test(
    'expression tokenization preserves whitespace boundaries and large values',
    () {
      expect(shuntingYard(' 12 + 3 * (4 - 2) ').last.output, [
        '12',
        '3',
        '4',
        '2',
        '-',
        '*',
        '+',
      ]);
      for (final expression in ['12 34', 'a b', '2\n3', '2 @ 3']) {
        expect(() => shuntingYard(expression), throwsArgumentError);
      }
      for (final tokens in <List<String>>[
        ['1e30'],
        ['1e20', '1e20', '*'],
        ['-1e30'],
      ]) {
        final frames = evaluatePostfix(tokens);
        validFrames(frames);
        final expected = tokens.length == 1
            ? double.parse(tokens.single)
            : 1e40;
        expect(double.parse(frames.last.output.single), expected);
      }
    },
  );

  test('trace rows, variables and outputs are frozen snapshots', () {
    final values = [1, 2], pointers = {'scan': 0}, active = {0};
    final row = SequenceTraceRow(
      label: 'input',
      values: values,
      pointers: pointers,
      active: active,
    );
    final variables = <String, Object>{'sum': 1};
    final frame = SequenceTrace(
      caption: 'snapshot',
      rows: [row],
      variables: variables,
      output: values,
    );
    values[0] = 99;
    pointers['scan'] = 1;
    active.clear();
    variables['sum'] = 99;
    expect(row.values, ['1', '2']);
    expect(row.pointers, {'scan': 0});
    expect(row.active, {0});
    expect(frame.variables, {'sum': '1'});
    expect(frame.output, ['1', '2']);
    expect(() => row.values.add('3'), throwsUnsupportedError);
    expect(() => row.pointers['scan'] = 2, throwsUnsupportedError);
    expect(() => frame.rows.clear(), throwsUnsupportedError);
    expect(() => frame.variables.clear(), throwsUnsupportedError);
  });

  test('all 18 catalog extensions have complete traces and metadata', () {
    expect(sequenceExtensions.length, 18);
    expect(sequenceExtensions.map((a) => a.id).toSet().length, 18);
    for (final entry in sequenceExtensions) {
      final run = entry.create();
      expect(run.frameCount, greaterThanOrEqualTo(2));
      for (var i = 0; i < run.frameCount; i++) {
        expect(run.captionAt(i), isNotEmpty);
      }
      expect(entry.description, isNotEmpty);
    }
    for (final frames in examples().values) {
      validFrames(frames);
    }
  });

  testWidgets('every example frame fits both phone and desktop canvases', (
    tester,
  ) async {
    for (final size in [const Size(300, 180), const Size(1100, 500)]) {
      for (final entry in examples().entries) {
        for (final frame in entry.value) {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox.fromSize(
                  size: size,
                  child: SequenceTraceView(frame: frame),
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${entry.key}: ${frame.caption} at $size',
          );
        }
      }
    }
  });
}
