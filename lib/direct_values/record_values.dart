import 'dart:async';

import 'package:meta/meta.dart';

import '../execution/execution.dart';
import '../execution/root_execution.dart';

@immutable
class Record {
  final Future<dynamic> Function(Execution execution, RootExecution parentExecution, int debugLine, int debugCharacter) record;
  Record(this.record);
}

class ValueRecord extends Record {
  ValueRecord(dynamic value) : super((_,__,___,____)=>Future.value(value));

}

class SyncedRecord extends Record {

  SyncedRecord(dynamic Function(Execution execution, RootExecution parentExecution, int debugLine, int debugCharacter) function) : super((execution,parentExecution,line,character)=>Future.sync((){
    return function(execution, parentExecution, line, character);
  }));
}
