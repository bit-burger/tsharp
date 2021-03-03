import 'package:meta/meta.dart';

import 'instructions.dart';
import 'values.dart';
import 'executions.dart';
import 'constants.dart';

class ParseException extends DebugObject {
  final String message;

  ParseException(int debugLine, int debugCharacter, this.message) : super(debugLine,debugCharacter);
}

class CustomParseException extends ParseException {
  CustomParseException(int line, int character, String message)
      : super(line, character, message);
}

class Klammer {
  final String klammer;
  final int character;
  final int line;

  Klammer(this.klammer, this.character, this.line);
}

class TS {
  static String generateErrorShow(String line, int character) {
    return "  " + line + "\n  " + (" " * character) + "^\n";
  }

  Function(int lineNumber, int characterNumber, String line, String message,
      String fullError) onError;

  Future<String> Function(String message) input;

  Function(String) output;

  TS({
    @required this.output,
    @required this.input,
    @required this.onError,
  });
}

//var i = 0 sind zwei verschiedene instructions, Declration und assignment
//operator: :%"!?/&|*+-^°=.`´


// ' ist kommentar
List<Instruction> parse(String s, [List<String> parameters]) {
  var rawInstruction = <String>[""];
  final instructions = <Instruction>[];
  final klammern = <Klammer>[];
  var line = 0;
  var character = -1;
  try {
    s.split("").forEach((char) {
      character++;
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
        } else {
          rawInstruction.last += char;
        }
        return;
      } else if (char == "{" || char == "(" || char == "<" || char == "[") {
        if (klammern.isNotEmpty && klammern.last == "<") return;
        klammern.add(Klammer(char, character, line));
      } else if (char == "}" || char == ")" || char == "]" || char == ">") {
        if (klammern.isEmpty)
          throw ParseException(line, character,
              "bracket \"$char\" on line $line, is unnecesary");
        else if (klammern.last.klammer == "<") {
          if (char == ">") {
            klammern.removeLast();
          }
        } else if ((klammern.last.klammer == "{" && char == "}") ||
            (klammern.last.klammer == "(" && char == ")") ||
            (klammern.last.klammer == "[" && char == "]"))
          klammern.removeLast();
        else {
          List<String> textSplit = s.split("\n");
          String openingBracketLine = textSplit[klammern.last.line];
          String closingBracketLine = textSplit[line];
          throw CustomParseException(
            null,
            null,
            "[NAME]:${line}:${character}:Closing bracket \"${char}\" not matching opening bracket \"${klammern.last.klammer}\"\n\n" +
                "Opening:\n" +
                TS.generateErrorShow(
                  openingBracketLine +
                      " (${klammern.last.line}:${klammern.last.character})",
                  klammern.last.character,
                ) +
                "Closing:\n" +
                TS.generateErrorShow(
                  closingBracketLine + " (${line}:${character})",
                  character,
                ),
          );
        }
      }
      rawInstruction.last += char;
    });
    if (klammern.isNotEmpty) {
      if (klammern.last.klammer == "<")
        throw ParseException(klammern.last.line, klammern.last.character,
            "String has to be closed");
      else
        throw ParseException(klammern.last.line, klammern.last.character,
            "Bracket \"${klammern.last.klammer}\" is unnecessary");
    }
  } on ParseException catch (error) {
    if (error is CustomParseException)
      print("***ERROR***\n\n${error.message}");
    else {
      String line = s.split("\n")[error.debugLine];
      print("[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
          TS.generateErrorShow(
            line + " (${klammern.last.line}:${klammern.last.character})",
            error.debugCharacter,
          ));
    }
  }
  return null;
}

//BETA

const s = '''
{ öalsdjf }
''';

const smallExample = '''
var a
let func = @Int
a = isType(<>,@Int



){{{{{{
''';