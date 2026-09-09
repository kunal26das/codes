import 'dart:convert';
import 'dart:math';

import 'package:algoscope/algorithms/ai.dart';
import 'package:algoscope/algorithms/sorting.dart';
import 'package:algoscope/algorithms/strings.dart';
import 'package:algoscope/models/frames.dart';
import 'package:flutter_test/flutter_test.dart';

({int wins, int visits}) _stats(GTreeNode node) {
  final parts = node.label.split('/').map(int.parse).toList();
  return (wins: parts[0], visits: parts[1]);
}

String _treeHistory(List<GTreeFrame> frames) => jsonEncode([
  for (final frame in frames)
    [
      frame.caption,
      for (final node in frame.nodes)
        [node.id, node.label, node.children, node.edgeLabel, node.state.name],
    ],
]);

void main() {
  group('BST sort', () {
    test('preserves duplicates and handles empty and skewed trees', () {
      for (final input in <List<int>>[
        [],
        [5],
        [3, -2, 3, 0, -2, 3],
        [1, 2, 3, 4, 5, 6],
        [6, 5, 4, 3, 2, 1],
      ]) {
        final original = [...input];
        final expected = [...input]..sort();
        final frames = bstSort(input);
        expect(input, original);
        expect(frames.first.values, original);
        expect(frames.last.values, expected);
        for (final frame in frames) {
          for (final index in {
            ...frame.active,
            ...frame.comparing,
            ...frame.done,
          }) {
            expect(index, inInclusiveRange(0, frame.values.length - 1));
          }
        }
      }
    });

    test('insertion frames follow existing tree branches', () {
      final frames = bstSort([5, 3, 7, 2, 4, 6, 8]);
      List<int> ancestorsFor(int inputIndex) => [
        for (final frame in frames)
          if (frame.active.contains(inputIndex) && frame.comparing.isNotEmpty)
            frame.comparing.single,
      ];
      // 4 belongs under the left child of 5; 8 under the right child.
      expect(ancestorsFor(4), [0, 1]);
      expect(ancestorsFor(6), [0, 2]);
      expect(frames.last.values, [2, 3, 4, 5, 6, 7, 8]);
    });
  });

  group('Rabin–Karp', () {
    test('rolling hashes equal independently recomputed window hashes', () {
      const text = 'JUXYABCD\u03A9\u0100Q';
      const pattern = 'ZZZ';
      final frames = rabinKarp(text, pattern);
      final windowFrames = frames
          .where((frame) => frame.caption.startsWith('Window '))
          .toList();
      expect(windowFrames.length, text.length - pattern.length + 1);
      for (final frame in windowFrames) {
        var expectedHash = 0;
        for (var i = 0; i < pattern.length; i++) {
          expectedHash =
              (expectedHash * 256 + text.codeUnitAt(frame.offset + i)) % 101;
        }
        final shownHash = int.parse(
          RegExp(r'\] hash (\d+)').firstMatch(frame.caption)!.group(1)!,
        );
        expect(shownHash, expectedHash);
        expect(
          frame.matched,
          isEmpty,
          reason: 'A hash check does not confirm any character.',
        );
      }
    });

    test('rejects a hash collision before finding a later true match', () {
      // JU and AB both hash to 41 modulo 101 with base 256.
      final frames = rabinKarp('JUAB', 'AB');
      expect(
        frames.any((frame) => frame.offset == 0 && frame.mismatch == 0),
        isTrue,
      );
      expect(frames.last.found, {2, 3});
      for (final frame in frames) {
        for (final index in frame.matched) {
          expect(frame.text[frame.offset + index], frame.pattern[index]);
        }
      }
    });

    test('agrees with the first occurrence for varied texts and patterns', () {
      final rng = Random(91);
      const alphabet = 'ABCD';
      String word(int length) => String.fromCharCodes([
        for (var i = 0; i < length; i++)
          alphabet.codeUnitAt(rng.nextInt(alphabet.length)),
      ]);
      for (var trial = 0; trial < 100; trial++) {
        final text = word(rng.nextInt(24));
        final pattern = word(1 + rng.nextInt(6));
        final expected = text.indexOf(pattern);
        final last = rabinKarp(text, pattern).last;
        expect(
          last.found,
          expected == -1
              ? <int>{}
              : {for (var i = 0; i < pattern.length; i++) expected + i},
        );
      }
      expect(rabinKarp('', '').last.caption, contains('index 0'));
      expect(rabinKarp('AB', 'ABC').last.found, isEmpty);
    });
  });

  group('Monte-Carlo tree search', () {
    test('grows a legal game tree and keeps every earlier snapshot intact', () {
      const iterations = 32;
      final frames = monteCarlo(iterations: iterations);
      expect(frames.first.nodes.length, 1);
      expect(frames.first.nodes.single.children, isEmpty);
      expect(frames.first.nodes.single.label, '0/0');
      var previousCount = 1;
      var completed = 0;
      for (final frame in frames) {
        expect(frame.nodes.length - previousCount, inInclusiveRange(0, 1));
        previousCount = frame.nodes.length;
        final byId = {for (final node in frame.nodes) node.id: node};
        expect(byId.length, frame.nodes.length);
        final pending = [(id: 0, stones: 4, depth: 0)];
        final reached = <int>{};
        while (pending.isNotEmpty) {
          final state = pending.removeLast();
          expect(
            reached.add(state.id),
            isTrue,
            reason: 'Nodes must have one parent and no cycles.',
          );
          final node = byId[state.id]!;
          final stats = _stats(node);
          expect(stats.wins, inInclusiveRange(0, stats.visits));
          final moves = <int>{};
          for (final childId in node.children) {
            final child = byId[childId]!;
            final take = int.parse(child.edgeLabel!.split(' ').last);
            expect(take, inInclusiveRange(1, min(2, state.stones)));
            expect(moves.add(take), isTrue);
            expect(_stats(child).visits, lessThanOrEqualTo(stats.visits));
            pending.add((
              id: childId,
              stones: state.stones - take,
              depth: state.depth + 1,
            ));
          }
          if (state.stones == 0) {
            expect(node.children, isEmpty);
            expect(stats.wins, state.depth.isOdd ? stats.visits : 0);
          }
        }
        expect(reached.length, frame.nodes.length);
        if (frame.caption.startsWith('Back-propagate')) {
          completed++;
          final root = byId[0]!;
          expect(_stats(root).visits, completed);
          expect(
            root.children.fold<int>(
              0,
              (sum, id) => sum + _stats(byId[id]!).visits,
            ),
            completed,
          );
          expect(
            root.children.fold<int>(
              0,
              (sum, id) => sum + _stats(byId[id]!).wins,
            ),
            _stats(root).wins,
          );
        }
      }
      expect(completed, iterations);
      expect(frames.last.nodes.length, inInclusiveRange(3, 12));
      expect(frames.length, lessThanOrEqualTo(4 * iterations + 2));
    });

    test('learns the winning root move and adversarial opponent response', () {
      final last = monteCarlo(iterations: 128).last;
      final byId = {for (final node in last.nodes) node.id: node};
      GTreeNode childFor(GTreeNode parent, int take) => parent.children
          .map((id) => byId[id]!)
          .singleWhere((node) => node.edgeLabel == 'take $take');
      final takeOne = childFor(byId[0]!, 1);
      final takeTwo = childFor(byId[0]!, 2);
      expect(_stats(takeOne).visits, greaterThan(_stats(takeTwo).visits));
      expect(last.caption, startsWith('Choose take 1:'));
      // After the root takes two, its opponent can take both remaining stones.
      // Selection must prefer that root-player loss over cooperating with us.
      final opponentWins = childFor(takeTwo, 2);
      expect(_stats(opponentWins).wins, 0);
      expect(
        _stats(opponentWins).visits,
        greaterThan(_stats(childFor(takeTwo, 1)).visits),
      );
    });

    test('repeats with the same seed and changes with a different seed', () {
      final original = _treeHistory(monteCarlo(seed: 17));
      expect(_treeHistory(monteCarlo(seed: 17)), original);
      expect(_treeHistory(monteCarlo(seed: 18)), isNot(original));
      expect(() => monteCarlo(iterations: 0), throwsRangeError);
    });
  });
}
