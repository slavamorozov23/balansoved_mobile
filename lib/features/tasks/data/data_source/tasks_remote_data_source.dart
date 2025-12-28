import 'package:balansoved_mobile/features/tasks/data/models/task_model.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';

/// Результат запроса задач с сервера
class TasksApiResult {
  final List<TaskModel> tasks;
  final TaskPaginationMeta? paginationMeta;

  const TasksApiResult({required this.tasks, this.paginationMeta});
}

abstract class TasksRemoteDataSource {
  /// Получить задачи по параметрам запроса
  Future<TasksApiResult> getTasks(String firmId, TaskRequestParams params);

  /// Получить одну задачу по ID
  Future<TaskModel> getTask(String firmId, String taskId, {bool onlyMy = true});

  /// Сохранить задачу
  Future<String> saveTask(String firmId, TaskModel task);

  /// Удалить задачу
  Future<void> deleteTask(String firmId, String taskId);
}
