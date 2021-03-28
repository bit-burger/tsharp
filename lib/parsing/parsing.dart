import '../instructions/instructions.dart';
import 'parse_debug.dart';
import 'parse_error_handling.dart';

mixin Parser {

  void parseError(String completeError, List<StreamEvent> events, StreamEventType worstEventType, bool stopsExecution) {

  }

  List<Instruction> parse<Location>(String s, Location location) {
    final stream = ParseDebugStream();
    try {

    } on ParseException catch (error) {

    } catch (error) {

    }

  }
}