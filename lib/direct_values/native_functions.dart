import 'package:meta/meta.dart';


import 'simple_values.dart' show TSFunction,TSType;
import 'package:tsharp/execution/execution.dart';

@immutable
abstract class NativeFunction extends TSFunction {
  Future<dynamic> function(List<dynamic> parameters, Execution position);

  NativeFunction();
}

//kein wert (nur im record register)

class NonCheckedNativeFunction extends NativeFunction {
  final Future<dynamic> Function(List<dynamic> parameters, Execution position)
  _function;

  NonCheckedNativeFunction(this._function);

  @override
  Future<dynamic> function(List parameters, Execution position) {
    return _function(parameters, position);
  }
}

class ParameterLengthCheckedNativeFunction extends NativeFunction {
  final int minParameters;
  final int maxParameters;

  ParameterLengthCheckedNativeFunction(
      this._function, this.minParameters, this.maxParameters);

  final Future<dynamic> Function(List<dynamic> parameters, Execution position)
  _function;

  @override
  Future function(List parameters, Execution position) {}
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

  TypeCheckedNativeFunction(this._function,this.checks,List<TSType> types, defaultValue) : super(types, defaultValue);

}
