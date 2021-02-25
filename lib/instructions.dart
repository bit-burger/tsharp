import 'package:meta/meta.dart';
import 'values.dart';
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




abstract class MultipleDeclaration extends Declaration {
  final Map<String,Value> variables; //Variablen und ihre default Werte
  MultipleDeclaration(this.variables,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class MultipleVariableDeclaration extends MultipleDeclaration {
  final Value value;
  MultipleVariableDeclaration(this.value,Map<String, Value> variables, int debugLine, int debugCharacter) : super(variables, debugLine, debugCharacter);
}

class MultipleConstantDeclaration extends MultipleVariableDeclaration {
  MultipleConstantDeclaration(Value value, Map<String, Value> variables, int debugLine, int debugCharacter) : super(value, variables, debugLine, debugCharacter);

}

class ParameterDeclaration extends MultipleDeclaration {
  ParameterDeclaration(Map<String, Value> variables, int debugLine, int debugCharacter) : super(variables, debugLine, debugCharacter);

}





abstract class SingleDeclaration<Val extends Value> extends Declaration {
  final String variable;
  final Value value;
  SingleDeclaration(this.variable,this.value,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

abstract class SingleVariableDeclaration extends SingleDeclaration {
  SingleVariableDeclaration(String variable, Value value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

abstract class SingleConstantDeclaration extends SingleVariableDeclaration{
  SingleConstantDeclaration(String variable, Value value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}


//definition num = @int + @kom
class TypeDefinition extends SingleDeclaration {
  TypeDefinition(String variable, Value value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class RecordDefinition extends SingleDeclaration {
  RecordDefinition(String variable, Value value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class ConstantDefinition extends SingleDeclaration<DirectValue> {
  ConstantDefinition(String variable, DirectValue value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class OperatorDeclaration extends SingleDeclaration {
  OperatorDeclaration(String variable, Value value, int debugLine, int debugCharacter) : super(variable, value, debugLine, debugCharacter);

}

class Prefix extends OperatorDeclaration {
  Prefix(String operator, Value value, int debugLine, int debugCharacter) : super(operator, value, debugLine, debugCharacter);

}

class Postfix extends OperatorDeclaration {
  Postfix(String operator, Value value, int debugLine, int debugCharacter) : super(operator, value, debugLine, debugCharacter);

}



class VariableAssignment extends Instruction {
  final String variable;
  final Value value;

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
  final Value bool;

  Conditional(this.bool,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class If extends Conditional {
  final Closure body;

  If(this.body,Value bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

class IfElse extends If {
  final Closure alternative;

  IfElse(this.alternative,Closure body, Value bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);

}

class While extends Conditional {
  final Fnc body;

  While(this.body,Value bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

class For extends Instruction {
  final Fnc body;
  final Value iterator;

  For(this.body,this.iterator,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

enum Returns { RETURN, STOP}
class TerminationInstruction extends Instruction {
  final Value returnValue;
  final List<Returns> returns; //für sachen wie return return, ein RETURN repräsentiert "return", STOP repräsentiert "stop", im program wird ein fehler dann geworfen
  // und die verschiedenen funktionen müssen versuchen ihn abzubaueh, if versucht ihn dann natürlich nicht abzubauen
  TerminationInstruction(this.returnValue,this.returns,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class ErrorInstruction extends Instruction {
  final DirectValue message;

  ErrorInstruction(this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class Assertion extends Instruction {
  final Value bool;
  final DirectValue message;

  Assertion(this.bool,this.message,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}