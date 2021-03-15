import 'package:meta/meta.dart';
import '../instructions/instructions.dart';


@immutable
class Closure {
  final List<Instruction> instructions;

  Closure(this.instructions);
}