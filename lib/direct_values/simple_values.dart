import 'package:meta/meta.dart';

import 'package:tsharp/constants.dart' show anonymous_function_name;

import '../instructions/instructions.dart';
import '../future_values/values.dart';
import '../execution/execution.dart';
import '../execution/root_execution.dart';
import '../execution/runtime_classes.dart';
import '../libraries/location.dart';

enum SpecialValues {
  max,
  min,
  infinity,
  negative_infinity,
  absent
} //negative infinity = operator vor infinity

//abs = SpecialValues.absent
//arr = List
//bol = bol
//fnc = Fnc
//int = int
//kom = double
//rng = Rng
//str = String
//typ = Typ

@immutable
class Rng {
  final int start;
  final int end;

  Rng(this.start, this.end);
}

enum TSType { abs, arr, bol, fnc, int, kom, rng, str, typ }

@immutable
class Typ {
  final Set<TSType> types;

  Typ operator +(Typ other) {
    return Typ(this.types..addAll(other.types));
  }

  Typ operator -(Typ other) {
    return Typ(this.types.intersection(other.types));
  }

  Typ.single(TSType single) : this.types = Set.of(List.unmodifiable([single]));

  Typ(this.types);
}

@immutable
abstract class Logic<L> {}

abstract class TSFunction<L> extends Logic<L> {
  final dynamic location;

  TSFunction(this.location);
}

class Fnc extends TSFunction<dynamic> {
  final RootExecution rootExecution;

  final Execution firstNonClosureExecution;

  final Execution parentExecution;

  final int line;

  final int character;

  final String name;

  final List<Instruction> instructions;

  Fnc copyWithNewName([String name = anonymous_function_name]) {
    return Fnc.fromInstructionList(
      this.instructions,
      this.rootExecution,
      this.firstNonClosureExecution,
      this.parentExecution,
      this.location,
      this.line,
      this.character,
      name,
    );
  }

  Fnc.fromInstructionList(
    this.instructions,
    this.rootExecution,
    this.firstNonClosureExecution,
    this.parentExecution,
    dynamic location,
    this.line,
    this.character, [
    this.name = anonymous_function_name,
  ]) : super(location);

  Fnc(
    FutureFunction function,
    this.rootExecution,
    this.firstNonClosureExecution,
    this.parentExecution,
    dynamic location,
    this.line,
    this.character, [
    this.name = anonymous_function_name,
  ]) : this.instructions = function.instructions,super(location);

}

@immutable
abstract class NativeFunction<L extends NativeLibraryLocation> extends TSFunction<L> {
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      String functionName,
      Stack stack);

  NativeFunction(L location) : super(location);
}