import 'constants.dart' show allowed_characters_for_operators;
import 'parsing.dart';
import 'values.dart';

final operator_characters = allowed_characters_for_operators;


const List<List<String>> operators = [
  ["||","&&","|"],
  ["*","/"],
  ["+","-"],
];

const List<List<String>> prefixes = [
["!"],
];

const List<List<String>> postfixes = [
["!","ß"],
];


const a = "a + b + b";



void main() {
  var rawInstruction = <String>[""];
  final klammern = <Klammer>[];
  var line = 0;
  var character = -1;
  try {
    a.split("").forEach((char) {
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

}