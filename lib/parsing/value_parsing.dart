import 'package:tsharp/direct_values/simple_values.dart';

import '../future_values/future_values.dart';

import 'package:tsharp/constants.dart';

import 'parse_debug.dart';
import 'parse_error_handling.dart';
import 'list_parsing.dart';
import 'instruction_parsing.dart';
import 'extensions.dart';

FutureValue parseValueNoTrim(
    String value, int line, int character, ParseDebugStream stream,
    [bool clean = false]) {
  final trim = value.trimLeft();

  return parseValue(trim.trimRight(), line,
      character + value.length - trim.length, stream, clean);
}

//muss getrimmed sein
FutureValue parseValue(
    String value, int line, int character, ParseDebugStream stream,
    [bool clean = false]) {
  assert(value.trim().length == value.length);
  if (value == "\$") return RecordReference("params", line, character);
  if (value == "\$\$") return RecordReference("args", line, character);
  if (value == "true") return PrimitiveValue(true, line, character);
  if (value == "false") return PrimitiveValue(false, line, character);
  if (value == "absent" || value == "_")
    return PrimitiveValue(SpecialValues.absent, line, character);
  if (value == "function") return FutureFunction([], line, character);
  if (value == "min") return PrimitiveValue(SpecialValues.min, line, character);
  if (value == "max") return PrimitiveValue(SpecialValues.max, line, character);
  if (value == "infinity")
    return PrimitiveValue(SpecialValues.infinity, line, character);

  assert(!standart_values.contains(value));

  final intParse = int.tryParse(value);
  if (intParse != null) return PrimitiveValue(intParse, line, character);
  final komParse = double.tryParse(value);
  if (komParse != null) return PrimitiveValue(komParse, line, character);
  final sub = value.substring(1);
  if (sub.containsOneOf(allowed_characters_for_identifiers)) {
    if (value[0].containsOneOf(allowed_characters_for_identifiers)) if (keywords
        .contains(value))
      throw ParseException.single(
        "Identifier cannot be a keyword. ",
        line,
        character + 1,
      );
    else
      return VariableReference(value, line, character);
    if (value[0] == "@") {
      if (sub.length == 3)
        return TypeReference(sub, line, character);
      else
        throw ParseException.single(
          "A type reference must only be 3 characters long (not including the @).",
          line,
          character + 1,
        );
    }
    if (value[0] == "#") return RecordReference(sub, line, character);
  }
  if (clean) {
    return easyValues(value, line, character, stream);
  } else {
    return operatorParse(value, character, line, stream);
  }
}

//muss getrimmt sein
FutureValue operatorParse(
    String s, int _character, int _line, ParseDebugStream stream) {
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
        if (klammern.isEmpty || klammern.last.klammer != "\"")
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
    if (operator != null) {
      operator.end = globalCount - 1;
      operators.add(operator);
      operator = null;
    }
  });

  if (operators.isEmpty) return easyValues(s, _line, _character, stream);
  // Guckt ob die operatoren alle a+b oder a + b sind und nicht a+ b (das wäre prefix)
  //throwt bei forbidden_operators (=) und bei ignoriert ignorierte (.)
  final filteredOperators = operators.where((operator) {
    if (forbidden_operators.contains(operator.operator))
      throw ParseException.single(
          "Operator \"${operator.operator}\" not allowed", line, character);
    if (ignored_operators.contains(operator.operator)) return false;
    if (operator.begin == 0) {
      if (split[operator.end + 1] == " ")
        throw ParseException.single(
            "No space between the prefix \"${operator.operator}\" and the value \"${s.substring(operator.operator.length).trim()}\" is allowed.",
            operator.line,
            operator.character + 1);
      return false;
    } else if (operator.end == s.length - 1) {
      if (split[operator.begin - 1] == " ")
        throw ParseException.single(
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
      throw ParseException.single(
        "You cannot put write too operators next to each other,"
                " the operators in question might be: " +
            operators
                .map((operator) =>
                    "\"" + s.substring(operator.begin, operator.end + 1) + "\"")
                .toList(growable: false)
                .prettyPrint,
        _line,
        _character,
        character,
      );
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
            parseValue(
                s.substring(i),
                operators.first.line,
                operators.first.character + prefix.length,
                stream,
                operators.length < 2)
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
          [
            parseValue(s.substring(0, i + 1), _line, _character, stream,
                operators.length < 2)
          ],
          operators.first.line,
          operators.first.character);
    }
    throw ParseException.singleWithExtraString("To values next to eachother have to either be:\n"
        "  - Separated by a komma in an array, or parameter list\n"
        "  - Separated by an operator (not prefix or postfix)\n", _line, _character, s);
  } else {
    final mostImportantOperator = Operator.mostImportant(filteredOperators);
    operators.where((element) => element != mostImportantOperator);
    bool before = false;
    bool after = false;
    for (Operator operator in operators) {
      if (operator.end < mostImportantOperator.begin)
        before = true;
      else if (operator.begin > mostImportantOperator.end) after = true;
    }
    final values = [];
    try {
      values.add(parseValueNoTrim(
        s.substring(0, mostImportantOperator.begin),
        _line,
        _character,
        stream,
        before,
      ));
    } catch (error) {
      stream.processException(error);
    }
    try {
      values.add(parseValueNoTrim(
        s.substring(mostImportantOperator.end + 1),
        mostImportantOperator.line,
        mostImportantOperator.character + 1 + mostImportantOperator.length,
        stream,
        after,
      ));
    } catch (error) {
      stream.processException(error);
    }
    return OperatorCall(mostImportantOperator.operator, values,
        mostImportantOperator.line, mostImportantOperator.character);
  }
  assert(false);
}

