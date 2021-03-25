import 'package:tsharp/debug.dart';
import 'package:tsharp/instructions/instructions.dart';

import 'package:tsharp/constants.dart';

import '../future_values/values.dart';
import '../direct_values/simple_values.dart';

import 'parse_debug.dart';
import 'extensions.dart';
import 'base_parsing.dart';
import 'value_parsing.dart';
// import 'package:flutter/foundation.dart' show compute;

//eine funktion machen die das handeln von string getrennt von kommas vereinfacht
// klammern müssen dabei beachtet werden, bsp. a = [1,{ }, 23]; b =

List<MultipleVariableOrConstantDeclarationVariable> parseVariableLists(
    String identifiers, int line, int character) {
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
    var identifier = "";
    var points = 0;
    var system = 0; //0 = nothing, 1 = " ", 2 = " =", 3 = " = "
    FutureValue defaultValue;
    for (int i = 0; i < s.length; i++) {
      final char = s[i];
      if (system == 0) {
        if (char.containsOneOf(allowed_characters_for_identifiers)) {
          if (points > 0)
            throw ParseException(
                "After the points, you cannot continue with the identifier name. ",
                line,
                character);
          identifier += char;
        } else if (char == " ") {
          if (points != 0 && points != 3)
            throw ParseException(
                "To designate \"$identifier\" as the rest variable, "
                "you have to use \"$identifier...\" "
                "instead of \"$identifier${"." * points}\"",
                line,
                character);
          system = 1;
        } else if (char == ".") {
          points++;
        } else {
          throw UnknownParseException(line, character);
        }
      } else if (system == 1) {
        if (char == " ")
          ;
        else if (char == "=")
          system = 2;
        else if (char == ".")
          throw ParseException(
              "To designate \"$identifier\" as the rest variable, "
              "you have to place the \"...\" next to the identifier "
              "without any whitespace in between as following: \"$identifier...\"",
              line,
              character);
        else
          throw UnknownParseException(line, character);
      } else if (system == 2) {
        if (char == " ")
          system = 3;
        else
          throw ParseException(
              "Between the \"=\" and the default value a space is expected. ",
              line,
              character);
      } else {
        if (char != " ") {
          defaultValue = parseValue(s.substring(i), line, character);
          print("");
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
      throw ParseException(
          "After a \"=\" a default value is expected. ", line, character);
    if (identifier.length == 0)
      throw ParseException("There has to be an identifier. ", line, character);
    if (identifier == "_") identifier = null;
    if (defaultValue == null)
      defaultValue = SimpleValue(SpecialValues.absent, line, character);
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

// ' ist kommentar


//BETA

const smallExample = '''
a = " ölajd aölskdjfj(({)\\\\ aösdlfkj

"
let func = @Int
a = isType(<>,@Int



)''';

void main() {
  // parse(smallExample,1,1);
  // parse(smallExample);
  // final a = parse(smallExample);
  //
  // print("a");

//    a... = 4  ,       b... = [asdf, 5 + 34, !5 + 6],
//12345678901234567890123456789012345678902345678901234
  const e = """
    a... = " alsdjf\\\\ {{\\" 
    
    
    
jallah "  ,       
b... = [asdf, 5 + 34, !5 + 6],
    
    casdfasdf = 45 + [  !asdf! + 345!     ]
    """;
  const l = "a+d * c";
  try {
    // var a = parseVariableLists(e, 1, 1);
    var a = operatorParse(l, 1, 1);
    print(a);
  } on ParseException catch (error) {
    if (error is CustomParseException)
      print("***ERROR***\n\n${error.message}");
    else {
      String line = e.split("\n")[error.debugLine - 1];
      print(
          "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
              TSException.generateErrorShow(
                line,
                error.debugCharacter - 1,
                error.secondDebugCharacter - 1,
              ));
    }
  }
}
