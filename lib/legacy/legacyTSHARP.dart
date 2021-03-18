import 'dart:io' as io;
import 'dart:math';


class TSConfiguration {
  final List<TSFunction> functions;
  final void Function(String) outputFunction;
  final Future<String> Function(String) inputFunction;
  final bool includeStandardTSFunctions;
  TSConfiguration(this.outputFunction,this.inputFunction,{this.functions = const [],this.includeStandardTSFunctions = true,});
}

class ParseException extends TSException {
  int whichLine;
  ParseException(this.whichLine, String message) : super(message);
}

abstract class TSException implements Exception {
  final String message;
  TSException(this.message);
  @override
  String toString() {
    return message;
  }
}

class RunException extends TSException {
  RunException(String message) : super(message);
}

class ReturnToFunctionException implements Exception {
  final Value returnValue;
  ReturnToFunctionException(this.returnValue);
}

class TSFunctionRunException extends RunException {
  TSFunctionRunException(String message) : super(message);
}
//endregion
//region Parsing

enum IfParse { BOOL, CLOSURE, NOTHING }

class Parsing {
  static List<Instruction> giveListOfInstructions(final String text, int line) {
    List<String> rawInstructions = text.stringWaitSplit(split: "\n");
    List<Instruction> instructions = <Instruction>[];
    for (String rawInstruction in rawInstructions) {
      line += 1;
      // print(rawInstruction + ": " + line.toString() + "\n");
      rawInstruction = rawInstruction.trim();
      final rawInstructionString = rawInstruction + " [line: $line]";
      List<String> rawInstructionComponents = rawInstruction.stringWaitSplit();
      if (rawInstructionComponents.isEmpty) continue;
      if (rawInstructionComponents.first == "return") {
        if (rawInstructionComponents.length != 2 &&
            rawInstructionComponents.length != 1)
          throw ParseException(line,
              "a return statement should either only be return, or return a value");
        instructions.add(
          ReturnInstruction(
            rawInstructionComponents.length == 2
                ? Parsing.giveValue(rawInstructionComponents[1], line)
                : Abs(),
            rawInstructionString,
          ),
        );
      } else if (rawInstructionComponents[0] == "error") {
        instructions.add(
          ErrorInstruction(
            Parsing.giveValue(rawInstructionComponents[1], line),
            rawInstructionString,
          ),
        );
      } else if (rawInstructionComponents.first == "while") {
        if (rawInstructionComponents.length != 3)
          throw ParseException(line,
              "a while statement should include while, a bool and the scope");
        Value value = giveValue(rawInstructionComponents[1], line);
        if (value is! Bol && value is DirectValue)
          throw ParseException(line,
              "a while statement cant use the type <${value.runtimeType} as a bool");
        ScopeFunction scope = giveFnc(rawInstructionComponents[2], line, null);
        instructions.add(WhileInstruction(value, scope, rawInstruction));
      } else if (rawInstructionComponents.first == "if") {
        if (rawInstructionComponents.length < 3)
          throw ParseException(line,
              "if statement should at least include if, a boolean, and a closure to execute");
        IfParse next = IfParse.NOTHING;
        IfInstruction instruction;
        IfInstruction getLowestInstruction() {
          IfInstruction ifInstruction = instruction;
          while (ifInstruction is IfElseInstruction) {
            if ((ifInstruction as IfElseInstruction).elseScopeFunction !=
                null) {
              if ((ifInstruction as IfElseInstruction)
                      .elseScopeFunction
                      .instructions
                      .length ==
                  1) {
                if ((ifInstruction as IfElseInstruction)
                    .elseScopeFunction
                    .instructions
                    .first is IfElseInstruction) {
                  ifInstruction = (ifInstruction as IfElseInstruction)
                      .elseScopeFunction
                      .instructions
                      .first;
                  continue;
                }
              }
            }
            break;
          }
          return ifInstruction;
        }

        for (int i = 0; i < rawInstructionComponents.length; i++) {
          final String rawInstructionComponent = rawInstructionComponents[i];
          if (next == IfParse.BOOL) {
            Value value;
            try {
              value = Parsing.giveValue(rawInstructionComponent, line);
            } catch (error) {
              throw ParseException(line,
                  "after an if or and elif, a boolean is expected (error: ${error.toString()})");
            }
            if (value is DirectValue && value is! Bol)
              throw ParseException(line,
                  "<$rawInstructionComponent> cant be a boolean (a boolean is expected after a ");
            getLowestInstruction().condition = value;
            next = IfParse.CLOSURE;
          } else if (next == IfParse.CLOSURE) {
            ScopeFunction value =
                Parsing.giveFnc(rawInstructionComponent, line, null);
            IfInstruction instruction = getLowestInstruction();
            if (instruction.scopeFunction == null) {
              instruction.scopeFunction = value;
            } else {
              (instruction as IfElseInstruction).elseScopeFunction = value;
            }
            next = IfParse.NOTHING;
          } else if (rawInstructionComponent == "if") {
            if (i != 0)
              throw ParseException(line,
                  "if can only be in the first position of an if statement, after that only elif and else are allowed");
            if (rawInstructionComponents.length > 3) {
              instruction = IfElseInstruction(rawInstruction);
            } else {
              instruction = IfInstruction(rawInstruction);
            }
            next = IfParse.BOOL;
          } else if (rawInstructionComponent == "elif") {
            IfInstruction instruction = getLowestInstruction();
            if (i + 3 <= rawInstructionComponents.length) {
              (instruction as IfElseInstruction).elseScopeFunction =
                  ScopeFunction([IfElseInstruction(rawInstructionComponent)]);
            } else {
              (instruction as IfElseInstruction).elseScopeFunction =
                  ScopeFunction([IfInstruction(rawInstructionComponent)]);
            }
            next = IfParse.BOOL;
          } else if (rawInstructionComponent == "else") {
            if (i + 2 != rawInstructionComponents.length)
              throw ParseException(
                  line, "else has to be followed by a last closure");
            next = IfParse.CLOSURE;
          }
        }
        if (next == IfParse.BOOL) {
          throw ParseException(line,
              "after an elif, there must be a boolean and then a closure");
        } else if (next == IfParse.CLOSURE) {
          throw ParseException(
              line, "after a bool , a closure is excpected in a if statement");
        }
        instructions.add(instruction);
      } else if ((rawInstructionComponents.length == 4 &&
              rawInstructionComponents[2] == "=") ||
          rawInstructionComponents.length == 2) {
        if (rawInstructionComponents[0] == "var" ||
            rawInstructionComponents[0] == "let") {
          final Value value = rawInstructionComponents.length == 2
              ? Abs()
              : Parsing.giveValue(rawInstructionComponents[3], line);
          instructions.add(
            rawInstructionComponents[0] == "let"
                ? ConstantDeclarativeInstruction(
                    rawInstructionComponents[1],
                    value,
                    rawInstructionString,
                  )
                : DeclarativeInstruction(
                    rawInstructionComponents[1],
                    value,
                    rawInstructionString,
                  ),
          );
        } else {
          throw ParseException(line,
              "Erstes Wort von 4 oder 2 Länge sollte \"var\" oder \"let\" sein");
        }
      } else if (rawInstructionComponents.length == 3) {
        instructions.add(
          ModifierInstruction(
            rawInstructionComponents[0],
            Parsing.giveValue(rawInstructionComponents[2], line),
            rawInstructionString,
          ),
        );
      } else if (rawInstructionComponents.length == 1) {
        final Value singleFunctionCallInstructionValue =
            Parsing.giveValue(rawInstruction, line);
        if (singleFunctionCallInstructionValue is! Executioner)
          throw ParseException(line,
              "Value from type ${singleFunctionCallInstructionValue.runtimeType} is unused");
        final SingleFunctionCallInstruction singleFunctionCallInstruction =
            SingleFunctionCallInstruction(
          singleFunctionCallInstructionValue,
          rawInstructionString,
        );
        instructions.add(singleFunctionCallInstruction);
      } else {
        print("This instruction is false");
      }
      line += "\n".allMatches(rawInstruction).length;
    }
    return instructions;
  }

