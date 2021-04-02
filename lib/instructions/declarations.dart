import 'package:tsharp/constants.dart';

import 'instructions.dart';
import 'package:meta/meta.dart';

import 'package:tsharp/debug.dart';

import 'package:tsharp/parsing/parse_error_handling.dart';
import 'package:tsharp/parsing/parse_debug.dart';
import 'package:tsharp/parsing/extensions.dart';

import 'package:tsharp/future_values/future_values.dart';

import 'package:tsharp/direct_values/direct_values.dart';

import 'helper.dart' as helper;

abstract class Declaration extends Instruction {
  Declaration(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}
// z.b.: ValidOperator auf stream, damit der Wert noch richtig überprüft werden kann

//eine Declaration darf keinen Wert enthalten, var a = 3 sind zwei instructions: var a; a = 3;
//eine Multiple Declaration muss den Wert direkt schon haben, nähmlich ein Array

class DeclarationChecks {
  static Declaration multipleOrSingleVarOrLet(
      List<Token> tokens, bool isVariable, ParseDebugStream stream) {
    FutureValue? futureValue;
    if (tokens.length > 2) {
      DeclarationChecks.atLeastFourTokens(tokens, stream);
      futureValue = helper.parseValueOfToken(tokens[3], stream);
    } else {
      DeclarationChecks.atLeastTwoTokens(tokens, stream);
    }
    if (helper.isSomeList(tokens[1])) {
      DeclarationChecks.checkCleannessOfMultipleIdentifiers(tokens, stream);
      if (futureValue != null &&
          !helper.isCorrectCompileTimeType<FutureArray>(futureValue))
        throw ParseException.token(
          "A multiple ${isVariable ? "variable" : "constant"} "
          "declaration, has to be initialised with an array",
          tokens[3],
        );
      return isVariable
          ? MultipleVariableDeclaration(
              helper.parseVariableLists(
                tokens[1].token.substring(1, tokens[1].token.length - 1),
                tokens[1].line!,
                tokens[1].character!,
                stream,
              ),
              futureValue,
              tokens[0].line!,
              tokens[0].character!,
            )
          : MultipleConstantDeclaration(
              helper.parseVariableLists(
                tokens[1].token.substring(1, tokens[1].token.length - 1),
                tokens[1].line!,
                tokens[1].character!,
                stream,
              ),
              futureValue,
              tokens[0].line!,
              tokens[0].character!,
            );
    } else {
      DeclarationChecks.validVariableName(tokens, stream);
      return isVariable
          ? SingleVariableDeclaration(tokens[1].token, futureValue,
              tokens[0].line!, tokens[0].character!)
          : SingleConstantDeclaration(tokens[1].token, futureValue,
              tokens[0].line!, tokens[0].character!);
    }
  }

