import 'package:talker/talker.dart';

class NotificationsLog extends TalkerLog {
  NotificationsLog(super.message);

  static get getTitle => 'Notifications';
  static get getKey => 'notifications';
  static get getPen => AnsiPen()..blue();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class NotificationsErrorLog extends TalkerLog {
  NotificationsErrorLog(String message, [dynamic error, StackTrace? stackTrace])
      : super('❌ $message', error: error, stackTrace: stackTrace);

  static get getTitle => 'Notifications';
  static get getKey => 'notifications_error';
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
