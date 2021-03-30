import 'package:tsharp/constants.dart';
import 'package:tsharp/debug.dart';

import 'parse_debug.dart';
import 'extensions.dart';

enum ParseExceptionImportance {
  ERROR, //Should be put in stream, the instructions are not valid
  INSTRUCTION_ERROR,
  EXCEPTION, //Should not be put in stream, goes all the way up to the Parse mixin
  FAILURE, //Should not be put in stream, goes all the way up to the Parse mixin, indicates error
}

extension on ParseExceptionImportance {
  StreamEventType toStreamEvents() {
    switch (this) {
      case ParseExceptionImportance.ERROR:
        return StreamEventType.ERROR;
      case ParseExceptionImportance.INSTRUCTION_ERROR:
        return StreamEventType.ERROR;
      case ParseExceptionImportance.EXCEPTION:
        return StreamEventType.EXCEPTION;
      case ParseExceptionImportance.FAILURE:
        return StreamEventType.FAILURE;
    }
  }
}

enum StreamEventType {
  WARNING,
  ERROR,
  EXCEPTION,
  FAILURE,
}

extension on StreamEventType {
  String stringRepresentation() {
    switch (this) {
      case StreamEventType.WARNING:
        return "WARNING";
      case StreamEventType.ERROR:
        return "ERROR";
      case StreamEventType.EXCEPTION:
        return "TERMINATING_ERROR";
      case StreamEventType.FAILURE:
        return "SYSTEM_ERROR";
    }
  }
}

class ParseExceptionPart extends TextDebugObject {
  final String message;

  String asErrorLog(List<String> split) {
    return TSException.generateErrorShow(
            split[this.debugLine - 1] + "  [$debugLine:$debugCharacter]",
            this.debugCharacter - 1,
            this.secondCharacter == null ? null : secondCharacter! - 1) +
        "\n";
  }

  String asErrorLogWithMessage(List<String> split) {
    return error_space + message + asErrorLog(split);
  }

  ParseExceptionPart(this.message, int debugLine, int debugCharacter,
      [int? secondDebugCharacter])
      : super(debugLine, debugCharacter, secondDebugCharacter);

  @override
  bool operator ==(Object other) => other is ParseExceptionPart && other.message == this.message && super==(other);
}

class ParseException implements Exception {
  final String? errorTitle;
  final List<ParseExceptionPart> errors;
  final ParseExceptionImportance importance;

  ParseException(this.errorTitle, this.errors, this.importance);

  factory ParseException.singleWithExtraString(
      String message, int debugLine, int debugCharacter, String restString,
      [String? referenceString]) {
    int secondCharacter = restString.length + debugCharacter;
    final int alternativeCharacter =
        (referenceString ?? restString).split("\n").first.length +
            debugCharacter -
            1;
    if (alternativeCharacter < secondCharacter)
      secondCharacter = alternativeCharacter;
    return ParseException.single(
        message, debugLine, debugCharacter, secondCharacter);
  }

  factory ParseException.token(String message, Token token) =>
      ParseException.single(message, token.line!, token.character!);

  factory ParseException.tokens(String message, List<Token> tokens) =>
    ParseException.token(message, tokens.combine());


  factory ParseException.single(
    String message,
    int debugLine,
    int debugCharacter, [
    int? secondDebugCharacter,
    ParseExceptionImportance importance = ParseExceptionImportance.ERROR,
  ]) {
    return ParseException(
      null,
      [
        ParseExceptionPart(
          message,
          debugLine,
          debugCharacter,
          secondDebugCharacter,
        ),
      ],
      importance,
    );
  }

  factory ParseException.unknown(int debugLine, int debugCharacter,
      [int? secondDebugCharacter]) =>
      ParseException.single(
        "Unknown expression. ",
        debugLine,
        debugCharacter,
        secondDebugCharacter,
      );
}



class ParseDebugStream {
  final List<ParseDebugStreamEvent> events;

  ParseDebugStream() : this.events = <ParseDebugStreamEvent>[];

  bool canEvaluateExceptionDirectly(var exception) =>
      exception is ParseException &&
      (exception.importance == ParseExceptionImportance.INSTRUCTION_ERROR ||
          exception.importance == ParseExceptionImportance.ERROR);

  void processException(var exception) {
    if (canEvaluateExceptionDirectly(exception)) {
      events.add(
        ParseDebugStreamEvent(
          (exception as ParseException).errorTitle,
          exception.errors,
          exception.importance.toStreamEvents(),
        ),
      );
    } else {
      throw exception;
    }
  }

  void warning(String message, int line, int character) {
    custom(message, line, character, StreamEventType.WARNING);
  }

  void tokenWarning(String message, Token token) {
    warning(message, token.line!, token.character!);
  }

  void error(String message, int line, int character) {
    custom(message, line, character, StreamEventType.ERROR);
  }

  void tokenError(String message, Token token) {
    error(message, token.line!, token.character!);
  }

  void custom(
      String message, int line, int character, StreamEventType eventType) {
    events.add(ParseDebugStreamEvent(
        null, [ParseExceptionPart(message, line, character)], eventType));
  }

  String asErrorLog(dynamic l, List<String> split) {
    String s = "";
    for (int i = 0; i < events.length; i++) {
      assert(i < events.length - 1 ||
          (events[i].errorType != StreamEventType.EXCEPTION &&
              events[i].errorType != StreamEventType.FAILURE));
      s += events[0].asErrorLog(l, split);
    }
    return s;
  }
}

class ParseDebugStreamEvent {
  String get errorTitle => _errorTitle ?? errorContent.first.message;

  final String? _errorTitle;
  final List<ParseExceptionPart> errorContent;
  final StreamEventType errorType;

  ParseDebugStreamEvent(this._errorTitle, this.errorContent, this.errorType)
      : assert(errorContent.length > 0),
        assert(errorContent.length == 2 || _errorTitle == null);

  String asErrorLog(dynamic l, List<String> split) {
    String baseString = l.toString() +
        ":${errorContent[0].debugLine}:"
            "${errorContent[0].debugCharacter}:"
            "${errorType.stringRepresentation()}: "
            "$errorTitle${errorTitle.contains("\n") ? "\n" : ":"}\n";
    if (_errorTitle == null) {
      baseString += errorContent.first.asErrorLog(split) + "\n";
    } else {
      for (ParseExceptionPart part in errorContent) {
        baseString += part.asErrorLogWithMessage(split) + "\n";
      }
    }
    baseString += "\n";
    return baseString;
  }

  @override
  bool operator ==(Object other) =>
      other is ParseDebugStreamEvent &&
      other.errorTitle == this.errorTitle &&
      other.errorType == this.errorType &&
      other.errorContent == this.errorContent;
}
