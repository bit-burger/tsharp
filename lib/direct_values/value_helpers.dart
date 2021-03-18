import 'simple_values.dart';


TSType whichType(dynamic value, int debugLine, int debugCharacter, ) {
  if(value is List)
    return TSType.arr;
  if(value is bool)
    return TSType.bol;
  if(value is TSFunction)
    return TSType.fnc;
  if(value is int)
    return TSType.int;
  if(value is double)
    return TSType.kom;
  if(value is Rng)
    return TSType.rng;
  if(value is String)
    return TSType.str;
  if(value is Typ)
    return TSType.typ;
  if(value is SpecialValues) {
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

extension StringRepresentation on TSType {

  String get stringRep {
    switch (this) {
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

}