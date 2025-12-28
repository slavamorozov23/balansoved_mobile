import 'package:talker/talker.dart';

/// Base class for Auth feature logs
class AuthLog extends TalkerLog {
  AuthLog(String super.message);

  /// Log title
  static get getTitle => 'Auth';

  /// Log key
  static get getKey => 'auth';

  /// Log color
  static get getPen => AnsiPen()..blue();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

/// Error log for Auth feature
class AuthErrorLog extends TalkerLog {
  AuthErrorLog(String message, [dynamic error, StackTrace? stackTrace])
    : super('❌ $message', error: error, stackTrace: stackTrace);

  /// Log title
  static get getTitle => 'Auth';

  /// Log key
  static get getKey => 'auth_error';

  /// Log color
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