  static ScopeFunction giveFnc(
      String string, int line, List<String> parameters) {
    string = string.trim();
    if (string[0] == "{" && string[string.length - 1] == "}") {
      string = string.substring(1, string.length - 1);
      final List<Instruction> instructions =
          giveListOfInstructions(string, line);
      if (parameters == null) {
        return ScopeFunction(instructions);
      }
      return Fnc(instructions, parameters);
    } else {
      throw ParseException(
          line,
          string +
              " :\nthis is not a valid ${parameters == null ? "scope" : "functionBody"}");
    }
  }

  static Value giveValue(String string, int line) {
    string = string.trim();
    if(string[0]=="@") {
      string = string.substring(1);
      final type = Value.types[string];
      if(type!=null) return Typ(type);
      throw ParseException(line, "not a type");
    } else if (string == "absent") {
      return Abs();
    } else if (string == "true" || string == "false") {
      return Bol(string == "true");
    } else if (string[0] == "<" && string[string.length - 1] == ">") {
      return Txt(string.substring(1, string.length - 1));
    } else if (int.tryParse(string) != null) {
      return Int(int.tryParse(string));
    } else if (double.tryParse(string) != null) {
      return Kom(double.tryParse(string));
    } else if (string[string.length - 1] == ")") {
      List<String> functionParts = string.klammerSplit();
      String functionPartsLast = functionParts.removeLast();
      functionPartsLast =
          functionPartsLast.substring(1, functionPartsLast.length - 1);
      String functionPartsRest = "";
      functionParts.forEach((element) {
        functionPartsRest += element;
      });
      final Value value = Parsing.giveValue(functionPartsRest, line);
      String parameter = "";
      List<Value> parameterListe = [];
      List<String> klammern = [];
      for (int i = 0; i < functionPartsLast.length; i++) {
        String character = functionPartsLast[i];
        if (character == "(" || character == "{" || character == "<")
          klammern.add(character);
        else if ((character == ")" && klammern.last == "(") ||
            (character == "}" && klammern.last == "{") ||
            (character == ">" && klammern.last == "<")) klammern.removeLast();
        if (character == "," && klammern.length == 0) {
          if (parameter.isNotEmpty) {
            parameterListe.add(Parsing.giveValue(parameter.trim(), line));
            parameter = "";
          }
        } else {
          parameter += character;
        }
      }
      if (parameter.isNotEmpty) {
        parameterListe.add(Parsing.giveValue(parameter, line));
      }
      final Executioner executioner = Executioner(value, parameterListe);
      return executioner;
    } else if (string[0] == "(" && string[string.length - 1] == "}") {
      List<String> functionParts = string.klammerSplit();
      String firstFunctionPart = functionParts.removeAt(0);
      String restFunctionPart = "";
      functionParts.forEach((element) {
        restFunctionPart += element;
      });
      if (restFunctionPart[0] == "{" &&
          firstFunctionPart[firstFunctionPart.length - 1] == ")") {
        List<String> parameterListe = [];
        String parameter = "";
        firstFunctionPart =
            firstFunctionPart.substring(1, firstFunctionPart.length - 1);
        for (int i = 0; i < firstFunctionPart.length; i++) {
          String character = firstFunctionPart[i];
          if (character == " ") {
          } else if (character == ",") {
            if (parameter.isNotEmpty) {
              parameterListe.add(parameter);
              parameter = "";
            }
          } else {
            parameter += character;
          }
        }
        if (parameter.isNotEmpty) {
          parameterListe.add(parameter);
        }
        return giveFnc(restFunctionPart, line, parameterListe);
      }
    } else if (Value.isVar(string)) {
      return VariableGet(string);
    }
    throw ParseException(line, "Unbekannter Value fehler: " + string);
  }
}

