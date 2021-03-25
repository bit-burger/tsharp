import 'package:meta/meta.dart';
import 'package:tsharp/constants.dart';
import 'package:tsharp/debug.dart';

import 'parse_debug.dart';



List<List<Token>> parseToTokens(String s, int line, int character) {
  final List<List<Token>> tokens = <List<Token>>[
    [Token()]
  ];
  final klammern = <Klammer>[];
  character -= 1;
  final List<String> split = s.split("");

  int i = 0;
  parsing:
  for (i; i < split.length; i++) {
    final char = split[i];
    character++;
    if (klammern.isNotEmpty) {
      if (char == "\\") {
        if (klammern.last.character != "\"")
          throw Exception();
        else if (backslashable_characters[split[i + 1]] != null)
          throw Exception();
      } else if (char == "\n") {
        line++;
        character = 0;
      } else if (char == ")" || char == "}" || char == "]") {
        if (brackets[klammern.last.klammer] == char) {
          if (klammern.length == 1 &&
              i < split.length - 1 &&
              split[i + 1] != " " &&
              split[i + 1] != "\n" &&
              split[i + 1] != "(" &&
              split[i + 1] != "[" &&
              !allowed_characters_for_operators.contains(split[i + 1])) {
            tokens.last.last.token += char;
            tokens.last.add(Token());
            klammern.removeLast();
            continue parsing;
          }
          klammern.removeLast();
        } else
          throw Exception();
      } else if (i == split.length - 1) {
        //wenn der letzte char in einer klammmer ist gibt es eh einen fehler
        // und man möchte keinen internen fehler (wenn man auf split[i + 1] zugreift)
        continue;
      } else if (char == "\"") {
        if (klammern.last.klammer != "\"")
          throw Exception();
        else if (split[i - 1] != "\\") split.removeLast();
      }
      tokens.last.last.token += char;
    } else {
      if (char == "\\") {
        throw Exception();
      } else if (char == "'") {
        while (i != "\n") i++;
      } else if (char == "\n") {
        if (tokens.last.length != 1 || tokens.last[0].token.isNotEmpty)
          tokens.add([Token()]);
        line++;
        character = 0;
        continue parsing;
      } else if (char == "(" || char == "{" || char == "[" || char == "\"") {
        if (extendable.contains(tokens.last.last.token))
          tokens.last.add(Token());
        klammern.add(Klammer(char, character, line));
      } else if (char == " ") {
        if (tokens.last.last.token.isNotEmpty) {
          int j = i + 1;
          while (j < split.length && split[j] == " ") j++;
          var operator = "";
          var b = j;
          while (b < split.length)
            if (allowed_characters_for_operators.contains(split[b])) {
              operator += split[b];
              b++;
            } else if (split[b] == " ")
              break;
            else {
              character += j - i - 1;
              i = j - 1;
              //i und character wird später noch eins plus gemacht (wegen der for-schleife) und character++;
              tokens.last.add(Token());
              continue parsing;
            }
          while (b < split.length && split[b] == " ") b++;
          if (forbidden_operators.contains(operator)) {
            character += j - i - 1;
            i = j - 1;
            //i und character wird später noch eins plus gemacht (wegen der for-schleife) und character++;
            tokens.last.add(Token());
            continue parsing;
          } else {
            tokens.last.last.clean = false;
            tokens.last.last.token += s.substring(i, b);
            //i und character wird später noch eins plus gemacht (wegen der for-schleife) und character++;
            character += i - b;
            i = b - 1;
          }
        }
        continue parsing;
        //vorspringen bis zum nächsten richtigen und alles andere machen mit operator
      }
      if (tokens.last.last.token.isEmpty) {
        tokens.last.last.line = line;
        tokens.last.last.character = character;
      }
      tokens.last.last.token += char;
    }
  }
  for (List<Token> tokenList in tokens) {

  }
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
  return tokens;
}
