import 'package:meta/meta.dart';
import 'package:tsharp/debug.dart';

class RunTimeException extends TSException {

  final Stack stack;

  RunTimeException(String message, DebugObject debugObject, this.stack)
      : super(message, debugObject.debugLine,
            debugObject.debugCharacter, null);
}

@immutable
class ValueHolder {
  final String name;
  final bool isConstant;
  final bool isLibrary;

  ValueHolder(this.name,{this.isConstant = false, this.isLibrary = false});

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ValueHolder && this.name == other.name;
}

@immutable
class Stack {
  final String stack;

  Stack(this.stack);

}