//endregion Parsing
//region Execution
class Main {
  void Function(String) printer;

  Main(final String text) {
    final Stopwatch stopwatch = Stopwatch()..start();
    print("SCAN BEGUN\n");
    String newText = "";
    text.split("\n").forEach((line) {
      if (line.contains("//")) {
        line = line.substring(0, line.indexOf("//"));
      }
      if (line.contains("#")) {
        line = line.substring(0, line.indexOf("#"));
      }
      newText += line.trim() + "\n";
    });
    newText = newText.substring(0, newText.length - 1);
    print("\n");
    print("SCAN DONE");
    print("  TIME " +
        (stopwatch.elapsedMilliseconds.toDouble() / 1000).toString());
    print("-------");
    try {
      print("PARSING BEGUN\n");
      MainFunction mainFunction =
          MainFunction(Parsing.giveListOfInstructions(newText, 0));
      stopwatch.stop();
      print("PARSING DONE");
      print("  TIME: " +
          (stopwatch.elapsedMilliseconds.toDouble() / 1000).toString());
      print("-------");
      stopwatch
        ..reset()
        ..start();
      print("EXECUTION BEGUN");
      print("");
      Execution executedObject = Execution(mainFunction, null);
      stopwatch.start();
      print("");
      print("*******************");
      print("EXECUTION SUCCEEDED");
      print("  VARIABLES: " + executedObject.variables.toString());
      print("  TIME: " +
          (stopwatch.elapsedMilliseconds.toDouble() / 1000).toString() +
          " SECONDS");
      print("*******************");
      io.exitCode = 0;
    } catch (error) {
      if (error is ParseException) {
        print("\n");
        print("▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲");
        print("PARSE EXCEPTION");
        print("  LINE: ${error.whichLine}");
        print("  TYPE: ${error.message}");
        print("▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲");
      } else if (error is RunException) {
        print("\n");
        print("▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲");
        print("EXECUTION EXCEPTION");
        print(error);
        print("▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲");
      } else {
        print("INTERNAL FAIL: " + error.toString().toUpperCase());
      }
      io.exitCode = 2;
    }
  }
}

