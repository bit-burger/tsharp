import 'package:tsharp/direct_values/simple_values.dart';

import '../future_values/values.dart';

import 'package:tsharp/constants.dart';

import 'parse_debug.dart';
import 'base_parsing.dart';
import 'instruction_parsing.dart';
import 'extensions.dart';


FutureValue parseValueNoTrim(String value, int line, int character, [bool clean = false]) {
  final trim = value.trimLeft();

  return parseValue(
      trim.trimRight(), line, character + value.length - trim.length,clean);
}

//muss getrimmed sein
FutureValue parseValue(String value, [int line, int character, bool clean = false]) {
  assert (value.trim().length == value.length);
  if (value == "\$") return RecordReference("params", line, character);
  if (value == "true") return SimpleValue(true, line, character);
  if (value == "false") return SimpleValue(false, line, character);
  if (value == "absent" || value == "_")
    return SimpleValue(SpecialValues.absent, line, character);
  if (value == "function") return FutureFunction([], line, character);
  if (value == "min") return SimpleValue(SpecialValues.min, line, character);
  if (value == "max") return SimpleValue(SpecialValues.max, line, character);
  if (value == "infinity")
    return SimpleValue(SpecialValues.infinity, line, character);

  final intParse = int.tryParse(value);
  if (intParse != null) return SimpleValue(intParse, line, character);
  final komParse = double.tryParse(value);
  if (komParse != null) return SimpleValue(komParse, line, character);
  final sub = value.substring(1);
  if (sub.containsOneOf(allowed_characters_for_identifiers)) {
    if (value[0].containsOneOf(allowed_characters_for_identifiers))
      return VariableReference(value, line, character);
    if (value[0] == "@") {
      if (sub.length == 3)
        return TypeReference(sub, line, character);
      else
        throw ParseException(
          "A type reference must only be 3 characters long (not including the @).",
          line,
          character + 1,
        );
    }
    if (value[0] == "#") return RecordReference(sub, line, character);
  }
  if(clean)
    throw ParseException(
      "This cannot be parsed as a value for an unknown reason, possible reasons are:\n"
        "  - A reserved word was used as an identifier or in a wrong context (before line, after the line, on the line)\n"
        "  - A operator is missing\n"
        "  - A operator is written as a prefix or postfix, "
              "to fix this insert at least one space on both ends or remove all space on bot ends\n"
        "  - You tried to reference a variable, constant, type, or record but not all characters were one of \"$allowed_characters_for_identifiers\"\n",
      line,
      character,
      character + value.split("\n").first.length,
    );
  return operatorParse(value, character, line);
}

//muss getrimmt sein
FutureValue operatorParse(String s, int _character, int _line) {
  final klammern = <Klammer>[];
  final List<Operator> operators = [];

  int character = _character - 1;
  int line = _line;
  int globalCount = -1;

  bool wasBackslash = false;
  Operator operator;
  final split = (s + " ").split("");

  //holt alle operatoren raus
  split.forEach((char) {
    character++;
    globalCount++;
    if (char.containsOneOf(allowed_characters_for_operators) &&
        klammern.isEmpty) {
      if (operator == null) {
        operator = Operator(char, globalCount, line, character);
      } else {
        operator.operator += char;
        operator.end = globalCount;
      }
      return;
    } else if (char == "\n") {
      //if(klammern.isNotEmpty)
      //  return;
      line++;
      character = 0;
    } else if (char == "\"") {
      if (!wasBackslash) {
        if (klammern.isEmpty||klammern.last.klammer!="\"")
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
          (klammern.last.klammer == "[" && char == "]"))
        klammern.removeLast();
    }
    if (wasBackslash) {
      wasBackslash = false;
    } else if (char == "\\") {
      wasBackslash = true;
    }
    if (operator != null) {
      operator.end = globalCount - 1;
      operators.add(operator);
      operator = null;
    }
  });

  if (operators.isEmpty) return easyValues(s, _line, _character,);
  // Guckt ob die operatoren alle a+b oder a + b sind und nicht a+ b (das wäre prefix)
  //throwt bei forbidden_operators (=) und bei ignoriert ignorierte (.)
  final filteredOperators = operators.where((operator) {
    if(forbidden_operators.contains(operator.operator))
      throw ParseException("Operator \"${operator.operator}\" not allowed", line, character);
    if(ignored_operators.contains(operator.operator))
      return false;
    if (operator.begin == 0) {
      if (split[operator.end + 1] == " ")
        throw ParseException(
            "No space between the prefix \"${operator.operator}\" and the value \"${s.substring(operator.operator.length).trim()}\" is allowed.",
            operator.line,
            operator.character + 1);
      return false;
    } else if (operator.end == s.length - 1) {
      if (split[operator.begin - 1] == " ")
        throw ParseException(
            "No space between the postfix \"${operator.operator}\" "
            "and the value \"${s.substring(0, s.trim().length - operator.operator.length).trim()}\" is allowed.",
            operator.line,
            operator.character - 1);
      return false;
    }
    return (split[operator.end + 1] == " ") ==
        (split[operator.begin - 1] == " ");
  }).toList(growable: false);
  if (filteredOperators.isEmpty && operators.length > 0) {
    if (operators.length > 2)
      throw ParseException(
          "You cannot put write too operators next to each other,"
                  " the operators in question might be: " +
              operators
                  .map((operator) =>
                      "\"" +
                      s.substring(operator.begin, operator.end + 1) +
                      "\"")
                  .toList(growable: false)
                  .prettyPrint,
          _line,
          _character,
          character,);
    String prefix = "";
    int i = 0;
    while (i < split.length &&
        split[i].containsOneOf(allowed_characters_for_operators)) {
      prefix += split[i];
      i++;
    }
    if (prefix.length > 0) {
      return PrefixCall(
          prefix,
          [
            parseValue(s.substring(i), operators.first.line,
                operators.first.character + prefix.length)
          ],
          operators.first.line,
          operators.first.character);
    }

    if (operators.length == 2) operators.removeAt(0);
    String postfix = "";
    s = s.trimLeft();
    i = s.length - 1;
    while (i > 0 && s[i].containsOneOf(allowed_characters_for_operators)) {
      postfix = s[i] + postfix;
      i--;
    }
    if (postfix.length > 0) {
      return PostfixCall(
          postfix,
          [parseValue(s.substring(0, i + 1), _line, _character)],
          operators.first.line,
          operators.first.character);
    }
  } else {
    final operator = Operator.mostImportant(filteredOperators);
    final values = [
      parseValueNoTrim(s.substring(0, operator.begin), _line, _character),
      parseValueNoTrim(s.substring(operator.end + 1), operator.line,
          operator.character + 1 + operator.length),
    ];
    return OperatorCall(
        operator.operator, values, operator.line, operator.character);
  }
  throw UnknownParseException(_line, _character);
}

