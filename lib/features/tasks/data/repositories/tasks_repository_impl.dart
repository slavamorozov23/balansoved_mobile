import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/tasks/data/data_source/tasks_remote_data_source.dart';
import 'package:balansoved_mobile/features/tasks/data/models/task_model.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;

  TasksRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TasksResult>> getTasks(
    String firmId,
    TaskRequestParams params,
  ) async {
    try {
      final apiResult = await remoteDataSource.getTasks(firmId, params);
      final tasks = apiResult.tasks.map((task) => task.toEntity()).toList();

      final result = TasksResult(
        tasks: tasks,
        paginationMeta: apiResult.paginationMeta,
      );

      return Right(result);
    } on ServerException catch (e) {
      if (e.statusCode == 403) {
        return Left(
          AccessDeniedFailure(message: e.message, details: e.responseBody),
        );
      }
      return Left(ServerFailure(message: e.message, details: e.responseBody));
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTask(
    String firmId,
    String taskId, {
    bool onlyMy = true,
  }) async {
    try {
      final task =
          await remoteDataSource.getTask(firmId, taskId, onlyMy: onlyMy);
      return Right(task.toEntity());
    } on ServerException catch (e) {
      if (e.statusCode == 403) {
        return Left(
          AccessDeniedFailure(message: e.message, details: e.responseBody),
        );
      }
      return Left(ServerFailure(message: e.message, details: e.responseBody));
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> saveTask(
    String firmId,
    TaskEntity task,
  ) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final taskId = await remoteDataSource.saveTask(firmId, taskModel);
      return Right(taskId);
    } on ServerException catch (e) {
      if (e.statusCode == 403) {
        return Left(
          AccessDeniedFailure(message: e.message, details: e.responseBody),
        );
      }
      return Left(ServerFailure(message: e.message, details: e.responseBody));
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String firmId, String taskId) async {
    try {
      await remoteDataSource.deleteTask(firmId, taskId);
      return const Right(null);
    } on ServerException catch (e) {
      if (e.statusCode == 403) {
        return Left(
          AccessDeniedFailure(message: e.message, details: e.responseBody),
        );
      }
      return Left(ServerFailure(message: e.message, details: e.responseBody));
    } catch (e) {
      return Left(ServerFailure(message: 'Неизвестная ошибка: $e'));
    }
  }
}
