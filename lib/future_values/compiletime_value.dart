import 'future_values.dart';
import 'package:tsharp/instructions/instructions.dart';

abstract class CompiletimeValue extends FutureValue {
  CompiletimeValue(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class PrimitiveValue<primitive extends dynamic> extends FutureValue {
  final primitive value;

  PrimitiveValue(this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class FutureArray extends FutureValue {
  final List<FutureValue> values;
  FutureArray(this.values, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class FutureFunction extends FutureValue {
  final List<Instruction> instructions;
  FutureFunction(this.instructions, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}
