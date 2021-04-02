import 'package:tsharp/constants.dart';

import 'package:tsharp/instructions/instructions.dart';
import 'package:tsharp/instructions/helper.dart' as helper;
import 'package:tsharp/direct_values/direct_values.dart';

import 'parse_debug.dart';
import 'parse_error_handling.dart';
import 'extensions.dart';
import 'package:woozy_search/woozy_search.dart';
import 'package:woozy_search/woozy_results.dart';

// import 'package:flutter/foundation.dart' show compute;

//eine funktion machen die das handeln von string getrennt von kommas vereinfacht
// klammern müssen dabei beachtet werden, bsp. a = [1,{ }, 23]; b =

final alternativeSearch = Woozy(limit: 5, caseSensitive: true)
  ..addEntries(keywords.toList(growable: false));

List<Instruction> parseInstructions(
    List<List<Token>> tokensListList, ParseDebugStream stream) {
  List<Token> tokens = <Token>[];
  List<bool> newLine = <bool>[];
  for (List<Token> tokenList in tokensListList) {
    for (int i = 0; i < tokenList.length; i++) {
      tokens.add(tokenList[i]);
      newLine.add(i == 0);
    }
  }

  List<Instruction> instructions = <Instruction>[];
  int i = 0;
  List<Token> getAllTokensOnThisLine() {
    final List<Token> remainderTokens = [tokens[i]];
    i++;
    while (i < tokens.length && !newLine[i]) {
      remainderTokens.add(tokens[i]);
      i++;
    }
    i--;
    return remainderTokens;
  }

  Instruction parse() {
    switch (tokens[i].token) {
      case "var":
        return DeclarationChecks.multipleOrSingleVarOrLet(
          getAllTokensOnThisLine(),
          true,
          stream,
        );
      case "let":
        return DeclarationChecks.multipleOrSingleVarOrLet(
          getAllTokensOnThisLine(),
          false,
          stream,
        );
      case "params":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastTwoTokens(r, stream);
        DeclarationChecks.checkCleannessOfMultipleIdentifiers(r, stream);
        DeclarationChecks.maxTwoTokens(r, stream);
        return ParameterDeclaration(
          helper.parseVariableLists(
            r[1].token,
            r[1].line!,
            r[1].character!,
            stream,
          ),
          r[0].line!,
          r[0].character!,
        );
      case "define":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastFourTokens(r, stream);
        DeclarationChecks.validVariableNameWithPrefix("@", r, stream);
        DeclarationChecks.lengthIsValidTypeIdentifier(r, stream);
        return TypeDefinition(r, stream);
      case "record":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastFourTokens(r, stream);
        DeclarationChecks.validVariableNameWithPrefix("#", r, stream);
        return RecordDefinition(r, stream);
      case "event":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastFourTokens(r, stream);
        DeclarationChecks.validVariableName(r, stream);
        DeclarationChecks.isNotOnlyUnderscoreEvent(r, stream);
        DeclarationChecks.lengthIsValidTypeIdentifier(r, stream);
        return EventDeclaration(r, stream);
      case "operator":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastFourTokens(r, stream);
        return OperatorDeclaration(r, stream);
      case "prefix":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastFourTokens(r, stream);
        return PrefixDeclaration(r, stream);
      case "postfix":
        final r = getAllTokensOnThisLine();
        DeclarationChecks.atLeastFourTokens(r, stream);
        return PostfixDeclaration(r, stream);
      //gucken ob clean ist für sachen wie params und SingleFunctionCall zu unterscheidung
      //Instruction Errors sind nur für z.B.: vernudelte if-schleifen,
      // oder schief gelaufene one liner whiles
    }
    final r = getAllTokensOnThisLine();
    String suspectedKeyword = r
        .map((t) => t.token.split(" "))
        .toList(growable: false)
        .oneMatrixDown()
        .firstWhere(
            (element) =>
                element.containsOneOf(allowed_characters_for_identifiers),
            orElse: () => throw ParseException.tokens(
                  "Instruction could not be parsed",
                  r,
                ));
    if (keywords.contains(suspectedKeyword))
      throw ParseException.tokens(
        "Suspected instruction name "
        "\"$suspectedKeyword\" should be at the beginning",
        r,
      );
    else if (keywords.contains(suspectedKeyword.toLowerCase()))
      throw ParseException.tokens(
        "The case of the suspected instruction name "
                "\"$suspectedKeyword\" is wrong, t# is case sensitive" +
            ((r.first.token.startsWith(suspectedKeyword))
                ? ""
                : ". The keyword is also at the wrong place, "
                    "it should always be at the beginning"),
        r,
      );
    List<MatchResult> searchResults = alternativeSearch
        .search(suspectedKeyword)
        .where((result) => result.score > 0.25)
        .toList(growable: false);
    if (searchResults.isEmpty || searchResults.first.score == 1)
      throw ParseException.tokens(
        "Instruction could not be parsed",
        tokens,
      );
    else {
      final maxLength = searchResults
          .map((r) => r.text)
          .toList(growable: false)
          .maxStringLength;
      final values = searchResults.map((r) {
        final variableSpace = (" " * (maxLength - r.text.length)) + error_space;
        final matchPercentage =
            (r.score * 100).toStringAsPrecision(2) + "% match";
        return smaller_error_space + r.text + variableSpace + matchPercentage;
      });
      throw ParseException.tokens(
        "Instruction could not be parsed, "
        "the suspected keyword (\"$suspectedKeyword\") "
        "may be a misspelling of one of the following:\n"
        "${values.toList(growable: false).prettyPrint(ending: ",\n")}",
        r,
      );
    }
  }

  for (i; i < tokens.length; i++)
    try {
      instructions.add(parse());
    } catch (error) {
      if (error is ParseException &&
          error.importance == ParseExceptionImportance.INSTRUCTION_ERROR)
        throw ParseException.single(
          error.errors.first.message,
          error.errors.first.debugLine,
          error.errors.first.debugCharacter,
          error.errors.first.secondCharacter,
        );
      else
        stream.processException(error);
    }
  return instructions;
}

// ' ist kommentar

//BETA

// const smallExample = '''
// a = " ölajd aölskdjfj(({)\\\\ aösdlfkj
//
// "
// let func = @Int
// a = isType(<>,@Int
//
//
//
// )''';

// void main() {
// parse(smallExample,1,1);
// parse(smallExample);
// final a = parse(smallExample);
//
// print("a");

//    a... = 4  ,       b... = [asdf, 5 + 34, !5 + 6],
//12345678901234567890123456789012345678902345678901234
//   const e = """
//     a... = " alsdjf\\\\ {{\\"
//
//
//
// jallah "  ,
// b... = [asdf, 5 + 34, !5 + 6],
//
//     casdfasdf = 45 + [  !asdf! + 345!     ]
//     """;
//   const l = "a+d * c";
//   try {
//     // var a = parseVariableLists(e, 1, 1);
//     var a = operatorParse(l, 1, 1);
//     print(a);
//   } on ParseException catch (error) {
//     if (error is CustomParseException)
//       print("***ERROR***\n\n${error.message}");
//     else {
//       String line = e.split("\n")[error.debugLine - 1];
//       print(
//           "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
//               TSException.generateErrorShow(
//                 line,
//                 error.debugCharacter - 1,
//                 error.secondDebugCharacter - 1,
//               ));
//     }
//   }
// }
