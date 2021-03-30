import 'package:meta/meta.dart';
import 'package:tsharp/debug.dart';

export 'conditionals_and_loops.dart';
export 'declarations.dart';
export 'importing.dart';
export 'scope_manipulation.dart';
export 'variable_use.dart';

@immutable
abstract class Instruction extends TextDebugObject {
  Instruction(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}
