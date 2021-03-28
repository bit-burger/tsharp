import 'instructions.dart';
import 'package:tsharp/future_values/future_values.dart';

class VariableAssignment extends Instruction {
  final String variable;
  final FutureValue value;

  VariableAssignment(this.variable, this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class Delete extends Instruction {
  final String deletion;

  Delete(this.deletion, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class SingleFunctionCall extends Instruction {
  final Call call; //muss vom typ "Call" sein also entweder: FunctionCall, PrefixCall, PostfixCall, und OperatorCall

  SingleFunctionCall(this.call,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}
