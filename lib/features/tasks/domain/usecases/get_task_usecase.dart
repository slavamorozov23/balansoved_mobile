import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/repositories/tasks_repository.dart';

class GetTaskUseCase {
  final TasksRepository repository;

  GetTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(
    String firmId,
    String taskId, {
    bool onlyMy = true,
  }) async {
    return await repository.getTask(firmId, taskId, onlyMy: onlyMy);
  }
}
