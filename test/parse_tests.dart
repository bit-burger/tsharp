import 'package:test/test.dart';
import 'package:tsharp/future_values/values.dart';

import 'package:tsharp/parsing/value_parsing.dart';
import 'package:tsharp/parsing/parse_debug.dart';
import 'package:tsharp/parsing/extensions.dart';

class O extends Operator {
  O(String operator) : super(operator,null,null,null);
}

void main() {

  test("Test an operator parsing", (){

    expect(Operator.mostImportant([O("&&"),O("*"),O("-")]).operator, "*");
    expect(Operator.mostImportant([O("-"),O("*"),O("....")]).operator, "....");

    OperatorCall value = parseValue("234+234 * 4", 1, 1) as OperatorCall;
    expect(value.function, "*");
  });

}