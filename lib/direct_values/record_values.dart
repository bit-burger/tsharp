import 'package:meta/meta.dart';

class Execution {} class ParentExecution {}

@immutable
abstract class Record {
  final Future<dynamic> Function(Execution execution, ParentExecution parentExecution, int debugLine, int debugCharacter) record;

  Record(this.record);
}
