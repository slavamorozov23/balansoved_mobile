import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:equatable/equatable.dart';

/// Результат запроса задач с возможными метаданными пагинации
class TasksResult extends Equatable {
  final List<TaskEntity> tasks;
  final TaskPaginationMeta? paginationMeta; // Только для бессрочных задач

  const TasksResult({required this.tasks, this.paginationMeta});

  @override
  List<Object?> get props => [tasks, paginationMeta];
}

abstract class TasksRepository {
  /// Получить задачи по заданным параметрам
  Future<Either<Failure, TasksResult>> getTasks(
    String firmId,
    TaskRequestParams params,
  );

  /// Получить одну задачу по ID
  Future<Either<Failure, TaskEntity>> getTask(
    String firmId,
    String taskId, {
    bool onlyMy = true,
  });

  /// Сохранить задачу (создать или обновить)
  Future<Either<Failure, String>> saveTask(String firmId, TaskEntity task);

  /// Удалить задачу
  Future<Either<Failure, void>> deleteTask(String firmId, String taskId);
}
