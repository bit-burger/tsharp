import 'package:meta/meta.dart';
import 'package:tsharp/libraries/location.dart';

import 'simple_values.dart' show TSFunction, TSType;
import 'package:tsharp/execution/execution.dart';
import 'package:tsharp/execution/root_execution.dart';

import '../execution/runtime_classes.dart' show Stack;

typedef NativeFunctionParams = Future<dynamic> Function(
    List<dynamic> parameters,
    RootExecution rootExecution,
    Execution firstNonClosureExecution,
    Execution parentExecution,
    Stack stack);

@immutable
abstract class NativeFunction<L extends NativeLibraryLocation> extends TSFunction<L> {
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      Stack stack);

  NativeFunction(L location) : super(location);
}

//kein wert (nur im record register)

class NonCheckedNativeFunction<L extends NativeLibraryLocation> extends NativeFunction<L> {

  final NativeFunctionParams _function;

  NonCheckedNativeFunction(this._function, L location) : super(location);

  @override
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      Stack stack) {
    return _function(
        parameters, rootExecution, firstNonClosureExecution, parentExecution, stack);
  }
}

class ParameterLengthCheckedNativeFunction<L extends NativeLibraryLocation> extends NativeFunction<L> {
  final int minParameters;
  final int maxParameters;

  ParameterLengthCheckedNativeFunction(
      this._function, this.minParameters, this.maxParameters, L location) : super(location);

  final Future<dynamic> Function(List<dynamic> parameters, Execution position)
      _function;

  @override
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      Stack stack) {

  }
}

abstract class TypeCheck<DefaultValueType> {
  final List<TSType> types;
  final DefaultValueType defaultValue;
  TypeCheck(this.types, this.defaultValue);
}

class SingleTypeCheck extends TypeCheck<List<dynamic>> {
  SingleTypeCheck(List<TSType> types, List defaultValue)
      : super(types, defaultValue);
}

class RestTypeCheck extends TypeCheck<dynamic> {
  RestTypeCheck(List<TSType> types, dynamic defaultValue)
      : super(types, defaultValue);
}

class TypeCheckedNativeFunction extends TypeCheck<dynamic> {
  final Future<dynamic> Function(
          List<dynamic> parameters, List<dynamic> rest, Execution position)
      _function;
  final List<TypeCheck> checks;

  TypeCheckedNativeFunction(
      this._function, this.checks, List<TSType> types, defaultValue)
      : super(types, defaultValue);
}
