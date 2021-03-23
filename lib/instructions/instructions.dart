import 'package:meta/meta.dart';

import '../future_values/values.dart';
import 'package:tsharp/debug.dart';

@immutable
abstract class Instruction {

  final int debugLine;
  final int debugCharacter;

  Instruction(this.debugLine, this.debugCharacter);

}

abstract class Declaration extends Instruction {

  Declaration(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

//eine Declaration darf keinen Wert enthalten, var a = 3 sind zwei instructions: var a; a = 3;
//eine Multiple Declaration muss den Wert direkt schon haben, nähmlich ein Array


@immutable
class MultipleVariableOrConstantDeclarationVariable extends DebugObject {
  final String name; //null wenn man dem parameter keinen namen gibt, z.B.: [a,,c]
  final FutureValue defaultValue; //wenn der im array korrespondierene Wert = absent ist,
  //in dem params befehl würde es auch reichen wenn das array zu kurz ist

  MultipleVariableOrConstantDeclarationVariable(this.name, this.defaultValue, int line, int character) : super(line, character);
}

class MultipleVariableOrConstantDeclarationRestAsArrayVariable extends MultipleVariableOrConstantDeclarationVariable {
  MultipleVariableOrConstantDeclarationRestAsArrayVariable(String name, FutureValue defaultValue,int line, int character) : super(name, defaultValue, line, character);
//REST: var [a, b = 3, c... = [2,2]] = [2,3,4,5,6] (c nimmt alle werte ab 4)
}

abstract class MultipleDeclaration extends Declaration {
  final List<MultipleVariableOrConstantDeclarationVariable> variables; //Variablen und ihre default Werte in einer reihe korresponierend zu dem array
  final FutureValue arrayValue;

  MultipleDeclaration(this.variables, this.arrayValue, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class MultipleVariableDeclaration extends MultipleDeclaration { MultipleVariableDeclaration(List<MultipleVariableOrConstantDeclarationVariable> variables, FutureValue arrayValue, int debugLine, int debugCharacter) : super(variables, arrayValue, debugLine, debugCharacter);}

class MultipleConstantDeclaration extends MultipleDeclaration { MultipleConstantDeclaration(List<MultipleVariableOrConstantDeclarationVariable> variables, FutureValue arrayValue, int debugLine, int debugCharacter) : super(variables, arrayValue, debugLine, debugCharacter);}

class ParameterDeclaration extends MultipleDeclaration { ParameterDeclaration(List<MultipleVariableOrConstantDeclarationVariable> variables, int debugLine, int debugCharacter) : super(variables, RecordReference("params", debugLine, debugCharacter), debugLine, debugCharacter);}

//params soll safe sein also: [a,b,c] = [0,1] => [a,b,c] = [0,1,absent]
// das ist dann auch sehr einfach mit den defaults, die dann ja absent ersetzen




abstract class SingleDeclaration<Val extends FutureValue> extends Declaration {
  final String variable;
  final FutureValue value;
  SingleDeclaration(this.variable,this.value,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}


//var _ = 3 dann kann der variablen name = null sein (genause wie bei multpilevariabledeclarationO
class SingleVariableDeclaration extends SingleDeclaration {SingleVariableDeclaration(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);}

class SingleConstantDeclaration extends SingleDeclaration {SingleConstantDeclaration(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);}


class TypeDefinition extends SingleDeclaration { TypeDefinition(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);}

class RecordDefinition extends SingleDeclaration { RecordDefinition(String record, FutureValue value, int debugLine, int debugCharacter) : super(record, value, debugLine, debugCharacter);}

class EventDeclaration extends SingleDeclaration { EventDeclaration(String event, FutureValue value, int debugLine, int debugCharacter) : super(event, value, debugLine, debugCharacter);}


class OperatorDeclaration extends SingleDeclaration { OperatorDeclaration(String operator, FutureValue value, int debugLine, int debugCharacter) : super(operator, value, debugLine, debugCharacter);}

class PrefixDeclaration extends OperatorDeclaration { PrefixDeclaration(String prefix, FutureValue value, int debugLine, int debugCharacter) : super(prefix, value, debugLine, debugCharacter);}

class PostfixDeclaration extends OperatorDeclaration { PostfixDeclaration(String postfix, FutureValue value, int debugLine, int debugCharacter) : super(postfix, value, debugLine, debugCharacter);}


class ImportDeclaration extends SingleDeclaration<SimpleValue<String>> { ImportDeclaration(String name, FutureValue value, int debugLine, int debugCharacter) : super(name, value, debugLine, debugCharacter);}
//import _ = "asdf.ts"    asdf()
//import asdf = "asdf.ts"   asdf_asdf()
//use math

class Usage extends Instruction {
  final String library;

  Usage(this.library, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class VariableAssignment extends Instruction {
  final String variable;
  final FutureValue value;

  VariableAssignment(this.variable, this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class Delete extends Instruction {
  final String deletion;

  Delete(this.deletion, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class SingleFunctionCall extends Instruction {
  final Call call; //muss vom typ "Call" sein also entweder: FunctionCall, PrefixCall, PostfixCall, und OperatorCall

  SingleFunctionCall(this.call,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

enum Returns { RETURN, STOP}
class TerminationInstruction extends Instruction {
  final FutureValue returnValue;
  final List<Returns> returns; //für sachen wie return return, ein RETURN repräsentiert "return", STOP repräsentiert "stop", im program wird ein fehler dann geworfen
  // und die verschiedenen funktionen müssen versuchen ihn abzubaueh, if versucht ihn dann natürlich nicht abzubauen
  TerminationInstruction(this.returnValue,this.returns,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class ErrorInstruction extends Instruction {
  final SimpleValue<String> message;

  ErrorInstruction(this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class Kill extends Instruction {
  Kill(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}