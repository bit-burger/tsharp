import 'parse_debug.dart' show Klammer;



void parseLists(
    String s,
    void Function(String s, int line, int character) forEach,
    int line,
    int character) {
  var listItem = "";
  final klammern = <Klammer>[];
  bool wasBackslash = false;
  int itemLine;
  int itemCharacter;
  character -= 1;
  bool onKomma() {
    if (klammern.isEmpty) {
      if (itemLine == null) {
        forEach(null, line, character);
      } else {
        forEach(listItem.trim(), itemLine, itemCharacter);
        itemLine = null;
        itemCharacter = null;
      }
      listItem = "";
      return true;
    }
    return false;
  }

  final List<String> split = s.split("");
  split.forEach((char) {
    character++;
    if (char == ",") {
      if (onKomma()) return;
    } else if (char == "\n") {
      line++;
      character = 0;
      listItem += char;
      return;
    } else if (char == "\"") {
      if (!wasBackslash) {
        if (klammern.isEmpty||klammern.last.klammer!="\"")
          klammern.add(Klammer(char, line, character));
        else if (klammern.last.klammer == "\"") klammern.removeLast();
      }
    } else if (char == "{" || char == "(" || char == "[") {
      if (klammern.isEmpty || klammern.last.klammer != "\"")
        klammern.add(Klammer(char, line, character));
    } else if (char == "}" || char == ")" || char == "]") {
      if (klammern.isNotEmpty && klammern.last.klammer == "\"")
        ;
      else if ((klammern.last.klammer == "{" && char == "}") ||
          (klammern.last.klammer == "(" && char == ")") ||
          (klammern.last.klammer == "[" && char == "]")) klammern.removeLast();
    }
    if (itemCharacter == null && char != " ") {
      itemLine = line;
      itemCharacter = character;
    }
    if (wasBackslash) {
      wasBackslash = false;
    } else if (char == "\\") {
      wasBackslash = true;
    }
    listItem += char;
  });
  onKomma();
}