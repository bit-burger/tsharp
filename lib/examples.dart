import 'dart:io';

import 'package:tsharp/tsharp.dart';
import 'dart:typed_data';
import 'package:meta/meta.dart';

final example1 = '''
var a
a = 3
var b = 54
b = 232323
var c = 5
var f = <alödj>
a = (df){
  c = 5
  var d = (x){
    c = 10
    var c = 11
    f = x
  } 
  d(df)
}
a(25)

''';
final example2 = '''
var a = 2
var b = (d,d   ,e, d){
a = 3
}
b(5,5,5,5)
''';
final example3 = '''
var b
var a = (c){
  b = c
}
a(3)

''';
final example4 = '''
var b
var c
var a = (d,e){
  b = d
  c = e
}
a(5,10)

''';
final example5 = '''
var a
constant b = (d){
  var c = (e){
    a = e
  }
  c(d)
}
b(15)
''';

final example6 = '''
var a 
(){
a = b
}()
''';

final example7 = '''
var a 
(){
  (){
    a = 34
  }()
}(34)
''';

final example8 = '''
var a = <haha>
var b = (c){
  c()
}
b((){
  a = 5
})

''';
final example9 = '''
var a = 2
var b = (c,d){
c(d)
}
b((a){
a()
},(){
a = 4
})
''';
final example11 = '''
var a
var b = (e,f){
e(f)()
}
b((g){
    return (){
      a = g
    }
  },
  10
)
''';
//besitzt wohl einen falschen parent und kann deshalb auf e zugreifen aber nicht auf g
final example12 = '''
var b = (){
return (){
return 4
}
}
var a = b()()

''';
//error exapmles
const example13 = '''
var a = <4>
(){
a = 45
}()

''';

const example17 = '''
var a = (b){
  return b()
}
(b){
  a = b(b((){
    return (){
      return <yallah habibi>
    }
  }))
}(a)
''';

const example18 = '''
var a   =       either(  and(true  ,  false)  , or(  true  ,true  ))
var b = (){
return 2345
}()
var d = 2345
var c = equals(b,d)
var f
var k = type(d,5.0)
''';

const example19 = '''
let a = 45
var b = 56


(){
b = 0

a = 34
}
''';
const example20 = '''
let a = equals(2,input(<hihi>))
''';

const example21 = '''
var hi
let a = formatted_input()
a()
''';

class ParseException {
  final int line;
  final int character;
  final String message;

  ParseException(this.line, this.character, this.message);
}

class FinishedParseException extends ParseException {
  FinishedParseException(int line, int character, String message)
      : super(line, character, message);
}

class Klammer {
  final String klammer;
  final int character;
  final int line;

  Klammer(this.klammer, this.character, this.line);
}

class TS {
  static String generateErrorShow(String line, int character) {
    return "  " + line + "\n  " + (" " * character) + "^\n";
  }

  Function(int lineNumber, int characterNumber, String line, String message,
      String fullError) onError;

  Future<String> Function(String message) input;

  Function(String) output;

  TS({
    @required this.output,
    @required this.input,
    @required this.onError,
  });
}

//var i = 0 sind zwei verschiedene instructions, Declration und assignment
//operator: :%"!?/&|*+-^°=.`´


// ' ist kommentar
List<Instruction> parse(String s, [List<String> parameters]) {
  var rawInstruction = <String>[""];
  final instructions = <Instruction>[];
  final klammern = <Klammer>[];
  var line = 0;
  var character = -1;
  try {
    s.split("").forEach((char) {
      character++;
      if (char == " ") {
        if (klammern.isNotEmpty) {
          rawInstruction.last += char;
        } else if (rawInstruction.last.isNotEmpty) {
          rawInstruction.add("");
        }
        return;
      } else if (char == "\n") {
        line++;
        character = -1;
        if (klammern.isEmpty) {
          print(rawInstruction);
          rawInstruction = [""];
          //instruction code
        } else {
          rawInstruction.last += char;
        }
        return;
      } else if (char == "{" || char == "(" || char == "<" || char == "[") {
        if (klammern.isNotEmpty && klammern.last == "<") return;
        klammern.add(Klammer(char, character, line));
      } else if (char == "}" || char == ")" || char == "]" || char == ">") {
        if (klammern.isEmpty)
          throw ParseException(line, character,
              "bracket \"$char\" on line $line, is unnecesary");
        else if (klammern.last.klammer == "<") {
          if (char == ">") {
            klammern.removeLast();
          }
        } else if ((klammern.last.klammer == "{" && char == "}") ||
            (klammern.last.klammer == "(" && char == ")") ||
            (klammern.last.klammer == "[" && char == "]"))
          klammern.removeLast();
        else {
          List<String> textSplit = s.split("\n");
          String openingBracketLine = textSplit[klammern.last.line];
          String closingBracketLine = textSplit[line];
          throw FinishedParseException(
            null,
            null,
            "[NAME]:${line}:${character}:Closing bracket \"${char}\" not matching opening bracket \"${klammern.last.klammer}\"\n\n" +
                "Opening:\n" +
                TS.generateErrorShow(
                  openingBracketLine +
                      " (${klammern.last.line}:${klammern.last.character})",
                  klammern.last.character,
                ) +
                "Closing:\n" +
                TS.generateErrorShow(
                  closingBracketLine + " (${line}:${character})",
                  character,
                ),
          );
        }
      }
      rawInstruction.last += char;
    });
    if (klammern.isNotEmpty) {
      if (klammern.last.klammer == "<")
        throw ParseException(klammern.last.line, klammern.last.character,
            "String has to be closed");
      else
        throw ParseException(klammern.last.line, klammern.last.character,
            "Bracket \"${klammern.last.klammer}\" is unnecessary");
    }
  } on ParseException catch (error) {
    if (error is FinishedParseException)
      print("***ERROR***\n\n${error.message}");
    else {
      String line = s.split("\n")[error.line];
      print("[NAME]:${error.line}:${error.character}:${error.message}\n" +
          TS.generateErrorShow(
            line + " (${klammern.last.line}:${klammern.last.character})",
            error.character,
          ));
    }
  }
  return null;
}

//BETA

const s = '''
{ öalsdjf }
''';

const smallExample = '''
var a
let func = @Int
a = isType(<>,@Int



){{{{{{
''';

void main() {
  List klammern = [];
  parse(smallExample);
  // Main(smallExample);
}
