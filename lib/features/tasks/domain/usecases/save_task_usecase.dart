import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/repositories/tasks_repository.dart';

class SaveTaskUseCase {
  final TasksRepository repository;

  SaveTaskUseCase(this.repository);

  Future<Either<Failure, String>> call(String firmId, TaskEntity task) async {
    return await repository.saveTask(firmId, task);
  }
}
