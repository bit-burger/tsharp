import 'package:meta/meta.dart';
import 'constants.dart';

@immutable
abstract class DebugObject {
  final int debugLine;
  final int debugCharacter;
  final int secondCharacter;

  DebugObject(this.debugLine, this.debugCharacter,[this.secondCharacter]);

}

@immutable
abstract class TSException {


  static String generateErrorShow(String line, int character, [int secondDebugCharacter])
      => error_space + line + "\n" + error_space + (" " * character) + ("^"*(((secondDebugCharacter ?? character) + 1) - character)) + "\n";

  final String message;
  final int debugLine;
  final int debugCharacter;
  final int secondDebugCharacter;

  TSException(this.message, this.debugLine, this.debugCharacter, this.secondDebugCharacter);

}
