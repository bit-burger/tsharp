import 'future_values.dart';

class RunTimeValue extends FutureValue {
  RunTimeValue(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

abstract class Reference extends RunTimeValue {
  final String invocation;

  Reference(this.invocation, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class RecordReference extends Reference { RecordReference(String invocation, int debugLine, int debugCharacter) : super(invocation,  debugLine, debugCharacter);}

class VariableReference extends Reference { VariableReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter);}

class TypeReference extends Reference { TypeReference(String invocation, int debugLine, int debugCharacter) : super(invocation, debugLine, debugCharacter); }

abstract class Call<Function> extends RunTimeValue {
  final Function function;

  final List<FutureValue> parameters;

  Call(this.function, this.parameters, int debugLine, int debugCharacter) : super(debugLine, debugCharacter); //muss sowieso irgendwann in ein array konvertiert werden, oder auch nicht lol

}

class FunctionCall extends Call<FutureValue> { FunctionCall(FutureValue function, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(function, parameters, debugLine, debugCharacter); }

class OperatorCall extends Call<String> { OperatorCall(String operator, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(operator, parameters, debugLine, debugCharacter); }

class PrefixCall extends OperatorCall { PrefixCall(String prefix, List<FutureValue> parameters, int debugLine, int debugCharacter) : super(prefix, parameters, debugLine, debugCharacter);}

class PostfixCall extends OperatorCall { PostfixCall(String postfix, List<FutureValue> parameters,int debugLine, int debugCharacter) : super(postfix, parameters, debugLine, debugCharacter) ;}
