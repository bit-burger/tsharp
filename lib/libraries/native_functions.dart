import 'package:tsharp/direct_values/direct_values.dart';
import 'package:tsharp/libraries/location.dart';
import 'package:tsharp/execution/execution.dart';
import 'package:tsharp/execution/root_execution.dart';

import '../direct_values/simple_values.dart' show TSType;
import '../execution/runtime_classes.dart' show RunTimeException, Stack;

import 'value_helpers.dart';

typedef NativeFunctionParams = Future<dynamic> Function(
    List<dynamic> parameters,
    RootExecution rootExecution,
    Execution firstNonClosureExecution,
    Execution parentExecution,
    String functionName,
    Stack stack);
typedef NativeFunctionNumberParams = Future<dynamic> Function(
    num one, num two, String functionName, Stack stack);

//kein wert (nur im record register)

class NonCheckedNativeFunction<L extends NativeLibraryLocation>
    extends NativeFunction<L> {
  final NativeFunctionParams _function;

  NonCheckedNativeFunction(this._function, L location) : super(location);

  @override
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      String functionName,
      Stack stack) {
    return _function(parameters, rootExecution, firstNonClosureExecution,
        parentExecution, functionName, stack);
  }
}

class ParameterLengthCheckedNativeFunction<L extends NativeLibraryLocation>
    extends NativeFunction<L> {
  final int? minParameters; //null means no constraints
  final int? maxParameters; //null means no constraints

  ParameterLengthCheckedNativeFunction(
      this._function, this.minParameters, this.maxParameters, L location)
      : super(location);

  NativeFunctionParams _function;

  @override
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      String functionName,
      Stack stack) {
    if ((minParameters == null || parameters.length >= minParameters!) &&
        (maxParameters == null|| parameters.length <= maxParameters!))
      return _function(parameters, rootExecution, firstNonClosureExecution,
          parentExecution, functionName, stack);
    throw RunTimeException(
        "The function \"$functionName\" " +
            (minParameters != null
                ? "should get at least $minParameters parameters"
                : "") +
            (minParameters != null && maxParameters != null ? " and " : " ") +
            (maxParameters != null ? "max only $maxParameters parameters" : ""),
        this.location,
        stack);
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
  final NativeFunctionParams _function;
  final List<TypeCheck> checks;

  TypeCheckedNativeFunction(
      this._function, this.checks, List<TSType> types, defaultValue)
      : super(types, defaultValue);
}

class TwoNumbersNativeFunction extends NativeFunction {
  final NativeFunctionNumberParams _function;

  @override
  Future<dynamic> function(
      List<dynamic> parameters,
      RootExecution rootExecution,
      Execution firstNonClosureExecution,
      Execution parentExecution,
      String functionName,
      Stack stack) {
    if (parameters.length != 2)
      throw RunTimeException(
          "You cannot give the function \"$functionName\" ${parameters.length} parameters,"
          "as it requires exactly 2 number parameters",
          this.location,
          stack);
    if ((Helper.isType(parameters[0], TSType.int) ||
            Helper.isType(parameters[0], TSType.kom)) &&
        (Helper.isType(parameters[1], TSType.int) ||
            Helper.isType(parameters[1], TSType.kom)))
      return _function(parameters[0], parameters[1], functionName, stack);
    return _function(0,0,functionName,stack);
  }

  TwoNumbersNativeFunction(this._function, NativeLibraryLocation location)
      : super(location);
}
