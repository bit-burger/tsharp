import 'package:meta/meta.dart';

const String allowed_characters_for_variables =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
const String allowed_characters_for_operators = ".:;*+-~/#=!?%&^°`´<>";
const List<String> keywords = <String>[
  "var", "let", "params", "definition", "constant", "record",
  "operator", "prefix", "postfix", "event", "delete"
  "assignment", "call", "delete",
  "return", "stop", "error",
  "if", "elif", "else", "assert",
  "while", "for",
  "use", "import",
  //Optional: ["params","assignment","call"]
];
const List<String> systemValues = [
  "true", "false", "absent", "function", "_", "infinity", "min", "max"
];
const Map<String,String> backslashable_characters = {
  "n" : "\n",
  "\\" : "\\",
  "\"" : "\"",
};

const String backslashable_characters_as_string = "\\n, \\\\, \\\"";

const List<String> forbiddenOperators = [
  "=",
];

const operator_upper_preference = [
  [";","...","."],
  [":","::",":?",":??"],
];

const operator_lower_preference = [
  ["*","/"],
  ["+","-"],
  ["%","^"],
  ["<",">","<=",">=","==","===","===="],
  ["??,?"],
  ["||","|"],
  ["&&"],
];


const prefixes = [
  ["-","+"]
];

@immutable
abstract class DebugObject {
  final int debugLine;
  final int debugCharacter;

  DebugObject(this.debugLine, this.debugCharacter);

}