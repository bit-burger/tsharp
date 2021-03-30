import 'package:meta/meta.dart';
import 'constants.dart';

@immutable
abstract class DebugObject {}


@immutable
abstract class TextDebugObject {
  final int debugLine;
  final int debugCharacter;
  final int? secondCharacter;

  TextDebugObject(this.debugLine, this.debugCharacter, [this.secondCharacter]);

  @override
  bool operator ==(Object other) =>
      other is TextDebugObject &&
      other.debugLine == this.debugLine &&
      other.debugCharacter == this.debugCharacter &&
      other.secondCharacter == this.debugCharacter;
}

class TSException {
  TSException._();
  static String generateErrorShow(String line, int character,
          [int? secondDebugCharacter]) =>
      error_space +
      line +
      "\n" +
      error_space +
      (" " * character) +
      ("^" * (((secondDebugCharacter ?? character) + 1) - character)) +
      "\n";
}
