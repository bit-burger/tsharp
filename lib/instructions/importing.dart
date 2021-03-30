import 'instructions.dart';
import 'package:tsharp/future_values/future_values.dart';

class Usage extends Instruction {
  final String library;

  Usage(this.library, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class ImportDeclaration extends SingleDeclaration {
  ImportDeclaration(
      String name, FutureValue value, int debugLine, int debugCharacter)
      : super(name, value, debugLine, debugCharacter);
}

//import _ = "asdf.ts"    asdf()
//import asdf = "asdf.ts"   asdf_asdf()
//use asdf    asdf()
