import 'package:meta/meta.dart';

import 'package:tsharp/debug.dart';

import '../instructions/instructions.dart';

export 'runtime_values.dart';

export 'compiletime_value.dart';

@immutable
abstract class FutureValue extends DebugObject {
  FutureValue(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

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
