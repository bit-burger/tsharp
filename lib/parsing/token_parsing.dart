import 'package:tsharp/constants.dart';

import 'parse_debug.dart';
import 'parse_error_handling.dart';

List<List<Token>> parseToTokens(
    String s, int line, int character, ParseDebugStream stream) {
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
          throw ParseException.single(
            "You can only use backslashes inside of a string",
            line,
            character,
          );
        else if (backslashable_characters[split[i + 1]] != null)
          throw ParseException.single(
            "You can only backslash the characters: " +
                backslashable_characters_as_string,
            line,
            character,
          );
      } else if (char == "\n") {
        line++;
        character = 0;
      } else if((char == "{" || char == "(" || char == "[") && klammern.last != "\"") {
        klammern.add(Klammer(char,line,character));
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
          throw ParseException(
            "Opening \"${klammern.last.klammer}\" not matching closing bracket \"$char\": ",
            [
              ParseExceptionPart(
                "Opening bracket: ",
                klammern.last.line,
                klammern.last.character,
              ),
              ParseExceptionPart(
                "Closing bracket: ",
                line,
                character,
              ),
            ],
            ParseExceptionImportance.EXCEPTION,
          );
      } else if (i == split.length - 1) {
        //wenn der letzte char in einer klammmer ist gibt es eh einen fehler
        // und man möchte keinen internen fehler (wenn man auf split[i + 1] zugreift)
        continue;
      } else if (char == "\"") {
        if (klammern.last.klammer != "\"")
          klammern.add(Klammer("\"", line, character));
        else if (split[i - 1] != "\\") klammern.removeLast();
      }
      tokens.last.last.token += char;
    } else {
      if (char == "\\") {
        throw ParseException.single(
          "You can only use backslashes inside of a string",
          line,
          character,
        );
      } else if (char == "'") {
        while (i != "\n") i++;
      } else if (char == "\n") {
        if (tokens.last.length != 1 || tokens.last[0].token.isNotEmpty)
          tokens.add([Token()]);
        line++;
        character = 0;
        continue parsing;
      } else if (char == "(" || char == "{" || char == "[" || char == "\"") {
        if (extendable.contains(tokens.last.last.token) ||
            (char == "{" &&
                tokens.last.last.token.isNotEmpty &&
                tokens.last.last.token[tokens.last.last.token.length - 1] !=
                    " " &&
                !allowed_characters_for_operators.contains(
                    tokens.last.last.token[tokens.last.last.token.length - 1])))
          tokens.last.add(Token());
        klammern.add(Klammer(char, line, character));
      } else if (char == " ") {
        if (tokens.last.last.token.isNotEmpty ) {
          if(ignored_by_operator_grouping.contains(tokens.last.last.token)) {
            tokens.last.add(Token());
            continue parsing;
          }
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
            character += b - i - 1;
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
  if(tokens.last.length==1&&tokens.last[0].token.isEmpty) tokens.removeLast();
  if (klammern.isNotEmpty) {
    if (klammern.last.klammer == "\"")
      throw ParseException.single(
          "A string needs to be closed",
          klammern.last.line,
          klammern.last.character,
          null,
          ParseExceptionImportance.EXCEPTION);
    else
      throw ParseException.single(
          "Bracket \"${klammern.last.klammer}\" is unnecessary and was not closed",
          klammern.last.line,
          klammern.last.character,
          null,
          ParseExceptionImportance.EXCEPTION);
  }
  return tokens;
}
