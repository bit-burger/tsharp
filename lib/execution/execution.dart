import 'package:meta/meta.dart';

import '../direct_values/simple_values.dart';
import '../direct_values/record_values.dart';

import 'runtime_classes.dart';

class Execution {
  
  final Map<String, dynamic> variables;
  final Map<String, Typ> types;
  final Map<String, Record> records;
  final Map<String, String> operators;
  final Map<String, String> prefixes;
  final Map<String, String> postfixes;

  Execution(this.variables, this.types, this.records, this.operators, this.prefixes, this.postfixes);
  
}
//viele aufwendige assertions für den debug mode!
//TSType != Typ
