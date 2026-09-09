import 'package:flutter/foundation.dart';

/// A frozen, labeled sequence and the cursors operating on it at one instant.
@immutable
class SequenceTraceRow {
  SequenceTraceRow({
    required this.label,
    required Iterable<Object> values,
    Map<String, int> pointers = const {},
    Set<int> active = const {},
    Set<int> done = const {},
    this.rangeStart,
    this.rangeEnd,
  }) : values = List.unmodifiable(values.map((value) => '$value')),
       pointers = Map.unmodifiable(pointers),
       active = Set.unmodifiable(active),
       done = Set.unmodifiable(done);

  final String label;
  final List<String> values;
  final Map<String, int> pointers;
  final Set<int> active;
  final Set<int> done;
  final int? rangeStart;
  final int? rangeEnd;
}

/// Teaching state independent of the player: sequences, working variables,
/// the decision just made, and (on completion) a machine-checkable output.
@immutable
class SequenceTrace {
  SequenceTrace({
    required this.caption,
    required Iterable<SequenceTraceRow> rows,
    Map<String, Object> variables = const {},
    Iterable<Object> output = const [],
    this.result = '',
  }) : rows = List.unmodifiable(rows),
       variables = Map.unmodifiable(
         variables.map((key, value) => MapEntry(key, '$value')),
       ),
       output = List.unmodifiable(output.map((value) => '$value'));

  final String caption;
  final List<SequenceTraceRow> rows;
  final Map<String, String> variables;
  final List<String> output;
  final String result;
}
