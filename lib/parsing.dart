import 'package:meta/meta.dart';
import 'package:tsharp/instructions.dart';
import 'package:tsharp/tsharp.dart';

import 'values.dart' as values;
import 'newvalue.dart';
import 'executions.dart';
import 'constants.dart';

class ParseException extends DebugObject {
  final String message;

  ParseException(int debugLine, int debugCharacter, this.message)
      : super(debugLine, debugCharacter);
}

class UnknownParseException extends ParseException {
  UnknownParseException(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter, "Unknown Expression. ");
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

bool containsOneOf(String string, String tester) {
  for (String char in string.split("")) {
    if (!tester.contains(char)) return false;
  }
  return true;
}
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
        if (containsOneOf(char, allowed_characters_for_variables)) {
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
      defaultValue = PrimitiveValue(null, line, character);
    if (points == 3) {
      variables.add(MultipleVariableOrConstantDeclarationRestAsArrayVariable(
          identifier, defaultValue,_line,_character));
      return;
    }
    variables.add(MultipleVariableOrConstantDeclarationVariable(
        identifier, defaultValue,_line,_character));
  }, line, character);
  return variables;
}
//ohne [ und ] aber character fängt bei [ an
//funktion nur in easyValues abspielen
FutureValue parseArray(String s, int line, int character) {
  final List<FutureValue> values = List.empty(growable: true);

  parseLists(s, (s, line, character) {
    values.add(parseValue(s,line,character));
  }, line, character + 1);
  return FutureArray(values, line, character);
}

void parseLists(
    String s,
    void Function(String s, int line, int character) forEach,
    int line,
    int character) {
  var listItem = "";
  final klammern = <Klammer>[];
  bool wasBackslash = false;
  int itemLine;
  int itemCharacter;
  character -= 1;
  bool onKomma() {
    if (klammern.isEmpty) {
      if (itemLine == null) {
        forEach(null, line, character);
      } else {
        forEach(listItem.trim(), itemLine, itemCharacter);
        itemLine = null;
        itemCharacter = null;
      }
      listItem = "";
      return true;
    }
    return false;
  }

  final List<String> split = s.split("");
  split.forEach((char) {
    character++;
    if (char == ",") {

      if(onKomma()) return;
    } else if (char == "\n") {
      line++;
      character = 0;
      listItem += char;
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
      else if ((klammern.last.klammer == "{" && char == "}") ||
          (klammern.last.klammer == "(" && char == ")") ||
          (klammern.last.klammer == "[" && char == "]")) klammern.removeLast();
    }
    if (itemCharacter == null && char != " ") {
      itemLine = line;
      itemCharacter = character;
    }
    if (wasBackslash) {
      wasBackslash = false;
      listItem += backslashedCharacters[char];
    } else if (char == "\\") {
      wasBackslash = true;
    } else {
      listItem += char;
    }
  });
  onKomma();
}

FutureValue parseValueNoTrim(String value, int line, int character) {
  final trim = value.trimLeft();

  return parseValue(trim.trimRight(),line,character + value.length  - trim.length);
}

//muss getrimmed sein
FutureValue parseValue(String value, int line, int character) {
  assert (value.trim().length <= value.length);
  if(value == "\$")
    return RecordReference("#params", line, character);
  if (value == "true")
    return PrimitiveValue(true, line, character);
  if (value == "false")
    return PrimitiveValue(false, line, character);
  if (value == "absent" || value =="_")
    return PrimitiveValue(null, line, character);
  if(value == "function")
    return FutureFunction([], line, character);
  final intParse = int.tryParse(value);
  if (intParse != null) return PrimitiveValue(intParse, line, character);
  final komParse = double.tryParse(value);
  if (komParse != null) return PrimitiveValue(komParse, line, character);
  final sub = value.substring(1);
  if(containsOneOf(sub, allowed_characters_for_variables)) {
    if(containsOneOf(value[0], allowed_characters_for_variables))
      return VariableReference(value,line,character);
    if(value[0]=="@") {
      if (sub.length == 3)
        return TypeReference(sub, line, character);
      else
        throw ParseException(line, character + 1,
            "A type reference must only be 3 characters long (not including the @).");
    }
    if(value[0]=="#")
      return RecordReference(sub, line, character);
  }
  return operatorParse(value, character, line);
}

