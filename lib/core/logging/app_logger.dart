import 'package:talker/talker.dart';

class AppLog extends TalkerLog {
  AppLog(String super.message);

  static get getTitle => 'App';
  static get getKey => 'app';
  static get getPen => AnsiPen()..cyan();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class AppErrorLog extends TalkerLog {
  AppErrorLog(String message, [dynamic error, StackTrace? stackTrace])
    : super('Error: $message', error: error, stackTrace: stackTrace);

  static get getTitle => 'App';
  static get getKey => 'app_error';
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
