import 'instructions.dart';
import 'package:tsharp/future_values/future_values.dart';

enum Returns { RETURN, STOP}
class TerminationInstruction extends Instruction {
  final FutureValue returnValue;
  final List<Returns> returns; //für sachen wie return return, ein RETURN repräsentiert "return", STOP repräsentiert "stop", im program wird ein fehler dann geworfen
  // und die verschiedenen funktionen müssen versuchen ihn abzubaueh, if versucht ihn dann natürlich nicht abzubauen
  TerminationInstruction(this.returnValue,this.returns,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class ErrorInstruction extends Instruction {
  final PrimitiveValue<String> message;

  ErrorInstruction(this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class Kill extends Instruction {
  Kill(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}