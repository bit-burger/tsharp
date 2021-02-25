const String allowed_characters_for_variables =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
const String allowed_characters_for_operators = ".:;*+-/#=!?\"\$%&^°`´<>";
const List<String> keywords = <String>[
  "var", "let", "params", "definition", "constant", "record",
  "operator", "prefix", "postfix",
  "return", "stop", "error",
  "if", "elif", "else", "assert",
  "while", "for",
  "use", "import",
];