class Instruction {}

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
                TS.generateErrorShow(
                  openingBracketLine +
                      " (${klammern.last.line}:${klammern.last.character})",
                  klammern.last.character - 1,
                ) +
                "Closing:\n" +
                TS.generateErrorShow(
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
        if (backslashedCharacters[nextCharacter] == null) {
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
              TS.generateErrorShow(
                line,
                error.debugCharacter - 1,
              ));
    }
  }
  return null;
}

class Operator {
  String operator;
  int begin;
  int end;

  Operator(this.operator, this.begin);
}
//muss getrimmt sein
FutureValue operatorParse(String s, int _character, int _line) {
  final klammern = <Klammer>[];
  final List<Operator> operators = [];

  int character = _character - 1;
  int line = _line - 1;
  int globalCount = -1;

  bool wasBackslash = false;
  Operator operator;
  final split = (s + " ").split("");

  split.forEach((char) {
    character++;
    globalCount++;
    if (containsOneOf(char, allowed_characters_for_operators)&&klammern.isEmpty) {
      if(operator==null) {
        operator = Operator(char, globalCount);
      } else {
        operator.operator += char;
      }
      return;
    } else if (char == "\n") {
      line++;
      character = 0;
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
      else if ((klammern.last.klammer == "{" && char == "}") ||
          (klammern.last.klammer == "(" && char == ")") ||
          (klammern.last.klammer == "[" && char == "]")) klammern.removeLast();
    }
    if (wasBackslash) {
      wasBackslash = false;
    } else if (char == "\\") {
      wasBackslash = true;
    }
    if(operator!=null) {
      operator.end = globalCount-1;
      operators.add(operator);
      operator = null;
    }
  });

  if(operators.isEmpty)
    return easyValues(s,_line,_character);
  // Guckt ob die operatoren alle a+b oder a + b sind und nicht a+ b (das wäre prefix)
  final filteredOperators = operators.where((operator){
    if(operator.begin==0||split[operator.begin-1]==" ")
      return split[operator.end + 1] == " ";
    return split[operator.end + 1] != " ";
  }).toList(growable: false);
  if(filteredOperators.isEmpty&&operators.length<3&&operators.length>0) {
    var operator = "";
    int i = 0;
    while (i < split.length &&
        containsOneOf(split[i], allowed_characters_for_operators)) {
      operator += split[i];
      i++;
    }
    if (operator.length > 0) {
      return PrefixCall(operator, [parseValue(s.substring(i), line,
          character + operator.length)], line,
          character + operator.length);
    }
    operator = "";
    i = split.length - 1;
    while (i != 0 && containsOneOf(split[i], allowed_characters_for_operators)) {
      operator = split[i] + operator;
      i--;
    }
    if (operator.length > 0) {
      return PostfixCall(
          operator, [parseValue(s.substring(0, i + 1),line,character)], line, character);
    }
  }
}


//Strings,Arrays,Funktionen
FutureValue easyValues(String s, int line, int character) {
  if(s.startsWith("\"")&&s.endsWith("\""))
    return PrimitiveValue(s.substring(1,s.length-1), line, character);
  if(s.startsWith("[")&&s.endsWith("]"))
    return parseArray(s.substring(1,s.length-1), line, character);
  if(s.startsWith("{")&&s.endsWith("}"))
    return PrimitiveValue(s.substring(1,s.length-1), line, character);
  if(s.startsWith("(")&&s.endsWith(")"))
    return parseValueNoTrim(s.substring(1,s.length-1), line, character);
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
    a... = 4  ,       b... = [asdf, 5 + 34, !5 + 6],
    
    c = 45 + [    asdf+345!    ]
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
              TS.generateErrorShow(
                line,
                error.debugCharacter - 1,
              ));
    }
  }
}