  static void atLeastTwoTokens(List<Token> tokens, ParseDebugStream stream,
      [bool hasToBeFour = false]) {
    if (tokens.length < 2 && !hasToBeFour)
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) needs at least "
        "the declaration type and the identifier",
        tokens,
      );
    if (tokens.length == 3) if (tokens[2].token == "=")
      throw ParseException.single("After the \"=\" a value is expected",
          tokens[2].line!, tokens[2].character!);
    else if (!hasToBeFour)
      throw ParseException.token(
          "This declaration does not require \"${tokens[2].token}\"",
          tokens[2]);
    if (tokens.length > 4)
      throw ParseException.tokens(
        "This declaration is too long",
        tokens.getRange(3, tokens.length).toList(growable: false),
      );
  }

  static void maxTwoTokens(List<Token> tokens, ParseDebugStream stream) {
    if (tokens.length > 2) if (tokens[2].token == "=")
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) "
        "does not allow a initialisation value",
        tokens.sublist(2).toList(growable: false),
      );
    else
      throw ParseException.tokens(
        "This Declaration (${tokens.first.token}) "
        "should only consist of ${tokens[0].token} "
        "and ${tokens[1].token}",
        tokens.sublist(2).toList(growable: false),
      );
  }

  static void atLeastFourTokens(List<Token> tokens, ParseDebugStream stream) {
    atLeastTwoTokens(tokens, stream, true);
    if (tokens.length < 4)
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) needs "
        "the declaration type, identifier, an equals sign, and the value",
        tokens,
      );
    if (tokens[2].token != "=")
      throw ParseException.tokens(
        "This declaration (${tokens.first.token}) needs an equals sign "
        "to receive a value",
        tokens,
      );
  }

  static void checkCleannessOfMultipleIdentifiers(
      List<Token> tokens, ParseDebugStream stream) {
    if (!tokens[1].clean)
      throw ParseException.token(
        "Not a valid variable group, "
        "most likely an operator is trying to combine two variable groups",
        tokens[1],
      );
  }

  static void validVariableName(List<Token> tokens, ParseDebugStream stream,
      [String? identifier]) {
    identifier ??= tokens[1].token;
    if ((keywords.contains(identifier) || standart_values.contains(identifier)))
      stream.tokenError(
          "Identifier cannot be named after a reserved word", tokens[1]);
    if (allowed_characters_for_identifiers.containsOneOf(identifier))
      stream.tokenError(
        "Identifier names are only allowed to contains the following characters: \n" +
            smaller_error_space +
            "\"$allowed_characters_for_identifiers\"",
        tokens[1],
      );
  }

  static void validVariableNameWithPrefix(
      String prefix, List<Token> tokens, ParseDebugStream stream) {
    final sub = tokens[1].token.substring(1);
    if (tokens[1].token[0] != prefix) {
      throw ParseException.single(
        "This declaration (${tokens.first.token}) "
        "requires the identifier to carry "
        "the prefix \"$prefix\"",
        tokens[1].line!,
        tokens[1].character!,
      );
    }
    if (tokens[1].token.length < 2)
      stream.tokenError(
        "The identifier is not valid, it is too short",
        tokens[1],
      );
    validVariableName(tokens, stream, sub);
  }

  static void lengthIsValidTypeIdentifier(
      List<Token> tokens, ParseDebugStream stream) {
    if (tokens[1].token.length != 4) {
      stream.tokenError(
        "Type identifier is too ${tokens[1].token.length < 4 ? "short" : "long"}, "
        "it has to be three characters long "
        "(not including the \"@\")",
        tokens[1],
      );
    }
  }

  static FutureValue giveValueWithCorrectType<T>(
      List<Token> tokens, ParseDebugStream stream) {
    FutureValue val;
    val = helper.parseValueOfToken(tokens[3], stream);
    if (!helper.isCorrectCompileTimeType<T>(val)) {
      stream.tokenError(
        "Value \"${tokens[3].token}\" is not of type ${T.toString()}",
        tokens[3],
      );
    }
    return val;
  }

  static void isValidOperator(List<Token> tokens, ParseDebugStream stream) {
    if (allowed_characters_for_operators.containsOneOf(tokens[1].token))
      stream.tokenError(
        "Operators are only allowed to contain the following characters: \n" +
            smaller_error_space +
            "\"$allowed_characters_for_operators\"",
        tokens[1],
      );
    if (forbidden_operators.contains(tokens[1].token))
      stream.tokenError(
        "Operators are not allowed "
        "to be one of the reserved operators "
        "${forbidden_operators.toList().prettyPrint()}",
        tokens[1],
      );
  }

  static FutureValue operatorChecks(
      List<Token> tokens, ParseDebugStream stream) {
    DeclarationChecks.atLeastFourTokens(tokens, stream);
    DeclarationChecks.isValidOperator(tokens, stream);
    return DeclarationChecks.giveValueWithCorrectType<FutureFunction>(
        tokens, stream);
  }

  static void isNotOnlyUnderscoreEvent(
      List<Token> tokens, ParseDebugStream stream) {
    if (tokens[1].token == "_")
      stream.tokenWarning(
        "This declaration (${tokens[0].token} "
        "cannot have \"_\" as the identifier",
        tokens[1],
      );
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
  final FutureValue? arrayValue;

  MultipleDeclaration(
      this.variables, this.arrayValue, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class MultipleVariableDeclaration extends MultipleDeclaration {
  MultipleVariableDeclaration(
      List<MultipleVariableOrConstantDeclarationVariable> variables,
      FutureValue? arrayValue,
      int debugLine,
      int debugCharacter)
      : super(variables, arrayValue, debugLine, debugCharacter);
}

class MultipleConstantDeclaration extends MultipleDeclaration {
  MultipleConstantDeclaration(
      List<MultipleVariableOrConstantDeclarationVariable> variables,
      FutureValue? arrayValue,
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
  final String? variable;
  final FutureValue? value;

  SingleDeclaration(
      String variable, FutureValue value, int debugLine, int debugCharacter)
      : this.value = value,
        this.variable = variable == "_" ? null : variable,
        super(debugLine, debugCharacter);

  SingleDeclaration._(
      String variable, this.value, int debugLine, int debugCharacter)
      : this.variable = (variable == "_" ? null : variable),
        super(debugLine, debugCharacter);
}

//var _ = 3 dann kann der variablen name = null sein (genause wie bei multpilevariabledeclarationO
class SingleVariableDeclaration extends SingleDeclaration {
  SingleVariableDeclaration(
      String variable, FutureValue? value, int debugLine, int debugCharacter)
      : super._(variable, value, debugLine, debugCharacter);
}

class SingleConstantDeclaration extends SingleDeclaration {
  SingleConstantDeclaration(
      String variable, FutureValue? value, int debugLine, int debugCharacter)
      : super._(variable, value, debugLine, debugCharacter);
}

class SimpleDeclaration extends SingleDeclaration {
  SimpleDeclaration(
      List<Token> tokens, FutureValue value, ParseDebugStream stream)
      : super(
          tokens[0].token,
          value,
          tokens[0].line!,
          tokens[0].character!,
        );
}

class TypeDefinition extends SimpleDeclaration {
  TypeDefinition(List<Token> tokens, ParseDebugStream stream)
      : super(
            tokens.removeFirstOfIdentifier(),
            DeclarationChecks.giveValueWithCorrectType<TSType>(tokens, stream),
            stream);
}

class RecordDefinition extends SimpleDeclaration {
  RecordDefinition(List<Token> tokens, ParseDebugStream stream)
      : super(tokens.removeFirstOfIdentifier(),
            helper.parseValueOfToken(tokens.last, stream), stream);
}

class EventDeclaration extends SimpleDeclaration {
  EventDeclaration(List<Token> tokens, ParseDebugStream stream)
      : super(
            tokens,
            DeclarationChecks.giveValueWithCorrectType<FutureFunction>(
                tokens, stream),
            stream);
}

class OperatorDeclaration extends SimpleDeclaration {
  OperatorDeclaration(List<Token> tokens, ParseDebugStream stream)
      : super(tokens, DeclarationChecks.operatorChecks(tokens, stream), stream);
}

class PrefixDeclaration extends OperatorDeclaration {
  PrefixDeclaration(List<Token> tokens, ParseDebugStream stream)
      : super(tokens, stream);
}

class PostfixDeclaration extends OperatorDeclaration {
  PostfixDeclaration(List<Token> tokens, ParseDebugStream stream)
      : super(tokens, stream);
}
