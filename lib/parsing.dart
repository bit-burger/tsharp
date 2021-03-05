import 'package:meta/meta.dart';
import 'package:tsharp/tsharp.dart';

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

bool characterSafe(String string, String tester) {
  for(String char in string.split("")) {
    if(!tester.contains(char))
      return false;
  }
  return true;
}

Value parseValue(String value,[int line = 0, int character = 0]) {
  character -= 1;
  if(value=="true") {
    return Bol(true,line,character);
  }
  if(value=="false") {
    return Bol(false,line,character);
  }
  if(value=="absent") {
    return Abs(line,character);
  }
  if (value[0] == "\"" && value[value.length - 1] == "\"") {
    return Str(value.substring(1, value.length - 1));
  }
  final intParse = int.tryParse(value);
  if(intParse!=null)
    return Int(intParse,line,character);
  final komParse = double.tryParse(value);
  if(komParse!=null)
    return Kom(komParse,line,character);
  final List<String> split = value.split("");
  if(value.length==1) {
    if(characterSafe(value, allowed_characters_for_variables))
      return VariableGet
  } else {
    if(split[0]=="@") {

    } else if(split[0]=="#") {

    }
  }


}


// ' ist kommentar
List<Instruction> parse(String s,[int line = 0, int character = 0]) {
  var rawInstruction = <String>[""];
  final instructions = <Instruction>[];
  final klammern = <Klammer>[];
  bool wasBackslash = false;
  character -= 1;
  var globalCharacter = -1;
  final List<String> split = (s+"\n").split("");
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
        } else {
          rawInstruction.last += char;
        }
        return;
      } else if(char=="\"") {
        if(!wasBackslash) {
          if(klammern.isEmpty)
            klammern.add(Klammer(char,character,line));
          else if(klammern.last.klammer=="\"")
            klammern.removeLast();
        }
      } else if (char == "{" || char == "(" || char == "[") {
        if(klammern.isEmpty||klammern.last.klammer!="\"")
        klammern.add(Klammer(char, character, line));
      } else if (char == "}" || char == ")" || char == "]") {
        if(klammern.isNotEmpty&&klammern.last.klammer=="\"");
        else if (klammern.isEmpty)
          throw ParseException(line, character,
              "bracket \"$char\" on line $line, is unnecesary");
        else if ((klammern.last.klammer == "{" && char == "}") ||
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
      if(wasBackslash) {
        wasBackslash = false;
        print(backslashedCharacters[char]);
        rawInstruction.last += backslashedCharacters[char];
      } else if(char=="\\"){
        if(klammern.isEmpty||klammern.last.klammer!="\"")
          throw ParseException(line, character, "Cannot backslash characters outside of a string");
        final nextCharacter = split[globalCharacter+1];
        if(backslashedCharacters[nextCharacter]==null) {
          if(nextCharacter=="\n")
            throw ParseException(line,character + 1,"Cannot backslash a linebreak");
          else if(nextCharacter==" ")
            throw ParseException(line,character + 1,"Cannot backslash a space");
          else
            throw ParseException(line,character + 1,"Cannot backslash the character \"${split[globalCharacter + 1]}\"");
        }
        wasBackslash = true;
      } else {
        rawInstruction.last += char;
      }
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
      String line = s.split("\n")[error.debugLine];
      print("[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
          TS.generateErrorShow(
            line,
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
var a = " ölajd aölskdjfj(({)\\\\ aösdlfkj\\

"
let func = @Int
a = isType(<>,@Int



)''';

void main() {
  parse(smallExample);
}

