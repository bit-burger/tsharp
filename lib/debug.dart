import 'package:meta/meta.dart';

@immutable
abstract class DebugObject {
  final int debugLine;
  final int debugCharacter;

  DebugObject(this.debugLine, this.debugCharacter);

}

@immutable
abstract class TSException {


  static String generateErrorShow(String line, int character, [int secondDebugCharacter])
      => "  " + line + "\n  " + (" " * character) + ("^"*((secondDebugCharacter ?? character) - character)) + "\n";

  final String message;
  final int debugLine;
  final int debugCharacter;
  final int secondDebugCharacter;

  TSException(this.message, this.debugLine, this.debugCharacter, this.secondDebugCharacter);

}
