import 'package:meta/meta.dart';
import 'dart:math';


@immutable
abstract class Value {

  final int debugLine;
  final int debugCharacter;

  Value(this.debugLine, this.debugCharacter);
}




class IndirectValue extends Value {
  IndirectValue(int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

abstract class Invocation extends IndirectValue {
  final String name;

  Invocation(this.name, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class VariableInvocation extends Invocation {
  VariableInvocation(String name, int debugLine, int debugCharacter) : super(name, debugLine, debugCharacter);

}

class RecordInvocation extends Invocation {
  RecordInvocation(String name, int debugLine, int debugCharacter) : super(name, debugLine, debugCharacter);

}

class TypeInvocation extends Invocation {
  TypeInvocation(String name, int debugLine, int debugCharacter) : super(name, debugLine, debugCharacter);

}

class FunctionCall extends IndirectValue {
  final Value parameters;
  final Value function;

  FunctionCall(this.parameters, this.function, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

class OperatorCall extends IndirectValue {
  final Value firstParameter;
  final Value secondParameter;
  
  final String operator;

  OperatorCall(this.firstParameter, this.secondParameter, this.operator, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
}

abstract class SingleParameterOperatorCall extends IndirectValue {
  final Value parameter;
  final String operator;

  SingleParameterOperatorCall(this.parameter, this.operator, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);

}

class PrefixCall extends SingleParameterOperatorCall {
  PrefixCall(Value parameter, String operator, int debugLine, int debugCharacter) : super(parameter, operator,debugLine, debugCharacter);
}

class PostfixCall extends SingleParameterOperatorCall {
  PostfixCall(Value parameter, String operator, int debugLine, int debugCharacter) : super(parameter, operator,debugLine, debugCharacter);
}


abstract class DirectValue<V> extends Value {
  final V value;
  DirectValue(this.value, int debugLine, int debugCharacter) : super(debugLine, debugCharacter);
  @override
  String toString() {
    return value.toString();
  }
}

abstract class NumberValue<Number extends num> extends DirectValue<Number> {
  NumberValue(Number value, int debugLine, int debugCharacter) : super(value,debugLine, debugCharacter);
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
  Int(int value, [int debugLine, int debugCharacter]) : super(value,debugLine, debugCharacter);
}

class Kom extends NumberValue<double> {
  Kom(double value, [int debugLine, int debugCharacter]) : super(value,debugLine, debugCharacter);
}

class Str extends DirectValue<String> {
  Str(String value, [int debugLine, int debugCharacter]) : super(value,debugLine, debugCharacter);
}

class Bol extends DirectValue<bool> {
  Bol(bool value, [int debugLine, int debugCharacter]) : super(value,debugLine, debugCharacter);
}

enum Type {int,kom,str,bol,abs,arr,fnc,typ}

class Typ extends DirectValue<List<Type>> {
  Typ(value, [int debugLine, int debugCharacter]) : super(value,debugLine, debugCharacter);
}

class Abs extends DirectValue{
  Abs([int debugLine, int debugCharacter]) : super(null,debugLine, debugCharacter);
}