class Execution {
  void throwError(String message, String instruction) {
    Execution onParent = this;
    String stack = "";
    while (onParent != null) {
      stack += "  " + onParent.name + "\n";
      onParent = onParent.parent;
    }
    stack = stack.substring(0, stack.length - 1);
    throw RunException("Error:\n  " +
        message +
        "  \nInstruction: " +
        "\n  " +
        instruction +
        "\n" +
        "Stack: \n" +
        stack);
  }

  // ignore: missing_return
  Variable variableOfString(String variable, String instruction) {
    Execution onParent = this;
    while (onParent != null) {
      if (onParent.variables[variable] != null) {
        return onParent.variables[variable];
      } else {
        onParent = onParent.parent;
      }
    }
    throwError("value variable \"$variable\" couldnt be found", instruction);
  }

  Value valueOfVariable(String variable, String instruction) =>
      variableOfString(variable, instruction).value;

  void changeValueOfVariable(String variable, Value value, String instruction) {
    Execution onParent = this;
    while (onParent != null) {
      if (onParent.variables[variable] != null) {
        onParent.variables[variable].value = value;
        return;
      } else {
        onParent = onParent.parent;
      }
    }
    throwError(
        "variable \"$variable\" couldnt be found (and changed)", instruction);
  }

  Value giveUsableValue(Value value, String instruction) {
    if (value is VariableGet) {
      return valueOfVariable(value.variable, instruction);
    } else if (value is Executioner) {
      return execute(value, instruction);
    } else if (value is Fnc) {
      value.parent = this;
      return value;
    }
    return value;
  }

  // ignore: missing_return
  Value execute(Executioner executioner, String instruction) {
    Value executableFunction;
    List<Value> newParameters = <Value>[];
    for (Value parameter in executioner.functionParameters) {
      newParameters.add(giveUsableValue(parameter, instruction));
    }
    if (executioner.function is SystemVariableGet) {
      TSFunction tsFunction = TSFunction
          .tsFunctions[(executioner.function as SystemVariableGet).variable];
      if (tsFunction.maxParameterCount <=
              executioner.functionParameters.length &&
          tsFunction.minParameterCount >=
              executioner.functionParameters.length) {
        try {
          return tsFunction.inputHandler(newParameters,this);
        } catch (error) {
          throwError((error as TSFunctionRunException).message, instruction);
        }
      } else {
        throwError(
          "PARAMETER COUNT DOESN'T MATCH TSFUNCTION: " +
              (executioner.function as SystemVariableGet).variable +
              ", PARAMETER LENGTH OF FUNCTION: " +
              tsFunction.minParameterCount.toString() +
              "<->" +
              tsFunction.minParameterCount.toString() +
              ", GIVEN PARAMETER LENGTH: " +
              executioner.functionParameters.length.toString(),
          instruction,
        );
      }
    } else if (executioner.function is Fnc) {
      executableFunction = executioner.function;
      (executableFunction as Fnc).parent = this;
    } else if (executioner.function is VariableGet) {
      executableFunction = valueOfVariable(
          (executioner.function as VariableGet).variable, instruction);
    } else if (executioner.function is Executioner) {
      executableFunction = execute(executioner.function, instruction);
    }
    if (executableFunction is Fnc) {
      if (executioner.functionParameters.length !=
          executableFunction.stringParameters.length) {
        throwError(
            "PARAMETER COUNT DOESN'T MATCH FUNCTION: " +
                executableFunction.name +
                ", PARAMETER LENGTH OF FUNCTION: " +
                executableFunction.stringParameters.length.toString() +
                ", GIVEN PARAMETER LENGTH: " +
                executioner.functionParameters.length.toString(),
            instruction);
      } else if (executableFunction != null && executableFunction is Fnc) {
        return Execution(executableFunction, newParameters).returnValue;
      }
    }
    throwError(
      "CANT EXECUTE SOMETHING OF TYPE " +
          executableFunction.runtimeType.toString(),
      instruction,
    );
  }

