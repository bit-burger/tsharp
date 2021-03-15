import 'package:meta/meta.dart';

import 'package:tsharp/direct_values/simple_values.dart';
import '../direct_values/record_values.dart';
import '../future_values/values.dart';

class Execution {

}
class ParentExecution extends Execution {

}




@immutable
class Library {
  final Map<String, Typ> types;
  final Map<String, dynamic> variables;
  final Map<String, Record> records;
  final Map<String, FutureValue> operators;
  final Map<String, FutureValue> prefix;
  final Map<String, FutureValue> postfix;

  Library(this.types, this.variables, this.records, this.operators, this.prefix, this.postfix);

  factory Library.standart() {
    return Library(
      {
        "num": Typ(
          Set.from([
            TSType.kom,
            TSType.int,
          ]),
        ),
        "any": Typ(Set.from([
          TSType.abs,
          TSType.arr,
          TSType.bol,
          TSType.fnc,
          TSType.int,
          TSType.kom,
          TSType.rng,
          TSType.str,
          TSType.typ,
        ])),
        "nab": Typ(Set.from([
          TSType.arr,
          TSType.bol,
          TSType.fnc,
          TSType.int,
          TSType.kom,
          TSType.rng,
          TSType.str,
          TSType.typ,
        ])),
        "nfn": Typ(Set.from([
          TSType.arr,
          TSType.bol,
          TSType.int,
          TSType.kom,
          TSType.rng,
          TSType.str,
          TSType.typ,
        ])),
        "pri": Typ(Set.from([
          TSType.bol,
          TSType.int,
          TSType.kom,
          TSType.str,
        ])),
        "ite": Typ(Set.from([
          TSType.arr,
          TSType.rng,
          TSType.str,
        ])),
        "acc": Typ(Set.from([
          TSType.arr,
          TSType.str,
        ])),
      }, {

    }, {},null,null,null,
    );
  }

}



class TS {}



//TSType != Typ
TSType whichType(dynamic value) {
  if(value is int)
    return TSType.int;
  if(value is double)
    return TSType.kom;
  if(value is String)
    return TSType.str;
  if(value is bool)
    return TSType.bol;
  if(value is List)
    return TSType.arr;
  if(value is Typ)
    return TSType.typ;
  if(value is TSFunction)
    return TSType.fnc;
  if(value is bool)
    return TSType.bol;

  if(value is Range)
    return TSType.rng;
  if(value is )
    return TSType.int;

}