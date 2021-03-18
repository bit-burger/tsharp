import 'package:meta/meta.dart';

import '../direct_values/direct_values.dart';
import '../future_values/values.dart';
import '../execution/execution.dart';

@immutable
class Library {
  final Map<String, Typ> types;
  final Map<String, dynamic> variables;
  final Map<String, Record> records;
  final Map<String, String> operators;
  final Map<String, String> prefixes;
  final Map<String, String> postfixes;
  final List<String> events;

  Library({
    this.types = const {},
    this.variables = const {},
    this.records = const {},
    this.operators = const {},
    this.prefixes = const {},
    this.postfixes = const {},
    this.events = const [],
  });

  Library.fromExecution(Execution execution, [List<String> events = const []])
      : this.types = execution.types,
        this.variables = execution.variables,
        this.records = execution.records,
        this.operators = execution.operators,
        this.prefixes = execution.prefixes,
        this.postfixes = execution.postfixes,
        this.events = events;
}
