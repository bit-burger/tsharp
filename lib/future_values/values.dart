import 'package:meta/meta.dart';

import 'package:tsharp/debug.dart';

import '../instructions/instructions.dart';


@immutable
abstract class FutureValue extends DebugObject {
  FutureValue(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class SimpleValue<primitive extends dynamic> extends FutureValue {
  final primitive value;

  SimpleValue(this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class FutureArray extends FutureValue {
  final List<FutureValue> values;

  FutureArray(this.values, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class FutureFunction extends FutureValue {
  final List<Instruction> instructions;

  FutureFunction(this.instructions, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

@immutable
abstract class Reference extends FutureValue {
  final String invocation;

  Reference(this.invocation, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class RecordReference extends Reference { RecordReference(String invocation, int debugLine, int debugCharacter) : super(invocation,  debugLine, debugCharacter);}

class VariableReference extends Reference { VariableReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter);}

class TypeReference extends Reference { TypeReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter); }

@immutable
abstract class Call<Function> extends FutureValue {
  final Function function;

  final List<FutureValue> parameters;

  Call(this.function, this.parameters, int debugLine, int debugCharacter) : super(debugLine, debugCharacter); //muss sowieso irgendwann in ein array konvertiert werden, oder auch nicht lol

}

class FunctionCall extends Call<FutureValue> { FunctionCall(FutureValue function, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(function, parameters, debugLine, debugCharacter); }

class OperatorCall extends Call<String> { OperatorCall(String operator, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(operator, parameters, debugLine, debugCharacter); }

class PrefixCall extends OperatorCall { PrefixCall(String prefix, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(prefix, parameters, debugLine, debugCharacter);}

class PostfixCall extends OperatorCall { PostfixCall(String postfix, List<FutureValue> parameters,int debugLine, int debugCharacter) : super(postfix, parameters, debugLine, debugCharacter) ;}


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
