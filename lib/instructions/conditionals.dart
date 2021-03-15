import 'package:meta/meta.dart';

import '../future_values/values.dart';
import '../direct_values/simple_values.dart';

import 'instructions.dart';
import 'closure.dart';


@immutable
abstract class Conditional extends Instruction {
  final FutureValue bool;

  Conditional(this.bool,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class If extends Conditional {
  final Closure body;

  If(this.body,FutureValue bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

class IfElse extends If {
  final Closure alternative;

  IfElse(this.alternative,Closure body, FutureValue bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);

}

class While extends Conditional {
  final Fnc body;

  While(this.body,FutureValue bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

class For extends Instruction {
  final Fnc body;
  final FutureValue iterator;

  For(this.body,this.iterator,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

enum Returns { RETURN, STOP}
class TerminationInstruction extends Instruction {
  final FutureValue returnValue;
  final List<Returns> returns; //für sachen wie return return, ein RETURN repräsentiert "return", STOP repräsentiert "stop", im program wird ein fehler dann geworfen
  // und die verschiedenen funktionen müssen versuchen ihn abzubaueh, if versucht ihn dann natürlich nicht abzubauen
  TerminationInstruction(this.returnValue,this.returns,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class ErrorInstruction extends Instruction {
  final SimpleValue<String> message;

  ErrorInstruction(this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}


class Assertion extends Instruction {
  final FutureValue bool;

  Assertion(this.bool, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}


class SingleFunctionCall extends Instruction {
  final Call call; //muss vom typ "Call" sein also entweder: FunctionCall, PrefixCall, PostfixCall, und OperatorCall

  SingleFunctionCall(this.call,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}