import 'dart:collection';

import 'package:meta/meta.dart';
import 'dart:math';
import '../instructions/instructions.dart';
import 'package:tsharp/constants.dart';

@immutable
abstract class Value extends DebugObject {
  Value(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

abstract class DirectValue<V> extends Value {
  final V value;
  DirectValue(this.value, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
  @override
  String toString() {
    return value.toString();
  }
}

abstract class NumberValue<Number extends num> extends DirectValue<Number> {
  NumberValue(Number value, int debugLine, int debugCharacter)
      : super(value, debugLine, debugCharacter);
  NumberValue operator +(NumberValue other) {
    final num value = this.value + other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberValue operator -(NumberValue other) {
    final num value = this.value - other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberValue operator *(NumberValue other) {
    final num value = this.value * other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberValue operator /(NumberValue other) {
    final num value = this.value / other.value;
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberValue customMax(NumberValue other) {
    final value = max(this.value, other.value);
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  NumberValue customMin(NumberValue other) {
    final value = min(this.value, other.value);
    if (value is double) {
      return Kom(value);
    }
    return Int(value as int);
  }

  Bol operator <(NumberValue other) {
    final bool value = this.value < other.value;
    return Bol(value);
  }

  Bol operator >(NumberValue other) {
    final bool value = this.value > other.value;
    return Bol(value);
  }
}

class Int extends NumberValue<int> {
  Int(int value, [int debugLine, int debugCharacter])
      : super(value, debugLine, debugCharacter);
}

class Kom extends NumberValue<double> {
  Kom(double value, [int debugLine, int debugCharacter])
      : super(value, debugLine, debugCharacter);
}

class Str extends DirectValue<String> {
  Str(String value, [int debugLine, int debugCharacter])
      : super(value, debugLine, debugCharacter);
}

class Bol extends DirectValue<bool> {
  Bol(bool value, [int debugLine, int debugCharacter])
      : super(value, debugLine, debugCharacter);
}

@immutable
class Range {
  final int start;
  final int end;

  Range(this.start, this.end);

}
class Rng extends DirectValue<Range> {
  Rng(Range value, int debugLine, int debugCharacter) : super(value, debugLine, debugCharacter);

}

class Arr extends DirectValue<List<DirectValue>> {
  Arr(List<DirectValue> value, int debugLine, int debugCharacter) : super(value, debugLine, debugCharacter);

}

enum TSType {
  abs,
  arr,
  bol,
  fnc,
  int,
  kom,
  rng,
  str,
  typ,
}

class Typ extends DirectValue<Set<TSType>> {
  Typ(Set<TSType> value, [int debugLine, int debugCharacter])
      : super(value, debugLine, debugCharacter);
}

class Abs extends DirectValue {
  Abs([int debugLine, int debugCharacter])
      : super(null, debugLine, debugCharacter);
}



class IndirectValue extends Value {
  IndirectValue(int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

abstract class Invocation extends IndirectValue {
  final String name;

  Invocation(this.name, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class VariableInvocation extends Invocation {
  VariableInvocation(String name, int debugLine, int debugCharacter)
      : super(name, debugLine, debugCharacter);
}

class RecordInvocation extends Invocation {
  RecordInvocation(String name, int debugLine, int debugCharacter)
      : super(name, debugLine, debugCharacter);
}

class TypeInvocation extends Invocation {
  TypeInvocation(String name, int debugLine, int debugCharacter)
      : super(name, debugLine, debugCharacter);
}

class FunctionCall extends IndirectValue {
  final Value parameters;
  final Value function;

  FunctionCall(
      this.parameters, this.function, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class OperatorCall extends IndirectValue {
  final Value firstParameter;
  final Value secondParameter;

  final String operator;

  OperatorCall(this.firstParameter, this.secondParameter, this.operator,
      int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

abstract class SingleParameterOperatorCall extends IndirectValue {
  final Value parameter;
  final String operator;

  SingleParameterOperatorCall(
      this.parameter, this.operator, int debugLine, int debugCharacter)
      : super(debugLine, debugCharacter);
}

class PrefixCall extends SingleParameterOperatorCall {
  PrefixCall(
      Value parameter, String operator, int debugLine, int debugCharacter)
      : super(parameter, operator, debugLine, debugCharacter);
}

class PostfixCall extends SingleParameterOperatorCall {
  PostfixCall(
      Value parameter, String operator, int debugLine, int debugCharacter)
      : super(parameter, operator, debugLine, debugCharacter);
}



@immutable
class ValueHolder {
  final Value value;

  ValueHolder(this.value);
}

class Constant extends ValueHolder {
  Constant(Value value) : super(value);
}

class Variable extends ValueHolder {
  Variable(Value value) : super(value);
}


@immutable
abstract class Record {

}

class ConstantRecord extends Record {
  final DirectValue value;

  ConstantRecord(this.value);
}


class RunTimeRecord extends Record {
  final DirectValue Function(RecordInvocation, Execution) executer;
  
  RunTimeRecord(this.executer);
}

class ParameterRecord extends Record {}


//im standart TSUse wird es Records geben in einer Map (dem Records register), z.B.: für "line" (im code dann #line) gibt es dann RunTimeRecord((i,_)=>i.debugLine)
//#parameter/$ => ParameterRecord()


// ignore: deprecated_extends_function
class FunctionPlan extends IndirectValue { //plant nur eine Funktion
  //[OUTDATED]//anstatt das die Fnc den parent enthält der execution, wird bei einer execution einer funktion einfach direkt das Executionsobjekt (parent) an den child abgegeben, ohne Umweg über die Funktion selber (parent Execution wird nicht mehr in der Funktion gespeichert)
  //update die Zeile drüber stimmt nicht Fnc müssen anstattdessen indirekt sein und bei der execution erzeugt werden
  final List<Instruction> instructions;
  FunctionPlan(this.instructions,int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class Fnc extends DirectValue<List<Instruction>> { //während der execution wird dieses objekt erzeugt wenn ein FunctionPlan object vorliegt, ihm wird direkt der parent gegegeben
  // (das wäre sehr wahrscheinlich, vorraussichtlich man befindet sich in der Execution, "this", also das aktuelle execution object)
  final Execution parent;

  Fnc(this.parent,List<Instruction> value, int debugLine, int debugCharacter) : super(value, debugLine, debugCharacter);
}



class ArrConstructor extends IndirectValue {
  final List<Value> value;

  ArrConstructor(this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class Execution {}
// ignore: deprecated_extends_function
class DartFunction extends DirectValue<Future<DirectValue> Function(List<DirectValue>,Execution)> {

  final int minParameters;
  final int maxParameters;

  DartFunction(this.minParameters,this.maxParameters,Future<DirectValue> Function(List<DirectValue> arguments, Execution ) value) : super(value, null, null); //null für keine Begrenzung

}

