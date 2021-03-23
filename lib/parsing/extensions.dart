extension FirstLastList<Element> on List {
  Element get firstNullable {
    return this.length == 0 ? null : this[0];
  }

  Element get lastNullable {
    return this.length == 0 ? null : this[this.length - 1];
  }
}

extension PrettyPrint<Element> on List {
  String get prettyPrint {
    if (this.isEmpty) return "";
    String returnValue = "";
    for (Element element in this) {
      returnValue += element.toString() + ", ";
    }
    return returnValue.substring(0, returnValue.length - 2);
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
    for(String s in ls) {
      if(this.startsWith(s)) return true;
    }
    return false;
  }

  bool endsWithOneOf(List<String> ls) {
    for(String s in ls) {
      if(this.endsWith(s)) return true;
    }
    return false;
  }

}

extension ContainsWhere<Item> on List<List<Item>> {
  int containsWhere(Item match) {
    for(int i = 0; i < this.length; i++)
      for(int j = 0; j < this[i].length; j++)
        if(match == this[i][j])
          return i;
    return null;
  }
}