//Strings,Arrays,Funktionen, muss nicht getrimmt sein
FutureValue easyValues(
    String s, int line, int character, ParseDebugStream stream) {
  if (s.startsWith("\"") && s.endsWith("\""))
    return PrimitiveValue(
        realString(s.substring(1, s.length - 1), line, character + 1),
        line,
        character);
  else if (s.startsWith("[") && s.endsWith("]")) {
    final sub = s.substring(1, s.length - 1);
    return FutureArray(parseList(sub, line, character + 1, stream), line, character);
  } else if (s.startsWith("{") && s.endsWith("}"))
    return FutureFunction(
        /*parseToTokens(s.substring(1,s.length - 1),line,character + 1)*/ null,
        line,
        character);
  else if (s.endsWith(")")) if (s.startsWith("("))
    return parseValueNoTrim(
        s.substring(1, s.length - 1), line, character, stream);
  else {
    return functionCall(s, line, character, stream);
  }
  //funktions call parsen
  throw ParseException.single(
    "This cannot be parsed as a value for an unknown reason, possible reasons are:\n"
    "  - A reserved word was used as an identifier or in a wrong context (before line, after the line, on the line)\n"
    "  - A operator is missing\n"
    "  - A operator is written as a prefix or postfix, "
    "to fix this insert at least one space on both ends or remove all space on bot ends\n"
    "  - You tried to reference a variable, constant, type, or record but not all characters were one of \"$allowed_characters_for_identifiers\"\n",
    line,
    character,
    character + s.split("\n").first.length,
  );
}

//trimmed, nur von easyValues callen
FunctionCall functionCall(
    String s, int _line, int _character, ParseDebugStream stream) {
  final klammern = <Klammer>[];
  bool wasBackslash = false;
  var character = _character - 1;
  var line = _line;
  var globalCharacter = -1;
  final List<String> split = s.split("");
  for (String char in split) {
    character++;
    globalCharacter++;
    if (char == "\n") {
      line++;
      character = 0;
    } else if (char == "\"") {
      if (!wasBackslash) {
        if (klammern.isEmpty || klammern.last.klammer != "\"")
          klammern.add(Klammer(char, character, line));
        else if (klammern.last.klammer == "\"") klammern.removeLast();
      }
    } else if (char == "(") {
      if (klammern.isEmpty) {
        if (split[globalCharacter - 1] == " ") {
          throw ParseException.single(
              "Cannot use a space, between the method and the method parameters",
              line,
              character);
        }
        final sub = s.substring(globalCharacter + 1, s.length - 1);
        final val = parseValue(
            s.substring(0, globalCharacter), _line, _character, stream);
        return FunctionCall(val, parseList(sub, line, character + 1, stream),
            _line, _character);
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
          (klammern.last.klammer == "[" && char == "]") ||
          (klammern.last.klammer == "(" && char == ")")) klammern.removeLast();
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
        throw ParseException.single(
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

List<FutureValue> parseList(
    String s, int line, int character, ParseDebugStream stream) {
  final List<FutureValue> values = <FutureValue>[];
  if(s.length==1)
    return values;
  parseLists(s, (_s, line, character) {
    try {
      values.add(parseValue(_s, line, character, stream));
    } catch (e) {
      stream.processException(e);
    }
  }, line, character);
  return values;
}
