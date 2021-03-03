import 'package:meta/meta.dart';

import 'instructions.dart';
import 'examples.dart';
import 'constants.dart';
import 'values.dart';


@immutable
class TSUse {
  final Map<String, Typ> types;
  final Map<String, Value> register;
  final Map<String, ValueHolder> records;

  TSUse(this.types, this.register, this.records);

  factory TSUse.standart() {
    return TSUse(
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

    }, {},
    );
  }

}



class TS {}

class Execution {

}