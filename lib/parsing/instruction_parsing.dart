import 'package:tsharp/debug.dart';
import 'package:tsharp/instructions/instructions.dart';
import 'parse_debug.dart';
import 'parse_error_handling.dart';

import 'package:tsharp/constants.dart';

import '../future_values/future_values.dart';
import '../direct_values/simple_values.dart';

import 'package:tsharp/instructions/instructions.dart';
// import 'package:flutter/foundation.dart' show compute;

//eine funktion machen die das handeln von string getrennt von kommas vereinfacht
// klammern müssen dabei beachtet werden, bsp. a = [1,{ }, 23]; b =


List<Instruction> parseInstructions(List<List<Token>> tokensListList, ParseDebugStream stream) {
  List<Token> tokens = <Token>[];
  List<bool> newLine = <bool>[];
  for(List<Token> tokenList in tokensListList) {
    for(int i = 0; i < tokenList.length; i++) {
      tokens.add(tokenList[i]);
      newLine.add(i==0);
    }
  }

  List<Instruction> instructions = <Instruction>[];
  int i = 0;
  List<Token> getRemainderOfTokensOnLine() {
    final List<Token> remainderTokens = [tokens[i]];
    while(i + 1 < newLine.length && !newLine[i + 1]) {
      remainderTokens.add(tokens[i + 1]);
      i++;
    }
    return remainderTokens;
  }
  Instruction parse() {
    final extraLength = tokens.length - i;
    switch (tokens[i].token)  {
      case "var":

        //hier VariableDeclaration constructor aufrufen, einzelnen konstructoren suchen nach fehler und machen warnungen

      case "let":

      case "params":

      case "define":

      case "event":

      case "record":

      case "operator":

      case "prefix":

      case "postfix":

    }

  }
  for(i; i<tokens.length; i++)
    instructions.add(parse());

}

// ' ist kommentar


//BETA

const smallExample = '''
a = " ölajd aölskdjfj(({)\\\\ aösdlfkj

"
let func = @Int
a = isType(<>,@Int



)''';

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
