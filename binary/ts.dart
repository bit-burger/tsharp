import 'dart:convert';
import 'dart:io';


import 'package:tsharp/legacyTSHARP.dart';
import 'package:args/args.dart';



void main(List<String> arguments) async {
  final parser = ArgParser();
  final results = parser.parse(arguments);
  final  rest  = results.rest;
  if(rest.isEmpty) {
    print("1 file man");
    return;
  } else if(rest.length>1) {
    print("1 file man");
    return;
  }

  final path = rest.first;
  final lines = utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());
  var text = "";
  await for (var line in lines) {
    text += line + '\n';
  }
  text = text.substring(0,text.length-1);
  Main(text);
}
