import 'package:talker/talker.dart';

class TasksLog extends TalkerLog {
  TasksLog(super.message);

  static get getTitle => 'Tasks';
  static get getKey => 'tasks';
  static get getPen => AnsiPen()..magenta();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class TasksErrorLog extends TalkerLog {
  TasksErrorLog(String message, [dynamic error, StackTrace? stackTrace])
      : super('❌ $message', error: error, stackTrace: stackTrace);

  static get getTitle => 'Tasks';
  static get getKey => 'tasks_error';
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
