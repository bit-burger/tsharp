import 'package:meta/meta.dart';

import 'package:tsharp/constants.dart';
import 'package:tsharp/debug.dart';

import 'extensions.dart';

@immutable
class ParseException extends TSException {
  ParseException(String message, int debugLine, int debugCharacter)
      : super(message, debugLine, debugCharacter, null);
}

class UnknownParseException extends ParseException {
  UnknownParseException(int debugLine, int debugCharacter)
      : super("Unknown Expression. ", debugLine, debugCharacter);
}

class CustomParseException extends ParseException {
  CustomParseException(String message, int line, int character)
      : super(message, line, character);
}


@immutable
class Klammer {
  final String klammer;
  final int character;
  final int line;

  Klammer(this.klammer, this.character, this.line);
}


class Operator {
  String operator;
  final int begin;
  int end;
  final int line;
  final int character;

  int get length => end - begin;


  
  static Operator mostImportant(List<Operator> competingOperators) {
    List<Operator> upper_preference =
    List.filled(operator_higher_precedence.length, null);
    List<Operator> lower_preference =
    List.filled(operator_lower_precedence.length, null);
    Operator middle_preference;

    competingOperators:
    for (Operator competingOperator in competingOperators) {
      int i = 0;
      for (List<String> operators in operator_higher_precedence) {
        if (operators.contains(competingOperator.operator) &&
            upper_preference[i] == null) {
          upper_preference[i] = competingOperator;
          break competingOperators;
        }
        i++;
      }
      i = 0;
      for (List<String> operators in operator_lower_precedence) {
        if (operators.contains(competingOperator.operator) &&
            lower_preference[i] == null) {
          upper_preference[i] = competingOperator;
          break competingOperators;
        }
        i++;
      }
      if (middle_preference == null) middle_preference = competingOperator;
    }
    upper_preference = upper_preference
        .where((element) => element != null)
        .toList(growable: false);
    lower_preference = lower_preference
        .where((element) => element != null)
        .toList(growable: false);
    return upper_preference.firstNullable ??
        middle_preference ??
        lower_preference.firstNullable;
  }

  Operator(this.operator, this.begin, this.line, this.character);
}