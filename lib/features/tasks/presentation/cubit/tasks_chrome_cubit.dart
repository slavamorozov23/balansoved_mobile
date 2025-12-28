import 'package:flutter_bloc/flutter_bloc.dart';

/// Управляет видимостью "хрома" на странице задач (поиск/фильтры).
///
/// `true`  — фильтры скрыты (режим фокуса)
/// `false` — фильтры показаны
class TasksChromeCubit extends Cubit<bool> {
  TasksChromeCubit() : super(false);

  bool get isCollapsed => state;

  void setCollapsed(bool collapsed) => emit(collapsed);

  void collapse() => emit(true);

  void expand() => emit(false);
}