  Map<String, Variable> variables = {};
  Execution parent;
  Value returnValue;
  String name;
  BaseFunction f;
  void executeScope(ScopeFunction scopeFunction) {
    scopeFunction.parent = this;
    Execution(scopeFunction, null);
  }

  Execution(BaseFunction function, List<Value> executionParameters) {
    f = function;
    if (function is Fnc) {
      name = function.name ?? "[Anonymus function]";
      if (function.stringParameters != null) {
        for (int i = 0; i < function.stringParameters.length; i++) {
          variables[function.stringParameters[i]] =
              Variable(executionParameters[i]);
        }
      }
    } else if (function is ScopeFunction) {
      name = "[Scope]";
    } else if (function is MainFunction) {
      name = "[Main]";
    }
    if (function is ScopeFunction) {
      parent = function.parent;
    }

    if (function.instructions == null)
      throwError("instructions of functions are not valid, reason: unknown",
          "[NO INSTRUCTIONS]");
    for (Instruction instruction in function.instructions) {
      if (instruction is VariableInstruction) {
        if (TSFunction.tsFunctions[instruction.variable] != null)
          throwError("You can't modify the tsFunction " + instruction.variable,
              instruction.debugInstruction);
        Value finalValue =
            giveUsableValue(instruction.value, instruction.debugInstruction);
        if (instruction is DeclarativeInstruction) {
          if (variables[instruction.variable] == null) {
            if (instruction.value is Fnc) {
              (instruction.value as Fnc).name = instruction.variable;
            }
            variables[instruction.variable] =
                instruction is ConstantDeclarativeInstruction
                    ? ConstantVariable(finalValue)
                    : Variable(finalValue);
          } else {
            throwError(
                "You can't modify a variable/constant that has already been declared in this scope",
                instruction.debugInstruction);
          }
        } else if (instruction is ModifierInstruction) {
          if (variableOfString(
                  instruction.variable, instruction.debugInstruction) //warum wird nicht erst die variable gesucht gefunden, ausgewertet und schliesslich benutzt,
          // anstatt sie zweimal zu suchen (sie wird bei variableOfString und changeValueOfVariable jedes mal nochmal neu gesucht)
              is! ConstantVariable) {
            changeValueOfVariable(
                instruction.variable, finalValue, instruction.debugInstruction);
          } else {
            throwError("You can't modify a constant " + instruction.variable,
                instruction.debugInstruction);
          }
        }
      } else if (instruction is SingleFunctionCallInstruction) {
        execute(instruction.execution, instruction.debugInstruction);
      } else if (instruction is ReturnInstruction) {
        final Value usableValue =
            giveUsableValue(instruction.value, instruction.debugInstruction);
        if (function is Fnc) {
          returnValue = usableValue;
          break;
        } else {
          throw ReturnToFunctionException(usableValue);
        }
      } else if (instruction is ErrorInstruction) {
        throwError("Error was thrown: " + instruction.value.toString(),
            instruction.debugInstruction);
      } else if (instruction is WhileInstruction) {
        final nonExecutedBoolean = instruction.condition;
        try {
          while (
              (giveUsableValue(nonExecutedBoolean, instruction.debugInstruction)
                      as Bol)
                  .value) executeScope(instruction.scopeFunction);
        } on TypeError {
          throwError("bool in while statement wasnt a bool",
              instruction.debugInstruction);
        } catch (error) {
          if (error is ReturnToFunctionException) {
            returnValue = error.returnValue;
            break;
          }
          rethrow;
        }
      } else if (instruction is IfInstruction) {
        try {
          Value boolean = giveUsableValue(
              instruction.condition, instruction.debugInstruction);
          if (boolean is! Bol)
            throwError(
                "cant execute a non boolean", instruction.debugInstruction);
          if ((boolean as Bol).value) {
            executeScope(instruction.scopeFunction);
          } else if (instruction is IfElseInstruction) {
            if (instruction.elseScopeFunction != null)
              executeScope(instruction.elseScopeFunction);
          }
        } catch (error) {
          if (error is ReturnToFunctionException &&
              (function is Fnc || function is MainFunction)) {
            returnValue = error.returnValue;
            break;
          } else {
            rethrow;
          }
        }
      }
    }
  }
}

