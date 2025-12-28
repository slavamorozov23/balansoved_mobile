import 'package:talker/talker.dart';

class EmployeesLog extends TalkerLog {
  EmployeesLog(super.message);

  static get getTitle => 'Employees';
  static get getKey => 'employees';
  static get getPen => AnsiPen()..yellow();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

class EmployeesErrorLog extends TalkerLog {
  EmployeesErrorLog(String message, [dynamic error, StackTrace? stackTrace])
      : super('❌ $message', error: error, stackTrace: stackTrace);

  static get getTitle => 'Employees';
  static get getKey => 'employees_error';
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
