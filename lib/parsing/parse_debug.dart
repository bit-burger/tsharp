import 'package:meta/meta.dart';

import 'package:tsharp/constants.dart';
import 'package:tsharp/debug.dart';

import 'extensions.dart';


@immutable
class Klammer {
  final String klammer;
  final int character;
  final int line;

  Klammer(this.klammer, this.character, this.line);
}

class Token {
  String token;
  int line;
  int character;
  bool clean = true;
  Token([this.token = "", this.line, this.character]);

  @override
  bool operator ==(Object other) =>
      other is Token &&
      line == other.line &&
      character == other.character &&
      token == other.token;

  @override
  String toString() => token == ""
      ? "[EMPTY] "
      : "\"$token\" ($line,$character)" + (clean ? "" : "[NC]");
}


class Operator {
  String operator;
  final int begin;
  int end;
  final int line;
  final int character;

  int get length => end - begin;

  static Operator mostImportant(List<Operator> competingOperators) {
    int highestOperator = 0;
    int highestOperatorRanking = operator_precedence_length;
    _:
    for (int i = 0; i < competingOperators.length; i++) {
      for (int o = 0; o < operator_higher_precedence.length; o++) {
        if (operator_higher_precedence[o]
            .contains(competingOperators[i].operator)) {
          if (highestOperatorRanking > o) {
            highestOperator = i;
            highestOperatorRanking = o;
          }
          continue _;
        }
      }
      for (int o = 0; o < operator_lower_precedence.length; o++) {
        if (operator_lower_precedence[o]
            .contains(competingOperators[i].operator)) {
          if (highestOperatorRanking > o + 3) {
            highestOperator = i;
            highestOperatorRanking = o + 3;
          }
          continue _;
        }
      }
      if (highestOperatorRanking > operator_higher_precedence.length - 1) {
        highestOperator = i;
        highestOperatorRanking = operator_higher_precedence.length - 1;
        continue _;
      }
    }
    return competingOperators[highestOperator];
  }

  Operator(this.operator, this.begin, this.line, this.character);
}