//endregion
//region Instructions
abstract class Instruction {
  String debugInstruction;
  Instruction(this.debugInstruction);
  @override
  String toString() => debugInstruction;
}

abstract class TerminationInstruction extends Instruction {
  final Value value;
  TerminationInstruction(this.value, String debugInstruction)
      : super(debugInstruction);
}

class ReturnInstruction extends TerminationInstruction {
  ReturnInstruction(Value value, String debugInstruction)
      : super(value, debugInstruction);
}

class ErrorInstruction extends TerminationInstruction {
  ErrorInstruction(Value value, String debugInstruction)
      : super(value, debugInstruction);
}

abstract class VariableInstruction extends Instruction {
  final Value value;
  final String variable;
  VariableInstruction(this.variable, this.value, String debugInstruction)
      : super(debugInstruction);
}

class SingleFunctionCallInstruction extends Instruction {
  SingleFunctionCallInstruction(this.execution, String debugInstruction)
      : super(debugInstruction);
  Executioner execution;
}

class ModifierInstruction extends VariableInstruction {
  ModifierInstruction(String variable, Value value, String debugInstruction)
      : super(variable, value, debugInstruction);
}

class ConstantDeclarativeInstruction extends DeclarativeInstruction {
  ConstantDeclarativeInstruction(
      String variable, Value value, String debugInstruction)
      : super(variable, value, debugInstruction);
}

class DeclarativeInstruction extends VariableInstruction {
  DeclarativeInstruction(String variable, Value value, String debugInstruction)
      : super(variable, value, debugInstruction);
  @override
  String toString() {
    return variable + " Dec";
  }
}

class IfInstruction extends Instruction {
  Value condition;
  ScopeFunction scopeFunction;
  IfInstruction(String debugInstruction) : super(debugInstruction);
  @override
  String toString() {
    return "if " +
        condition.toString() +
        "\n" +
        "{\n" +
        this.scopeFunction.instructions.toString() +
        "\n}";
  }

  IfInstruction.all(this.condition, this.scopeFunction, String debugInstruction)
      : super(debugInstruction);
}

class WhileInstruction extends IfInstruction {
  WhileInstruction(
      Value condition, ScopeFunction scopeFunction, String debugInstruction)
      : super.all(condition, scopeFunction, debugInstruction);
}

class IfElseInstruction extends IfInstruction {
  ScopeFunction elseScopeFunction;
  IfElseInstruction(String debugInstruction) : super(debugInstruction);
  @override
  String toString() {
    return "if " +
        condition.toString() +
        "\n" +
        "{\n" +
        // this.scopeFunction.instructions.toString() +
        "\n}" +
        " else"
            "{\n" +
        // this.elseScopeFunction.instructions.toString() +
        "\n}";
  }
}

//endregion
//region Value
abstract class Value {
  static const String allowedCharactersForVariables =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
  static const List<String> keywords = [
    "var",
    "let",
    "if",
    "else",
    "elif",
    "while",
    "for",
    "in",
    "absent",
    "true",
    "false"
  ];
  static bool isVar(String variable) {
    for (String character in variable.split("")) {
      if (!allowedCharactersForVariables.contains(character)) return false;
    }
    for (String keyword in Value.keywords) {
      if (keyword == variable) return false;
    }
    return true;
  }

  static Map<String,Type> types = {
    "Int" : Type.Int,
    "Kom" : Type.Kom,
    "Fnc" : Type.Fnc,
    "Txt" : Type.Txt,
    "Typ" : Type.Typ,
    "Abs" : Type.Abs,
  };
}

enum Type {Int,Kom,Fnc,Txt,Typ,Abs}



class VariableGet extends Value {
  final String variable;
  VariableGet.nonSystem(this.variable);
  factory VariableGet(String variable) {
    if (TSFunction.tsFunctions[variable] != null)
      return SystemVariableGet(variable);
    return VariableGet.nonSystem(variable);
  }
}

class SystemVariableGet extends VariableGet {
  SystemVariableGet(String variable) : super.nonSystem(variable);
}
//extra variable

class Executioner extends Value {
  final List<Value> functionParameters;
  final Value function;
  Executioner(this.function, this.functionParameters);
}

abstract class DirectValue<V> extends Value {
  final V value;
  DirectValue(this.value);
  @override
  String toString() {
    return value.toString();
  }
}

