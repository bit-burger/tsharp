import 'package:meta/meta.dart';
import 'package:tsharp/debug.dart';

class RunTimeException extends TextDebugObject implements Exception {

  final String message;

  final Stack stack;

  RunTimeException(this.message, TextDebugObject debugObject, this.stack)
      : super(debugObject.debugLine,
            debugObject.debugCharacter, debugObject.secondCharacter);
}

@immutable
class ValueHolder {
  final String name;

  ValueHolder(this.name);

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