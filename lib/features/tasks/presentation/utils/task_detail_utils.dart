import 'package:intl/intl.dart';

class TaskDetailUtils {
  static String formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return DateFormat('dd.MM.yyyy').format(dt);
  }
}
