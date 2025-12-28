import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final GetTasksUseCase _getTasksUseCase;

  TasksCubit({required GetTasksUseCase getTasksUseCase})
      : _getTasksUseCase = getTasksUseCase,
        super(TasksInitial());

  Future<void> fetchTasks(String firmId, TaskRequestParams params) async {
    emit(TasksLoading());

    final result = await _getTasksUseCase(firmId, params);
    result.fold(
      (failure) {
        if (failure is AccessDeniedFailure) {
          emit(TasksNoAccess(failure.message));
        } else {
          emit(TasksError(failure.message));
        }
      },
      (tasksResult) {
        emit(TasksLoaded(tasks: tasksResult.tasks, params: params));
      },
    );
  }
}
