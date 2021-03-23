import 'package:meta/meta.dart';

const String allowed_characters_for_identifiers =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
const String forbidden_characters_for_variables = "ḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏḐḑḒḓḔḕḖḗḘḙḚḛḜḝḞḟḠḡḢḣḤḥḦḧḨḩḪḫḬḭḮḯḰḱḲḳḴḵḶḷḸḹḺḻḼḽḾḿṀṁṂṃṄṅṆṇṈṉṊṋṌṍṎṏṐṑṒṓṔṕṖṗṘṙṚṛṜṝṞṟṠṡṢṣṤṥṦṧṨṩṪṫṬṭṮṯṰṱṲṳṴṵṶṷṸṹṺṻṼṽṾṿẀẁẂẃẄẅẆẇẈẉẊẋẌẍẎẏẐẑẒẓẔẕẖẗẘẙẚẛẜẝẞẟẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳỴỵỶỷỸỹỺỻỼỽỾỿ";

const String allowed_characters_for_operators = ".:;*+-~/#=!?%&^°`´<>";
const List<String> keywords = <String>[
  "var", "let", "params", "define", "constant", "record",
  "operator", "prefix", "postfix", "event",
  "assignment", "call", "delete",
  "return", "stop", "error", "kill",
  "if", "else", "assert",
  "while", "for",
  "use", "import",
  //Optional: ["params","assignment","call"]
];

const List<String> conditionals = <String>[
  "if", "while", "for"
];

const List<String> standart_values = [
  "true", "false", "absent", "function", "_", "infinity", "min", "max"
];
const Map<String,String> backslashable_characters = {
  "n" : "\n",
  "\\" : "\\",
  "\"" : "\"",
};

const String backslashable_characters_as_string = "\\n, \\\\, \\\"";

const List<String> forbidden_operators = [
  "=", "+=", "-=", "*=", "/="
];

const List<String> ignored_operators = [
  ".",
];



//anstatt List<List<String>>, List<Set<String>>
const operator_higher_precedence = [
  [";",".","...","..<"],
  [":","::",":?",":??"],
];

const operator_lower_precedence = [
  ["%","^"],
  ["*","/","//","~/"],
  ["+","-"],
  ["<>","><"],
  ["<",">","<=",">=","==","===","===="],
  ["??,?"],
  ["||","|"],
  ["&&"],
];



final operator_precedence_length = operator_lower_precedence.length + operator_higher_precedence.length + 1;


const prefixes = [
  ["-","+","!"]
];

const postfixes = [
  ["?",";","!","++","--"]
];

const anonymous_function_name = "[Anonymous]";

