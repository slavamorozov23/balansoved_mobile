import 'package:talker/talker.dart';

/// Base class for Comments feature logs
class CommentsLog extends TalkerLog {
  CommentsLog(super.message);

  /// Log title
  static get getTitle => 'Comments';

  /// Log key
  static get getKey => 'comments';

  /// Log color
  static get getPen => AnsiPen()..cyan();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}

/// Error log for Comments feature
class CommentsErrorLog extends TalkerLog {
  CommentsErrorLog(String message, [dynamic error, StackTrace? stackTrace])
      : super(
          '❌ $message',
          error: error,
          stackTrace: stackTrace,
        );

  /// Log title
  static get getTitle => 'Comments';

  /// Log key
  static get getKey => 'comments_error';

  /// Log color
  static get getPen => AnsiPen()..red();

  @override
  String get title => getTitle;

  @override
  String get key => getKey;

  @override
  AnsiPen get pen => getPen;
}
