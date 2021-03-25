import 'package:test/test.dart';
import 'package:tsharp/future_values/values.dart';
import 'package:tsharp/direct_values/values.dart';

import 'package:tsharp/parsing/value_parsing.dart';
import 'package:tsharp/parsing/parse_debug.dart';
import 'package:tsharp/parsing/instruction_parsing.dart';
import 'package:tsharp/parsing/token_parsing.dart';

import 'package:tsharp/debug.dart';

class O extends Operator {
  O(String operator) : super(operator,null,null,null);
}

void main() {

  group("Parsing", (){
    test("Operator parsing", (){

      expect(Operator.mostImportant([O("&&"),O("*"),O("-")]).operator, "*");
      expect(Operator.mostImportant([O("-"),O("*"),O("....")]).operator, "....");

      expect((parseValue("234+234 * 4", 1, 1) as OperatorCall).function, "*");
    });

    test("Prefixes and postfixes", (){
      final parsePrefix = parseValue("!asdf..!",1,1) as PrefixCall;
      expect(parsePrefix.function, "!");
      expect(parsePrefix.parameters.length, 1);
      expect(parsePrefix.debugLine, 1);
      expect(parsePrefix.debugCharacter, 1);

      final postfix = parsePrefix.parameters.first as PostfixCall;
      expect(postfix.function,"..!");
      expect(postfix.parameters.length,1);
      expect(postfix.debugLine,1);
      expect(postfix.debugCharacter,6);

      final value = postfix.parameters.first as VariableReference;
      expect(value.invocation,"asdf");
      expect(value.debugLine,1);
      expect(value.debugCharacter,2);
    });

    test("Value parsing",(){
      expect((parseValue("_",1,1) as SimpleValue).value,SpecialValues.absent);
      expect((parseValue("absent",1,1) as SimpleValue).value,SpecialValues.absent);
      expect((parseValue("23",1,1) as SimpleValue).value,23);
      expect((parseValue("23.0",1,1) as SimpleValue).value,23.0);
      expect((parseValue("\"asdf{\\\\\"",1,1) as SimpleValue).value,"asdf{\\");
      expect(((parseValue("\$:5",1,1) as OperatorCall).parameters.first as RecordReference).invocation,"params");

    });

    test("Bad value parsing", (){
      const val = "asdf !asdf";
      try {
        final result = parseValue(val,1,1);
      } catch (error) {
        if (error is CustomParseException)
          print("***ERROR***\n\n${error.message}");
        else {
          String line = val.split("\n")[error.debugLine - 1];
          print(
             "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
                 TSException.generateErrorShow(
                   line,
                   error.debugCharacter - 1,
                   error.secondDebugCharacter==null ? null : error.secondDebugCharacter - 1,
                 ));
        }
      }
    });

    test("Token test", (){
      expect(Token("ksdjf",234,1),Token("ksdjf",234,1));
      expect([Token("ksdjf",234,1), Token("jallah",34,34)],[Token("ksdjf",234,1), Token("jallah",34,34)]);

    });

    test("Token parsing", (){

      const val = "if ads == ksdf{}\n"
          "       return(bubbel) + one\n{}()";

      try {
        final parsing = parseToTokens(val,1,1);
        for(List<Token> list in parsing) {
          print(list);
        }
      } catch (error) {
        print((error as dynamic).message);
        if (error is CustomParseException)
          print("***ERROR***\n\n${error.message}");
        else {
          String line = val.split("\n")[error.debugLine - 1];
          //print(
          //    "[NAME]:${error.debugLine}:${error.debugCharacter}:${error.message}\n" +
          //        TSException.generateErrorShow(
          //          line,
          //          error.debugCharacter - 1,
          //          error.secondDebugCharacter - 1,
          //        ));
        }
      }
    });


    test("Function call parsing", (){
      final parseValueResult = parseValue("add(     [\n"
          "3423,\n"
          "         \"je susis{{{{{{\\\\\\\"{\",\n"
          "     23456787654],           \"\\\"\\\\\")",1,1) as FunctionCall;
      expect(parseValueResult.runtimeType,FunctionCall);

      final parseValueResultFunction = parseValueResult.function as VariableReference;
      expect(parseValueResultFunction.invocation, "add");
      expect(parseValueResultFunction.debugLine, 1);
      expect(parseValueResultFunction.debugCharacter, 1);

      final parseValueResultFirstValue = parseValueResult.parameters[0] as FutureArray;
      expect(parseValueResultFirstValue.values.length, 3);
      expect(parseValueResultFirstValue.debugLine, 1);
      expect(parseValueResultFirstValue.debugCharacter, 10);

      final parseValueResultFirstValueArrayFirst = parseValueResultFirstValue.values[0] as SimpleValue;
      expect(parseValueResultFirstValueArrayFirst.value, 3423);
      expect(parseValueResultFirstValueArrayFirst.debugLine, 2);
      expect(parseValueResultFirstValueArrayFirst.debugCharacter, 1);

      final parseValueResultFirstValueArraySecond = parseValueResultFirstValue.values[1] as SimpleValue;
      expect(parseValueResultFirstValueArraySecond.value, "je susis{{{{{{\\\"{");
      expect(parseValueResultFirstValueArraySecond.debugLine, 3);
      expect(parseValueResultFirstValueArraySecond.debugCharacter, 10);

      final parseValueResultFirstValueArrayThird = parseValueResultFirstValue.values[2] as SimpleValue;
      expect(parseValueResultFirstValueArrayThird.value, 23456787654);
      expect(parseValueResultFirstValueArrayThird.debugLine, 4);
      expect(parseValueResultFirstValueArrayThird.debugCharacter, 6);

      final parseValueResultSecondValue = parseValueResult.parameters[1] as SimpleValue;
      expect(parseValueResultSecondValue.value, "\"\\");
      expect(parseValueResultSecondValue.debugLine, 4);
      expect(parseValueResultSecondValue.debugCharacter, 30);

    });

    test("instruction grouping",(){
      final parseTestString =
"""
        var    adfgfd    **=   {



}bdfdfdfdf     +d     csdfsdf
""";
      print("""
        var    adfgfd    **=   {



}bdfdfdfdf     +d     csdfsdf
""".allMatches("\n").length);

      final parseResult = parseToTokens(parseTestString, 1, 1);
    });


  });

}