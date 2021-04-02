import 'parse_debug.dart';

extension FirstLastList<Element> on List {
  Element get firstNullable {
    return this.length == 0 ? null : this[0];
  }

  Element get lastNullable {
    return this.length == 0 ? null : this[this.length - 1];
  }
}

extension PrettyPrint<Element> on List {
  String prettyPrint({String ending = ", "}) {
    if (this.isEmpty) return "";
    String returnValue = "";
    for (Element element in this) {
      returnValue += element.toString() + ending;
    }
    return returnValue.substring(0, returnValue.length - ending.length);
  }
}

extension SameLength on List<String> {
  int get _maxStringLength {
    int maxLength = this[0].length;
    for (String s in this) if (s.length > maxLength) maxLength = s.length;
    return maxLength;
  }

  int get maxStringLength {
    if (this.length == 0)
      return 0;
    else
      return _maxStringLength;
  }

  List<String> toSameLength({String filler = " ", int extraLength = 0}) {
    if (this.length == 0) return this;
    final maxLength = _maxStringLength;
    return this.map<String>((s) {
      return s + filler * (s.length - maxLength + extraLength);
    }).toList();
  }
}

extension Containing on String {
  bool containsOneOf(String tester) {
    for (String char in this.split("")) {
      if (!tester.contains(char)) return false;
    }
    return true;
  }

  bool startsWithOneOf(List<String> ls) {
    for (String s in ls) {
      if (this.startsWith(s)) return true;
    }
    return false;
  }

  bool endsWithOneOf(List<String> ls) {
    for (String s in ls) {
      if (this.endsWith(s)) return true;
    }
    return false;
  }
}

extension ContainsWhere<Item> on List<List<Item>> {
  int? containsWhere(Item match) {
    for (int i = 0; i < this.length; i++)
      for (int j = 0; j < this[i].length; j++)
        if (match == this[i][j]) return i;
    return null;
  }
}

extension OneMatrixDown<Item> on List<List<Item>> {
  List<Item> oneMatrixDown() {
    List<Item> returnList = <Item>[];
    for (List<Item> list in this) returnList.addAll(list);
    return returnList;
  }
}

// extension Combine on List<String> {
//   String get combined {
//     String s = "";
//     for(String _s in this)
//       s += _s;
//     return s;
//   }
// }

extension Combine on List<Token> {
  Token combine() {
    if (this.length < 1) return Token();

    Token token = this.first;
    for (int i = 1; i < this.length; i++) {
      if (token.line != this[i].line) break;
      final split = this[i].token.split("\n");
      token.token += (" " *
              (this[i].character! - (token.character! + token.token.length))) +
          split.first;
      if (split.length > 1) break;
    }
    return token;
  }
}
