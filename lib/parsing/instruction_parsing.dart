import 'package:tsharp/debug.dart';
import 'package:tsharp/instructions/instructions.dart';

import 'package:tsharp/constants.dart';

import '../future_values/values.dart';
import '../direct_values/simple_values.dart';

import 'parse_debug.dart';
import 'extensions.dart';
import 'base_parsing.dart';
import 'value_parsing.dart';

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
        if (char.containsOneOf(allowed_characters_for_variables)) {
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
List<Instruction> parse(String s, int line, int character) {
  var rawInstruction = <String>[""];
  final instructions = <Instruction>[];
  final klammern = <Klammer>[];
  bool wasBackslash = false;
  character -= 1;
  var globalCharacter = -1;
  //schlechter code, denn am ende ist noch ein extra character ??
  final List<String> split = (s + "\n").split("");
  try {
    split.forEach((char) {
      character++;
      globalCharacter++;
      if (char == " ") {
        if (klammern.isNotEmpty) {
          rawInstruction.last += char;
        } else if (rawInstruction.last.isNotEmpty) {
          rawInstruction.add("");
        }
        return;
      } else if (char == "\n") {
        line++;
        character = -1;
        if (klammern.isEmpty) {
          print(rawInstruction);
          rawInstruction = [""];
          //instruction code
          //es muss noch ein = zeichen dort sein (bei event, operator, prefix, postfix)
          //operator %& = {
          //  return $:0 + $:1
          //}
        } else {
          rawInstruction.last += char;
        }
        return;
      } else if (char == "\"") {
        if (!wasBackslash) {
          if (klammern.isEmpty)
            klammern.add(Klammer(char, character, line));
          else if (klammern.last.klammer == "\"") klammern.removeLast();
        }
      } else if (char == "{" || char == "(" || char == "[") {
        if (klammern.isEmpty || klammern.last.klammer != "\"")
          klammern.add(Klammer(char, character, line));
      } else if (char == "}" || char == ")" || char == "]") {
        if (klammern.isNotEmpty && klammern.last.klammer == "\"")
          ;
        else if (klammern.isEmpty)
          throw ParseException(
              "bracket \"$char\" on line $line, is unnecessary",
              line,
              character);
        else if ((klammern.last.klammer == "{" && char == "}") ||
            (klammern.last.klammer == "(" && char == ")") ||
            (klammern.last.klammer == "[" && char == "]"))
          klammern.removeLast();
        else {
          List<String> textSplit = s.split("\n");
          String openingBracketLine = textSplit[klammern.last.line - 1];
          String closingBracketLine = textSplit[line - 1];
          throw CustomParseException(
            "[NAME]:${line}:${character}:Closing bracket \"${char}\" not matching "
                    "opening bracket \"${klammern.last.klammer}\"\n\n"
                    "Opening:\n" +
                TSException.generateErrorShow(
                  openingBracketLine +
                      " (${klammern.last.line}:${klammern.last.character})",
                  klammern.last.character - 1,
                ) +
                "Closing:\n" +
                TSException.generateErrorShow(
                  closingBracketLine + " (${line}:${character})",
                  character - 1,
                ),
            null,
            null,
          );
        }
      }
      if (wasBackslash) {
        wasBackslash = false;
      } else if (char == "\\") {
        if (klammern.isEmpty || klammern.last.klammer != "\"")
          throw ParseException(
              "Cannot backslash characters outside of a string",
              line,
              character);
        final nextCharacter = split[globalCharacter + 1];
        if (backslashable_characters[nextCharacter] == null) {
          if (nextCharacter == "\n")
            throw ParseException(
                "Cannot backslash a linebreak", line, character + 1);
          else if (nextCharacter == " ")
            throw ParseException(
                "Cannot backslash a space", line, character + 1);
          else
            throw ParseException(
                "Cannot backslash the character \"${split[globalCharacter + 1]}\"",
                line,
                character + 1);
        }
        wasBackslash = true;
      }
      rawInstruction.last += char;
    });
    if (klammern.isNotEmpty) {
      if (klammern.last.klammer == "\"")
        throw ParseException("A string needs to be closed", klammern.last.line,
            klammern.last.character);
      else
        throw ParseException(
            "Bracket \"${klammern.last.klammer}\" is unnecessary and was not closed",
            klammern.last.line,
            klammern.last.character);
    }
  } on ParseException catch (error) {
    if (error is CustomParseException)
      print("***ERROR***\n\n${error.message}");
    else {
      String line = s.split("\n")[error.debugLine - 1];
      print(
          "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
              TSException.generateErrorShow(
                line,
                error.debugCharacter - 1,
              ));
    }
  }
  return null;
}

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
              ));
    }
  }
}
