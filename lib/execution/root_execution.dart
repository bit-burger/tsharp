import 'package:tsharp/debug.dart';

import '../future_values/future_values.dart';
import '../direct_values/simple_values.dart';
import '../direct_values/record_values.dart';
import '../libraries/library.dart';

import 'runtime_classes.dart';
import 'execution.dart';

typedef OnError = void Function(String completeMessage, String errorMessage, TSException exception, int debugLine, int debugCharacter, bool parsingError);
typedef OnLibrary = Library Function(String name, bool isUse, int debugLine, int debugCharacter);
typedef OnOutput = void Function(String output);

class RootExecution extends Execution {
  RootExecution.standart(Map<String, dynamic> variables, Map<String, Typ> types, Map<String, Record> records, Map<String, String> operators, Map<String, String> prefix, Map<String, String> postfix, this.possibleEvents, this.onLibrary, this.onInput, this.onOutput, this.onError, ) : super(variables, types, records, operators, prefix, postfix);

  void callEvent(String event) {
  }

  final List<String> possibleEvents;

  final Library Function(String name, bool isUse, int debugLine, int debugCharacter) onLibrary;
  final Future<String> Function(String input) onInput;
  final void Function(String output) onOutput;
  final OnError onError;

  factory RootExecution(List<Library> libraries, Future<String> Function(String input) onInput,  onOutput, OnLibrary onLibrary, OnError onError, ) {
    final Map<String, Typ> types = {};
    final Map<String, dynamic> variables = {};
    final Map<String, Record> records = {};
    final Map<String, String> operators = {};
    final Map<String, String> prefixes = {};
    final Map<String, String> postfixes = {};
    final List<String> events = [];
    for(Library library in libraries) {
      types.addAll(library.types);
      variables.addAll(library.variables);
      records.addAll(library.records);
      operators.addAll(library.operators);
      prefixes.addAll(library.prefixes);
      postfixes.addAll(library.postfixes);
    }

    return RootExecution.standart(variables, types, records, operators, prefixes, postfixes, events, onLibrary, onInput, onOutput, onError,);
  }

  void run() {

  }

}