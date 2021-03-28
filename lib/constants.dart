import 'package:meta/meta.dart';

const String allowed_characters_for_identifiers =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
const String forbidden_characters_for_variables =
    "ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏḐḑḒḓḔḕḖḗḘḙḚḛḜḝḞḟḠḡḢḣḤḥḦḧḨḩḪḫḬḭḮḯḰḱḲḳḴḵḶḷḸḹḺḻḼḽḾḿṀṁṂṃṄṅṆṇṈṉṊṋṌṍṎṏṐṑṒṓṔṕṖṗṘṙṚṛṜṝṞṟṠṡṢṣṤṥṦṧṨṩṪṫṬṭṮṯṰṱṲṳṴṵṶṷṸṹṺṻṼṽṾṿẀẁẂẃẄẅẆẇẈẉẊẋẌẍẎẏẐẑẒẓẔẕẖẗẘẙẚẛẜẝẞẟẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳỴỵỶỷỸỹỺỻỼỽỾỿ";

const String allowed_characters_for_operators = ".:;*+-~/#=!?%&^°`´<>";

const String allowed_characters_for_values = "0123456789\"";

const String allowed_grouping_and_listing = "(){}[],";

const String allowed_identifier_modifiers = "@#\$";

const String allowed_comment_starters = "'";

const String allowed_whitespace = " \n";

const String allowed_characters =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_.:;*+-~/#=!?%&^°`´<> \n'@#";

const Set<String> keywords = <String>{
  "var", "let", "params", "define", "constant", "record",
  "operator", "prefix", "postfix", "event",
  "assignment", "call", "delete",
  "return", "stop", "error", "kill", "back",
  "if", "else", "guard", "assert",
  "while", "for",
  "use", "import",
  //Optional: ["params","assignment","call"]
};

const Set<String> extendable = <String>{
  "if",
  "while",
  "for",
  "else",
  "return",
  "assert",
  "guard",
};

const Set<String> standart_values = {
  "true",
  "false",
  "absent",
  "function",
  "_",
  "infinity",
  "min",
  "max"
};
const Map<String, String> backslashable_characters = {
  "n": "\n",
  "\\": "\\",
  "\"": "\"",
};

const Map<String, String> brackets = {
  "{": "}",
  "(": ")",
  "[": "]",
};

const String backslashable_characters_as_string = "\\n, \\\\, \\\"";

const Set<String> forbidden_operators = {"=", "+=", "-=", "*=", "/="};

const Set<String> ignored_operators = {"."};

//anstatt List<List<String>>, List<Set<String>>
const List<Set<String>> operator_higher_precedence = [
  {";", ".", "...", "..<"},
  {":", "::", ":?", ":??"},
];

const List<Set<String>> operator_lower_precedence = [
  {"%", "^"},
  {"*", "/", "//", "~/"},
  {"+", "-"},
  {"<>", "><"},
  {"<", ">", "<=", ">=", "==", "===", "===="},
  {"??", "?"},
  {"||", "|"},
  {"&&"},
];

final operator_precedence_length =
    operator_lower_precedence.length + operator_higher_precedence.length + 1;

const prefixes = [
  ["-", "+", "!"]
];

const postfixes = [
  ["?", ";", "!", "++", "--"]
];
const error_space = "    ";
const anonymous_function_name = "[Anonymous]";
