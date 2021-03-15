import 'package:meta/meta.dart';
import '../instructions/instructions.dart';
import '../future_values/values.dart';


class Execution {}
enum SpecialValues { max, min, infinity, negative_infinity, absent } //negative infinity = operator vor infinity


//abs = SpecialValues.absent
//arr = List
//bol = bol
//fnc = Fnc
//int = int
//kom = double
//rng = Rng
//str = String
//typ = Typ

@immutable
class Rng {
  final int start;
  final int end;

  Rng(this.start, this.end);
}

enum TSType { abs, arr, bol, fnc, int, kom, rng, str, typ }
@immutable
class Typ {
  final Set<TSType> types;

  Typ operator +(Typ other) {
    return Typ(this.types..addAll(other.types));
  }

  Typ operator -(Typ other) {
    return Typ(this.types.intersection(other.types));
  }

  Typ.single(TSType single) : this.types = Set.of(List.unmodifiable([single]));

  Typ(this.types);
}


@immutable
abstract class TSFunction {}

@immutable
class Fnc {
  final Execution parent;
  final List<Instruction> instructions;

  Fnc(this.parent, FutureFunction function)
      : this.instructions = function.instructions;
}

