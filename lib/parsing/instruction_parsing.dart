import 'package:tsharp/instructions/instructions.dart';

import '../future_values/values.dart';
import '../constants.dart';

import 'debug.dart';
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
      variables.add(null);
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
            throw ParseException(line, character,
                "After the points, you cannot continue with the identifier name. ");
          identifier += char;
        } else if (char == " ") {
          if (points != 0 && points != 3)
            throw ParseException(line, character,
                "To designate \"$identifier\" as the rest variable, you have to use \"$identifier...\" instead of \"$identifier${"." * points}\"");
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
          throw ParseException(line, character,
              "To designate \"$identifier\" as the rest variable, you have to place the \"...\" next to the identifier without any whitespace in between as following: \"$identifier...\"");
        else
          throw UnknownParseException(line, character);
      } else if (system == 2) {
        if (char == " ")
          system = 3;
        else
          throw ParseException(line, character,
              "Between the \"=\" and the default value a space is expected. ");
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
          line, character, "After a \"=\" a default value is expected. ");
    if (identifier.length == 0)
      throw ParseException(line, character, "There has to be an identifier. ");
    if (defaultValue == null)
      defaultValue = SimpleValue(null, line, character);
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
          throw ParseException(line, character,
              "bracket \"$char\" on line $line, is unnecesary");
        else if ((klammern.last.klammer == "{" && char == "}") ||
            (klammern.last.klammer == "(" && char == ")") ||
            (klammern.last.klammer == "[" && char == "]"))
          klammern.removeLast();
        else {
          List<String> textSplit = s.split("\n");
          String openingBracketLine = textSplit[klammern.last.line - 1];
          String closingBracketLine = textSplit[line - 1];
          throw CustomParseException(
            null,
            null,
            "[NAME]:${line}:${character}:Closing bracket \"${char}\" not matching opening bracket \"${klammern.last.klammer}\"\n\n" +
                "Opening:\n" +
                ParseException.generateErrorShow(
                  openingBracketLine +
                      " (${klammern.last.line}:${klammern.last.character})",
                  klammern.last.character - 1,
                ) +
                "Closing:\n" +
                ParseException.generateErrorShow(
                  closingBracketLine + " (${line}:${character})",
                  character - 1,
                ),
          );
        }
      }
      if (wasBackslash) {
        wasBackslash = false;
      } else if (char == "\\") {
        if (klammern.isEmpty || klammern.last.klammer != "\"")
          throw ParseException(line, character,
              "Cannot backslash characters outside of a string");
        final nextCharacter = split[globalCharacter + 1];
        if (backslashable_characters[nextCharacter] == null) {
          if (nextCharacter == "\n")
            throw ParseException(
                line, character + 1, "Cannot backslash a linebreak");
          else if (nextCharacter == " ")
            throw ParseException(
                line, character + 1, "Cannot backslash a space");
          else
            throw ParseException(line, character + 1,
                "Cannot backslash the character \"${split[globalCharacter + 1]}\"");
        }
        wasBackslash = true;
      }
      rawInstruction.last += char;
    });
    if (klammern.isNotEmpty) {
      if (klammern.last.klammer == "\"")
        throw ParseException(klammern.last.line, klammern.last.character,
            "A string needs to be closed");
      else
        throw ParseException(klammern.last.line, klammern.last.character,
            "Bracket \"${klammern.last.klammer}\" is unnecessary and was not closed");
    }
  } on ParseException catch (error) {
    if (error is CustomParseException)
      print("***ERROR***\n\n${error.message}");
    else {
      String line = s.split("\n")[error.debugLine - 1];
      print(
          "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
              ParseException.generateErrorShow(
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

  try {
    var a = parseVariableLists(e, 1, 1);
    print(a);
  } on ParseException catch (error) {
    if (error is CustomParseException)
      print("***ERROR***\n\n${error.message}");
    else {
      String line = e.split("\n")[error.debugLine - 1];
      print(
          "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
              ParseException.generateErrorShow(
                line,
                error.debugCharacter - 1,
              ));
    }
  }
}
