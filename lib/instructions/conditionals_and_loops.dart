import 'package:meta/meta.dart';

import '../future_values/future_values.dart';

import 'instructions.dart';


@immutable
abstract class Conditional extends Instruction {
  final FutureValue bool;

  Conditional(this.bool,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}


@immutable
abstract class BodyConditional<Body> extends Conditional {
  final Body body;

  BodyConditional(this.body, FutureValue bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);

}

class If<Body> extends BodyConditional<Body> {

  If(Body body,FutureValue bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);
}

class Guard<Body> extends If {
  Guard(body, FutureValue bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);

}

class IfElse<Body,AlternativeBody> extends If<Body> {
  final AlternativeBody alternative;

  IfElse(this.alternative, Body body, FutureValue bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);

}

class While<Body> extends BodyConditional<Body> {
  While(Body body, FutureValue bool, int debugLine, int debugCharacter) : super(body, bool, debugLine, debugCharacter);

}

class For<Body> extends Instruction {
  final Body body;
  final FutureValue iterator;

  For(this.body,this.iterator,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}



class Assertion extends Conditional {

  Assertion(FutureValue bool, int debugLine, int debugCharacter) : super(bool, debugLine, debugCharacter);
}

