import 'package:meta/meta.dart';

const String allowed_characters_for_variables =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
const String allowed_characters_for_operators = ".:;*+-~/#=!?%&^°`´<>";
const List<String> keywords = <String>[
  "var", "let", "params", "definition", "constant", "record",
  "operator", "prefix", "postfix",
  "assignment", "call", "delete",
  "return", "stop", "error",
  "if", "elif", "else", "assert",
  "while", "for",
  "use", "import",
  //Optional: ["params","assignment","call"]
];
const Map<String,String> backslashedCharacters = {
  "n" : "\n",
  "\\" : "\\",
  "\"" : "\"",
};

@immutable
abstract class DebugObject {
  final int debugLine;
  final int debugCharacter;

  DebugObject(this.debugLine, this.debugCharacter);

}