abstract class NumberType<Number extends num> extends DirectValue<Number> {
  NumberType(Number value) : super(value);
  NumberType operator +(NumberType other) {
    final num value = this.value + other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberType operator -(NumberType other) {
    final num value = this.value - other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberType operator *(NumberType other) {
    final num value = this.value * other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberType operator /(NumberType other) {
    final num value = this.value / other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberType customMax(NumberType other) {
    final value = max(this.value, other.value);
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberType customMin(NumberType other) {
    final value = min(this.value, other.value);
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  Bol operator <(NumberType other) {
    final bool value = this.value < other.value;
    return Bol(value);
  }

  Bol operator >(NumberType other) {
    final bool value = this.value > other.value;
    return Bol(value);
  }
}

class Int extends NumberType<int> {
  Int(int value) : super(value);
}

class Kom extends NumberType<double> {
  Kom(double value) : super(value);
}

class Txt extends DirectValue<String> {
  Txt(String value) : super(value);
}

class Bol extends DirectValue<bool> {
  Bol(bool value) : super(value);
}

class Typ extends DirectValue<Type> {
  Typ(Type value): super(value);
}

class Abs extends Value {
  @override
  String toString() {
    return "absent";
  }
}

abstract class BaseFunction extends Value {
  final List<Instruction> instructions;
  BaseFunction(this.instructions);
}

class Fnc extends ScopeFunction {
  List<String> stringParameters;
  String name;
  Fnc(List<Instruction> instructions, this.stringParameters)
      : super(instructions);

  @override
  String toString() {
    return "Fnc(" +
        instructions.toString() +
        stringParameters.toString() +
        name.toString() +
        ")";
  }
}

class ScopeFunction extends BaseFunction {
  Execution parent;
  ScopeFunction(List<Instruction> instructions) : super(instructions);
}

class MainFunction extends BaseFunction {
  MainFunction(List<Instruction> instructions) : super(instructions);
}

class Variable {
  Value value;
  Variable(this.value);
  @override
  String toString() {
    return "(Var)" + value.toString();
  }
}

class ConstantVariable extends Variable {
  ConstantVariable(Value value) : super(value);
  @override
  String toString() {
    return "(Let) " + value.toString();
  }
}

// ignore: deprecated_extends_function
class TSFunction {
  final Value Function(List<Value> input,Execution execution) inputHandler;
  final int minParameterCount;
  final int maxParameterCount;

  TSFunction(this.inputHandler, this.maxParameterCount, this.minParameterCount);

  static final Map<String, TSFunction> tsFunctions = {
    //Number input, number output"add"
    "add": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>) + (input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use add if not both are number types (Int OR Kom)");
    }, 2, 2),
    "subtract": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>) - (input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use add if not both are number types (Int OR Kom)");
    }, 2, 2),
    "multiply": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>) * (input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use add if not both are number types (Int OR Kom)");
    }, 2, 2),
    "divide": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>) / (input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot divide if not both are number types (Int OR Kom)");
    }, 2, 2),
    "round_divide": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return Int((input[0] as NumberType<num>).value ~/ (input[1] as NumberType<num>).value);
      }
      throw TSFunctionRunException(
          "Cannot use round divide if not both are number types (Int OR Kom)");
    }, 2, 2),
    "pow": null, //must be implemented
    "min": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>)
            .customMin(input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use min if not both are number types (Int OR Kom)");
    }, 2, 2),
    "max": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>)
            .customMax(input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use max if not both are number types (Int OR Kom)");
    }, 2, 2),
    // //Number input, boolean output
    "smaller": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>) < (input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use smaller if not both are number types (Int OR Kom)");
    }, 2, 2),
    "bigger": TSFunction((input,execution) {
      if (input[0] is NumberType && input[1] is NumberType) {
        return (input[0] as NumberType<num>) > (input[1] as NumberType<num>);
      }
      throw TSFunctionRunException(
          "Cannot use bigger if not both are number types (Int OR Kom)");
    }, 2, 2),
    // //boolean input, boolean output
    "and": TSFunction((input,execution) {
      if (input[0] is Bol && input[1] is Bol) {
        return Bol((input[0] as Bol).value && (input[1] as Bol).value);
      }
      throw TSFunctionRunException(
          "Cannot use and if not both are from type Bol");
    }, 2, 2),
    "or": TSFunction((input,execution) {
      if (input[0] is Bol && input[1] is Bol) {
        return Bol((input[0] as Bol).value || (input[1] as Bol).value);
      }
      throw TSFunctionRunException(
          "Cannot use or if not both are from type Bol");
    }, 2, 2),
    "either": TSFunction((input,execution) {
      if (input[0] is Bol && input[1] is Bol) {
        return Bol(((input[0] as Bol).value || (input[1] as Bol).value) &&
            !((input[0] as Bol).value && (input[1] as Bol).value));
      }
      throw TSFunctionRunException(
          "Cannot use either if not both are from type Bol");
    }, 2, 2),
    "not": TSFunction((input,execution) {
      if (input[0] is Bol) {
        return Bol(!(input[0] as Bol).value);
      }
      throw TSFunctionRunException(
          "Cannot use not if the argument is not from type Bol");
    }, 1, 1),
    // //all input, boolean output
    "equals": TSFunction((input,execution) {
      if (input[0].runtimeType == input[1].runtimeType) {
        if (input[0] is DirectValue) {
          return Bol((input[0] as DirectValue).value ==
              (input[1] as DirectValue).value);
        } else if (input[0] is Fnc) {
          return Bol(identical(input[0], input[1]));
        }
      }
      return Bol(false);
    }, 2, 2),
    "isSameType": TSFunction((input,execution) {
      return Bol(input[0].runtimeType == input[1].runtimeType);
    }, 2, 2),
    "isType": TSFunction((input,execution) {
      if(input[1] is Typ)
        return Bol(Value.types[input[0].runtimeType.toString()] == (input[1] as Typ).value);
      throw TSFunctionRunException("second parameter must be from Type \"Typ\"");
    }, 2, 2),
    "isAbsent": TSFunction((input,execution) {
      return Bol(input[0] is Abs);
    }, 1, 1),
    // "ea",
    // //io
    "output": TSFunction((input,execution) {
      String printValue = "";
      for (Value parameter in input) {
        printValue += parameter.toString() + ", ";
      }
      printValue = printValue.substring(0, printValue.length - 2);
      print(printValue);
      return Abs();
    }, 1, 99999),
    "input": TSFunction((input,execution) {
      if (input.isEmpty) {
        io.stdout.write(">");
      } else {
        io.stdout.write(input);
      }
      return Txt(io.stdin.readLineSync());
    }, 0, 1),
    "formattedInput": TSFunction((input,execution) {
      if (input.isEmpty) {
        io.stdout.write(">");
      } else {
        io.stdout.write(input);
      }
      try {
        final val = Parsing.giveValue(io.stdin.readLineSync(), 0);
        if(val is Fnc) val.parent = execution;
        return val;
      } catch (error) {
        throw TSFunctionRunException("invalid Value");
      }
    }, 0, 1),

    // "formattedInput",
  };
}

