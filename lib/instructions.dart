import 'package:meta/meta.dart';
import 'package:tsharp/constants.dart';
import 'newvalue.dart';
class Closure {} class Fnc {}

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


abstract class MultipleDeclaration extends Declaration {
  final List<MultipleVariableOrConstantDeclarationVariable> variables; //Variablen und ihre default Werte in einer reihe korresponierend zu dem array
  MultipleDeclaration(this.variables,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

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

abstract class ValueHoldingMultipleDeclaration extends MultipleDeclaration {
  final FutureValue value;
  ValueHoldingMultipleDeclaration(this.value,List<MultipleVariableOrConstantDeclarationVariable> variables, int debugLine, int debugCharacter) : super(variables, debugLine, debugCharacter);

}

class MultipleVariableDeclaration extends ValueHoldingMultipleDeclaration {
  MultipleVariableDeclaration(FutureValue value, List<MultipleVariableOrConstantDeclarationVariable> variables, int debugLine, int debugCharacter) : super(value, variables, debugLine, debugCharacter);
}

class MultipleConstantDeclaration extends ValueHoldingMultipleDeclaration {
  MultipleConstantDeclaration(FutureValue value, List<MultipleVariableOrConstantDeclarationVariable> variables,  int debugLine, int debugCharacter) : super(value, variables, debugLine, debugCharacter);

}

//params soll safe sein also: [a,b,c] = [0,1] => [a,b,c] = [0,1,absent]
// das ist dann auch sehr einfach mit den defaults, die dann ja absent ersetzen

class ParameterDeclaration extends MultipleDeclaration {
  ParameterDeclaration(List<MultipleVariableOrConstantDeclarationVariable> variables, int debugLine, int debugCharacter) : super(variables, debugLine, debugCharacter);

}





abstract class SingleDeclaration<Val extends FutureValue> extends Declaration {
  final String variable;
  final FutureValue value;
  SingleDeclaration(this.variable,this.value,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

abstract class SingleVariableDeclaration extends SingleDeclaration {
  SingleVariableDeclaration(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

abstract class SingleConstantDeclaration extends SingleVariableDeclaration{
  SingleConstantDeclaration(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}


//definition num = @int + @kom
class TypeDefinition extends SingleDeclaration {
  TypeDefinition(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class RecordDefinition extends SingleDeclaration {
  RecordDefinition(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class ConstantDefinition extends SingleDeclaration {
  ConstantDefinition(String variable, dynamic value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class OperatorDeclaration extends SingleDeclaration {
  OperatorDeclaration(String variable, FutureValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class Prefix extends OperatorDeclaration {
  Prefix(String operator, FutureValue value, int debugLine, int debugCharacter) : super(operator, value, debugLine, debugCharacter);

}

class Postfix extends OperatorDeclaration {
  Postfix(String operator, FutureValue value, int debugLine, int debugCharacter) : super(operator, value, debugLine, debugCharacter);

}



class VariableAssignment extends Instruction {
  final String variable;
  final FutureValue value;

  VariableAssignment(this.variable, this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}




abstract class Usage extends Instruction {
  final String library;

  Usage(this.library, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class Use extends Usage {
  Use(String library, int debugLine, int debugCharacter) : super(library, debugLine, debugCharacter);

}

class Import extends Usage {
  Import(String library, int debugLine, int debugCharacter) : super(library, debugLine, debugCharacter);

}



abstract class Conditional extends Instruction {
  final FutureValue bool;

  Conditional(this.bool,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class If extends Conditional {
  final Closure body;

  If(this.body,FutureValue bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

class IfElse extends If {
  final Closure alternative;

  IfElse(this.alternative,Closure body, FutureValue bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);

}

class While extends Conditional {
  final Fnc body;

  While(this.body,FutureValue bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

class For extends Instruction {
  final Fnc body;
  final FutureValue iterator;

  For(this.body,this.iterator,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

enum Returns { RETURN, STOP}
class TerminationInstruction extends Instruction {
  final FutureValue returnValue;
  final List<Returns> returns; //für sachen wie return return, ein RETURN repräsentiert "return", STOP repräsentiert "stop", im program wird ein fehler dann geworfen
  // und die verschiedenen funktionen müssen versuchen ihn abzubaueh, if versucht ihn dann natürlich nicht abzubauen
  TerminationInstruction(this.returnValue,this.returns,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class ErrorInstruction extends Instruction {
  final dynamic message;

  ErrorInstruction(this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}


class Assertion extends Instruction {
  final FutureValue bool;
  final dynamic message;

  Assertion(this.bool,this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}


class SingleFunctionCall extends Instruction {
  final Call call; //muss vom typ "Call" sein also entweder: FunctionCall, PrefixCall, PostfixCall, und OperatorCall

  SingleFunctionCall(this.call,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}