import 'package:tsharp/constants.dart';
import 'package:tsharp/future_values/future_values.dart';
import 'package:tsharp/parsing/parse_debug.dart';
import 'instructions.dart';
import 'package:tsharp/parsing/list_parsing.dart';
import 'package:tsharp/parsing/extensions.dart';
import 'package:tsharp/parsing/value_parsing.dart';
import 'package:tsharp/parsing/parse_error_handling.dart';
import 'package:tsharp/direct_values/direct_values.dart';

bool isPureClosure(Token token) =>
    token.token[0] == "{" && token.token[0] == "}" && token.clean;

bool isPureArray(Token token) =>
    token.token[0] == "[" && token.token[0] == "]" && token.clean;

bool isCorrectPrimitiveType<T>(FutureValue v) => v is! PrimitiveValue || v.value is T;

List<MultipleVariableOrConstantDeclarationVariable> parseVariableLists(
    String identifiers, int line, int character, ParseDebugStream stream) {
  final List<MultipleVariableOrConstantDeclarationVariable> variables = [];
  parseLists(identifiers, (s, _line, _character) {
    if (s == null) {
      variables.add(MultipleVariableOrConstantDeclarationVariable(
          null, null, _line, _character));
      return;
    } else if (s == "...") {
      variables.add(MultipleVariableOrConstantDeclarationRestAsArrayVariable(
          null, null, _line, _character));
      return;
    }
    int line = _line;
    int character = _character;
    String? identifier = "";
    var points = 0;
    var system = 0; //0 = nothing, 1 = " ", 2 = " =", 3 = " = "
    FutureValue? defaultValue;
    for (int i = 0; i < s.length; i++) {
      final char = s[i];
      if (system == 0) {
        if (char.containsOneOf(allowed_characters_for_identifiers)) {
          if (points > 0)
            throw ParseException.single(
                "After the points, you cannot continue with the identifier name. ",
                line,
                character);
          identifier = identifier! + char;
        } else if (char == " ") {
          if (points != 0 && points != 3)
            throw ParseException.single(
                "To designate \"$identifier\" as the rest variable, "
                "you have to use \"$identifier...\" "
                "instead of \"$identifier${"." * points}\"",
                line,
                character);
          system = 1;
        } else if (char == ".") {
          points++;
        } else {
          throw ParseException.unknown(line, character);
        }
      } else if (system == 1) {
        if (char == " ")
          ;
        else if (char == "=")
          system = 2;
        else if (char == ".")
          throw ParseException.single(
              "To designate \"$identifier\" as the rest variable, "
              "you have to place the \"...\" next to the identifier "
              "without any whitespace in between as following: \"$identifier...\"",
              line,
              character);
        else
          throw ParseException.unknown(line, character);
      } else if (system == 2) {
        if (char == " ")
          system = 3;
        else
          throw ParseException.single(
              "Between the \"=\" and the default value a space is expected. ",
              line,
              character);
      } else {
        if (char != " ") {
          defaultValue = parseValue(s.substring(i), line, character, stream);
          break;
        }
      }
      if (char == "\n") {
        character == 1;
        line++;
      } else
        character++;
    }
    if (system == 2 && defaultValue == null)
      throw ParseException.single(
          "After a \"=\" a default value is expected. ", line, _character, character);
    if (identifier!.length == 0)
      throw ParseException.single(
          "There has to be an identifier. ", line, _character);
    if (identifier == "_") identifier = null;
    if (defaultValue == null)
      defaultValue = PrimitiveValue(SpecialValues.absent, line, character);
    if (points == 3) {
      variables.add(MultipleVariableOrConstantDeclarationRestAsArrayVariable(
          identifier, defaultValue, _line, _character));
      return;
    }
    variables.add(MultipleVariableOrConstantDeclarationVariable(
        identifier, defaultValue, _line, _character));
  }, line, character);
  return variables;
}
