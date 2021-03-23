import '../direct_values/simple_values.dart';


class Helper {

  static TSType whichType(
      dynamic value
      ) {
    if (value is List) return TSType.arr;
    if (value is bool) return TSType.bol;
    if (value is TSFunction) return TSType.fnc;
    if (value is int) return TSType.int;
    if (value is double) return TSType.kom;
    if (value is Rng) return TSType.rng;
    if (value is String) return TSType.str;
    if (value is Typ) return TSType.typ;
    if (value is SpecialValues) {
      switch (value) {
        case SpecialValues.absent:
          return TSType.abs;
        case SpecialValues.min:
          return TSType.int;
        case SpecialValues.max:
          return TSType.int;
        case SpecialValues.infinity:
          return TSType.kom;
        case SpecialValues.negative_infinity:
          return TSType.kom;
      }
    }
    throw Exception();
  }


  static String stringOfType(TSType type) {
      switch (type) {
        case TSType.abs:
          return "abs";
        case TSType.arr:
          return "arr";
        case TSType.bol:
          return "bol";
        case TSType.fnc:
          return "fnc";
        case TSType.int:
          return "int";
        case TSType.kom:
          return "kom";
        case TSType.rng:
          return "rng";
        case TSType.str:
          return "str";
        case TSType.typ:
          return "typ";
      }
      throw Exception();
  }

  static bool isType(dynamic value, TSType type) => whichType(value) == type;

  static bool isTypeTyp(dynamic value, Typ type) => type.types.contains(whichType(value));

  static bool containsType(TSType type, Typ typ) => typ.types.contains(type);

  static bool same(Typ first, Typ second) =>
      first.types.containsAll(second.types) &&
          second.types.containsAll(first.types);
}

