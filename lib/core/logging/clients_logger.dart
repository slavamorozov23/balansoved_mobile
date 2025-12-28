import 'package:talker/talker.dart';

class ClientsLog extends TalkerLog {
  ClientsLog(super.message);

  static get getTitle => 'Clients';
  static get getKey => 'clients';
  static get getPen => AnsiPen()..yellow();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class ClientsErrorLog extends TalkerLog {
  ClientsErrorLog(String message, [dynamic error, StackTrace? stackTrace])
      : super('❌ $message', error: error, stackTrace: stackTrace);

  static get getTitle => 'Clients';
  static get getKey => 'clients_error';
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
