import 'package:tsharp/direct_values/simple_values.dart' show TSType, Typ;

final types = {
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
};
