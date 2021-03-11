import 'package:meta/meta.dart';
import 'executions.dart';
import 'instructions.dart';
import 'constants.dart';

@immutable
abstract class FutureValue extends DebugObject {
  FutureValue(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

// class Absent extends FutureValue {
//   Absent(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
//
// }
// absent darf einfach nur null sein,
// da jeder wert im variablen register an einem Variable oder Constant objeckt dran ist

//double, int, string, bool,absent
class PrimitiveValue extends FutureValue {
  final dynamic value;

  PrimitiveValue(this.value, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class FutureArray extends FutureValue {
  final List<FutureValue> values;

  FutureArray(this.values, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class FutureFunction extends FutureValue {
  final List<Instruction> instructions;

  FutureFunction(this.instructions, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

@immutable
abstract class Reference extends FutureValue {
  final String invocation;

  Reference(this.invocation,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class RecordReference extends Reference { RecordReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter); }

class VariableReference extends Reference { VariableReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter); }

class TypeReference extends Reference { TypeReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter); }

@immutable
abstract class Call<Function> extends FutureValue {
  final Function function;

  final List<FutureValue> parameters; //muss sowieso irgendwann in ein array konvertiert werden, oder auch nicht lol

  Call(this.function, this.parameters, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class FunctionCall extends Call<FutureValue> { FunctionCall(FutureValue function, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(function, parameters, debugLine, debugCharacter); }

class OperatorCall extends Call<String> { OperatorCall(String function, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(function, parameters, debugLine, debugCharacter); }

class PrefixCall extends OperatorCall { PrefixCall(String function, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(function, parameters, debugLine, debugCharacter);}

class PostfixCall extends OperatorCall { PostfixCall(String function, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(function, parameters, debugLine, debugCharacter) ;}


//Values: (Execution values not parse values)

//abs = null
//arr = Arr
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

  Typ(this.types);
}

@immutable
class Arr {
  final List<dynamic> items;

  Arr(List _items) : this.items = List.unmodifiable(_items);
}

@immutable
class Fnc {
  final Execution parent;
  final List<Instruction> instructions;

  Fnc(this.parent, FutureFunction function)
      : this.instructions = function.instructions;
}

@immutable
abstract class NativeFunction {
  Future<dynamic> function(List<dynamic> parameters, Execution position);

  NativeFunction();
}

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