//Strings,Arrays,Funktionen, muss nicht getrimmt sein
FutureValue easyValues(String s, int line, int character) {
  if (s.startsWith("\"") && s.endsWith("\""))
    return SimpleValue(
        realString(s.substring(1, s.length - 1), line, character + 1),
        line,
        character);
  else if (s.startsWith("[") && s.endsWith("]")) {
    final sub = s.substring(1,s.length - 1);
    if(sub.trim().length==0)
      return FutureArray([], line, character);
    final List<FutureValue> values = List.empty(growable: true);
    parseLists(sub, (s, line, character) {
      values.add(parseValue(s, line, character));
    }, line, character + 1);
    return FutureArray(values, line, character);
  } else if (s.startsWith("{") && s.endsWith("}"))
    return FutureFunction(/*parseToTokens(s.substring(1,s.length - 1),line,character + 1)*/null,line,character);
  else if (s.endsWith(")"))
    if(s.startsWith("("))
      return parseValueNoTrim(s.substring(1, s.length - 1), line, character);
    else {
      return functionCall(s, line, character);
    }
  //funktions call parsen
  return parseValueNoTrim(s, line, character, true);
}

//trimmed, nur von easyValues callen
FunctionCall functionCall(String s, int _line, int _character) {
  final klammern = <Klammer>[];
  bool wasBackslash = false;
  var character = _character - 1;
  var line = _line;
  var globalCharacter = -1;
  final List<String> split = s.split("");
  for(String char in split) {
    character++;
    globalCharacter++;
    if (char == "\n") {
      line++;
      character = 0;
    } else if (char == "\"") {
      if (!wasBackslash) {
        if (klammern.isEmpty||klammern.last.klammer!="\"")
          klammern.add(Klammer(char, character, line));
        else if (klammern.last.klammer == "\"") klammern.removeLast();
      }
    } else if(char == "(") {
      if (klammern.isEmpty) {
        if(split[globalCharacter - 1]==" ") {
          throw ParseException(
              "Cannot use a space, between the method and the method parameters",
              line,
              character);
        }
        final sub = s.substring(globalCharacter + 1,s.length - 1);
        final val = parseValue(s.substring(0,globalCharacter), _line, _character);
        if(sub.trim().length==0)
          return FunctionCall(val, [], _line, _character);
        final List<FutureValue> values = List.empty(growable: true);
        parseLists(sub, (s, line, character) {
          values.add(parseValue(s, line, character));
        }, line, character + 1);
        return FunctionCall(val, values, _line, _character);
      } else if (klammern.last.klammer != "\"") {
        klammern.add(Klammer("(", character, line));
      }
    } else if (char == "{" || char == "[" || char == "(") {
      if (klammern.isEmpty || klammern.last.klammer != "\"")
        klammern.add(Klammer(char, character, line));
    } else if (char == "}" || char == ")" || char == "]") {
      if (klammern.isNotEmpty && klammern.last.klammer == "\"")
        ;
      else if ((klammern.last.klammer == "{" && char == "}") ||
          (klammern.last.klammer == "[" && char == "]")
          || (klammern.last.klammer == "(" && char == ")"))
        klammern.removeLast();
    }
    if (wasBackslash) {
      wasBackslash = false;
    } else if (char == "\\") {
      wasBackslash = true;
    }
  }
  throw UnknownParseException(_line, _character);
}

String realString(String s, int line, int character) {
  character--;
  var realString = "";
  var backslash = false;
  for (int i = 0; i < s.length; i++) {
    character++;
    if (backslash) {
      if (backslashable_characters[s[i]] != null) {
        realString += backslashable_characters[s[i]];
        backslash = false;
      } else
        throw ParseException(
            "cannot backslash the character \"${s[i]}\", you can only backslash: " +
                backslashable_characters_as_string,
            line,
            character);
    } else if (s[i] == "\\") {
      backslash = true;
      continue;
    } else {
      realString += s[i];
    }
    if (s[i] == "\n") {
      character = 1;
      line++;
    }
  }

  return realString;
}
