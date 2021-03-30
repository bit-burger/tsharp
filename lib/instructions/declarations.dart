import 'package:tsharp/constants.dart';

import 'instructions.dart';
import 'package:meta/meta.dart';

import 'package:tsharp/debug.dart';

import 'package:tsharp/future_values/future_values.dart';
import 'package:tsharp/parsing/parse_error_handling.dart';
import 'package:tsharp/parsing/parse_debug.dart';
import 'package:tsharp/parsing/extensions.dart';

import 'helper.dart' as helper;

abstract class Declaration extends Instruction {
  Declaration(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

//eine Declaration darf keinen Wert enthalten, var a = 3 sind zwei instructions: var a; a = 3;
//eine Multiple Declaration muss den Wert direkt schon haben, nähmlich ein Array

class DeclarationChecks {
  static void atLeastTwoTokens(List<Token> tokens) {
    if (tokens.length < 2)
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) needs at least "
        "the declaration type and the identifier",
        tokens,
      );
  }

  static void atLeastFourTokens(List<Token> tokens) {
    if (tokens.length < 4)
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) needs "
        "the declaration type, identifier, an equals sign, and the value",
        tokens,
      );
    if (!forbidden_operators.contains(tokens[3]))
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) needs a value",
        tokens,
      );
  }

  static void validVariableName(String identifier, List<Token> tokens) {
    if ((keywords.contains(identifier) || standart_values.contains(identifier)))
      throw ParseException.token(
          "Identifier cannot be named after a reserved word", tokens[1]);
    if (allowed_characters_for_identifiers.containsOneOf(identifier))
      throw ParseException.token(
        "Identifier names are only allowed to contains the following characters: \n\"" +
            allowed_characters_for_identifiers +
            "\"",
        tokens[1],
      );
  }

  static void multipleVariableIdentifierIsNotClean(List<Token> tokens) {
    if (!tokens[1].clean)
      throw ParseException.token(
        "Not a valid variable group, "
        "most likely an operator is trying to combine two variable groups: \n"
        "  BAD -> [a,b,c] + [d,e]\n",
        tokens[1],
      );
  }

  static void validVariableNameWithPrefix(String prefix, List<Token> tokens) {
    final sub = tokens[1].token.substring(1);
    !(keywords.contains(tokens[1].token) &&
        standart_values.contains(tokens[1].token));
  }
}

@immutable
class MultipleVariableOrConstantDeclarationVariable extends TextDebugObject {
  final String?
      name; //null wenn man dem parameter keinen namen gibt, z.B.: [a,,c]
  final FutureValue?
      defaultValue; //wenn der im array korrespondierene Wert = absent ist,
  //in dem params befehl würde es auch reichen wenn das array zu kurz ist

  MultipleVariableOrConstantDeclarationVariable(
      this.name, this.defaultValue, int line, int character)
      : super(line, character);
}

class MultipleVariableOrConstantDeclarationRestAsArrayVariable
    extends MultipleVariableOrConstantDeclarationVariable {
  MultipleVariableOrConstantDeclarationRestAsArrayVariable(
      String? name, FutureValue? defaultValue, int line, int character)
      : super(name, defaultValue, line, character);
//REST: var [a, b = 3, c... = [2,2]] = [2,3,4,5,6] (c nimmt alle werte ab 4)
}

abstract class MultipleDeclaration extends Declaration {
  final List<MultipleVariableOrConstantDeclarationVariable>
      variables; //Variablen und ihre default Werte in einer reihe korresponierend zu dem array
  final FutureValue arrayValue;

  MultipleDeclaration(
      this.variables, this.arrayValue, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class MultipleVariableDeclaration extends MultipleDeclaration {
  MultipleVariableDeclaration(
      List<MultipleVariableOrConstantDeclarationVariable> variables,
      FutureValue arrayValue,
      int debugLine,
      int debugCharacter)
      : super(variables, arrayValue, debugLine, debugCharacter);
}

class MultipleConstantDeclaration extends MultipleDeclaration {
  MultipleConstantDeclaration(
      List<MultipleVariableOrConstantDeclarationVariable> variables,
      FutureValue arrayValue,
      int debugLine,
      int debugCharacter)
      : super(variables, arrayValue, debugLine, debugCharacter);
}

class ParameterDeclaration extends MultipleVariableDeclaration {
  ParameterDeclaration(
      List<MultipleVariableOrConstantDeclarationVariable> variables,
      int debugLine,
      int debugCharacter)
      : super(variables, RecordReference("params", debugLine, debugCharacter),
            debugLine, debugCharacter);
}

//params soll safe sein also: [a,b,c] = [0,1] => [a,b,c] = [0,1,absent]
// das ist dann auch sehr einfach mit den defaults, die dann ja absent ersetzen

abstract class SingleDeclaration extends Declaration {
  final String variable;
  final FutureValue? value;
  SingleDeclaration(
      this.variable, this.value, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

abstract class NormalIdentifierSingleDeclaration extends SingleDeclaration {
  NormalIdentifierSingleDeclaration(List<Token> tokens)
      : super(tokens[1].token, null, 0, 0) {
    if (tokens.length < 2)
      throw ParseException.tokens(
          "A declaration needs at least the declaration type and the identifier",
          tokens);
    if (!helper.isValidVariableName(tokens[1].token))
      throw ParseException.token("The identifier is not allowed", tokens[1]);
  }
}

abstract class GuaranteedValueNormalIdentifierSingleDeclaration
    extends NormalIdentifierSingleDeclaration {
  GuaranteedValueNormalIdentifierSingleDeclaration(List<Token> tokens)
      : super(tokens);
}

//var _ = 3 dann kann der variablen name = null sein (genause wie bei multpilevariabledeclarationO
class SingleVariableDeclaration extends SingleDeclaration {
  SingleVariableDeclaration(
      String variable, FutureValue value, int debugLine, int debugCharacter)
      : super(variable, value, debugLine, debugCharacter);
}

class SingleConstantDeclaration extends SingleDeclaration {
  SingleConstantDeclaration(
      String variable, FutureValue value, int debugLine, int debugCharacter)
      : super(variable, value, debugLine, debugCharacter);
}

class TypeDefinition extends SingleDeclaration {
  TypeDefinition(
      String variable, FutureValue value, int debugLine, int debugCharacter)
      : super(variable, value, debugLine, debugCharacter);
}

class RecordDefinition extends SingleDeclaration {
  RecordDefinition(
      String record, FutureValue value, int debugLine, int debugCharacter)
      : super(record, value, debugLine, debugCharacter);
}

class EventDeclaration extends SingleDeclaration {
  EventDeclaration(
      String event, FutureValue value, int debugLine, int debugCharacter)
      : super(event, value, debugLine, debugCharacter);
}

class OperatorDeclaration extends SingleDeclaration {
  OperatorDeclaration(
      String operator, FutureValue value, int debugLine, int debugCharacter)
      : super(operator, value, debugLine, debugCharacter);
}

class PrefixDeclaration extends OperatorDeclaration {
  PrefixDeclaration(
      String prefix, FutureValue value, int debugLine, int debugCharacter)
      : super(prefix, value, debugLine, debugCharacter);
}

class PostfixDeclaration extends OperatorDeclaration {
  PostfixDeclaration(
      String postfix, FutureValue value, int debugLine, int debugCharacter)
      : super(postfix, value, debugLine, debugCharacter);
}
