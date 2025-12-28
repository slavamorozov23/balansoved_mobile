import 'package:talker/talker.dart';

class FirmsLog extends TalkerLog {
  FirmsLog(super.message);

  static get getTitle => 'Firms';
  static get getKey => 'firms';
  static get getPen => AnsiPen()..cyan();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class FirmsErrorLog extends TalkerLog {
  FirmsErrorLog(String message, [dynamic error, StackTrace? stackTrace])
      : super('❌ $message', error: error, stackTrace: stackTrace);

  static get getTitle => 'Firms';
  static get getKey => 'firms_error';
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