//endregion
//region String extensions
extension on String {
  //"funny haha (){ ha ha ha  } -> ["funny","haha","(){ ha ha ha  }"]
  List<String> stringWaitSplit({String split = " "}) {
    List<String> list = [];
    List<String> klammern = [];
    String valueToAppend = "";
    this.split("").forEach((String character) {
      if (character == "{" || character == "(" || character == "<") {
        klammern.add(character);
      } else if (klammern.isEmpty && (character == split)) {
        if (split == "") {
          list.add(character);
        }
        list.add(valueToAppend);
        valueToAppend = "";
        return;
      } else if ((character == "}" && klammern.last == "{") ||
          (character == ")" && klammern.last == "(") ||
          (character == ">" && klammern.last == "<")) {
        klammern.removeAt(klammern.length - 1);
      }
      valueToAppend += character;
    });
    if (valueToAppend.isNotEmpty) {
      list.add(valueToAppend);
    }

    return list;
  }

  //"(haha)aldf(alsdf)" -> ["(haha)","aldf","(alsdf)"]
  List<String> klammerSplit() {
    List<String> returnValue = [];
    List<String> klammern = [];
    String valueToAppend = "";
    this.split("").forEach((character) {
      if (character == "(" || character == "{" || character == "<") {
        if (valueToAppend.isNotEmpty && klammern.isEmpty) {
          returnValue.add(valueToAppend);
          valueToAppend = "";
        }
        klammern.add(character);
        valueToAppend += character;
      } else if ((character == ")" && klammern.last == "(") ||
          (character == "}" && klammern.last == "{") ||
          (character == ">" && klammern.last == "<")) {
        klammern.removeLast();
        valueToAppend += character;
        if (klammern.isEmpty) {
          returnValue.add(valueToAppend);
          valueToAppend = "";
          return;
        }
      } else {
        valueToAppend += character;
      }
    });
    return returnValue;
  }
}

