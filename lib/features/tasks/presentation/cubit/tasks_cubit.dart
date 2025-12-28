import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/get_task_usecase.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/save_task_usecase.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final GetTasksUseCase _getTasksUseCase;
  final GetTaskUseCase _getTaskUseCase;
  final SaveTaskUseCase _saveTaskUseCase;
  TaskRequestParams? _currentParams;
  int? _urgentSearchYear;
  int? _urgentSearchMonth;

  TasksCubit({
    required GetTasksUseCase getTasksUseCase,
    required GetTaskUseCase getTaskUseCase,
    required SaveTaskUseCase saveTaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _getTaskUseCase = getTaskUseCase,
        _saveTaskUseCase = saveTaskUseCase,
        super(TasksInitial());

  Future<void> fetchTasks(String firmId, TaskRequestParams params) async {
    final effectiveParams = params.viewType == TaskViewType.timeline
        ? () {
            final direction = params.direction ?? 'initial';
            return params.copyWith(
              direction: direction,
              cursorAt: direction == 'initial' ? null : params.cursorAt,
            );
          }()
        : params;

    _currentParams = effectiveParams;
    emit(TasksLoading());

    if (effectiveParams.viewType == TaskViewType.dated) {
      _urgentSearchYear = effectiveParams.year;
      _urgentSearchMonth = effectiveParams.month;
    }

    final result = await _getTasksUseCase(firmId, effectiveParams);
    result.fold(
      (failure) {
        if (failure is AccessDeniedFailure) {
          emit(TasksNoAccess(failure.message));
        } else {
          emit(TasksError(failure.message));
        }
      },
      (tasksResult) {
        bool canLoadMore = false;
        bool canLoadOlder = false;
        bool canLoadNewer = false;
        String? oldestCursor;
        String? newestCursor;

        if (effectiveParams.viewType == TaskViewType.timeless ||
            effectiveParams.viewType == TaskViewType.all) {
          final meta = tasksResult.paginationMeta;
          canLoadMore = meta?.hasNextPage ?? tasksResult.tasks.length == 100;
        } else if (effectiveParams.viewType == TaskViewType.dated &&
            !effectiveParams.filterByMonth) {
          final currentYear = DateTime.now().year;
          final taskYear = effectiveParams.year ?? currentYear;
          final taskMonth = effectiveParams.month ?? DateTime.now().month;
          canLoadMore = taskYear == currentYear && taskMonth > 1;
        } else if (effectiveParams.viewType == TaskViewType.timeline) {
          if (tasksResult.tasks.isNotEmpty) {
            final sorted = List<TaskEntity>.from(tasksResult.tasks)
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            oldestCursor = sorted.first.createdAt.toUtc().toIso8601String();
            newestCursor = sorted.last.createdAt.toUtc().toIso8601String();
          }
          canLoadOlder = tasksResult.tasks.isNotEmpty;
          canLoadNewer = tasksResult.tasks.isNotEmpty;
        }

        emit(
          TasksLoaded(
            result: tasksResult,
            params: effectiveParams,
            canLoadMore: canLoadMore,
            canLoadOlder: canLoadOlder,
            canLoadNewer: canLoadNewer,
            oldestCursor: oldestCursor,
            newestCursor: newestCursor,
          ),
        );
      },
    );
  }

  /// Загрузить ещё задач для бессрочных и общей таблицы (page-based).
  Future<void> loadMoreTasks(String firmId) async {
    final currentState = state;
    if (currentState is! TasksLoaded) return;

    final viewType = currentState.params.viewType;
    if (viewType != TaskViewType.timeless && viewType != TaskViewType.all) {
      return;
    }
    if (!currentState.canLoadMore) return;

    emit(
      TasksLoadingMore(
        result: currentState.result,
        params: currentState.params,
        loadingMore: true,
        canLoadMore: currentState.canLoadMore,
        canLoadOlder: currentState.canLoadOlder,
        canLoadNewer: currentState.canLoadNewer,
        oldestCursor: currentState.oldestCursor,
        newestCursor: currentState.newestCursor,
      ),
    );

    final currentPage = currentState.paginationMeta?.currentPage ??
        currentState.params.page ??
        0;
    final nextParams = currentState.params.copyWith(page: currentPage + 1);

    final result = await _getTasksUseCase(firmId, nextParams);
    result.fold(
      (_) {
        emit(
          TasksLoaded(
            result: currentState.result,
            params: currentState.params,
            canLoadMore: false,
            canLoadOlder: currentState.canLoadOlder,
            canLoadNewer: currentState.canLoadNewer,
            oldestCursor: currentState.oldestCursor,
            newestCursor: currentState.newestCursor,
          ),
        );
      },
      (newTasksResult) {
        final allTasks = [
          ...currentState.result.tasks,
          ...newTasksResult.tasks,
        ];
        final combinedResult = TasksResult(
          tasks: allTasks,
          paginationMeta: newTasksResult.paginationMeta,
        );
        final meta = newTasksResult.paginationMeta;
        final canLoadMore = meta?.hasNextPage ?? newTasksResult.tasks.length == 100;
        emit(
          TasksLoaded(
            result: combinedResult,
            params: currentState.params,
            canLoadMore: canLoadMore,
            canLoadOlder: currentState.canLoadOlder,
            canLoadNewer: currentState.canLoadNewer,
            oldestCursor: currentState.oldestCursor,
            newestCursor: currentState.newestCursor,
          ),
        );
      },
    );
  }

  /// Загрузить ещё срочных задач при выключенном фильтре по месяцу.
  Future<void> loadMoreUrgentTasks(String firmId) async {
    final currentState = state;
    if (currentState is! TasksLoaded) return;

    if (currentState.params.viewType != TaskViewType.dated ||
        currentState.params.filterByMonth) {
      return;
    }

    emit(
      TasksLoadingMore(
        result: currentState.result,
        params: currentState.params,
        loadingMore: true,
        canLoadMore: currentState.canLoadMore,
        canLoadOlder: currentState.canLoadOlder,
        canLoadNewer: currentState.canLoadNewer,
        oldestCursor: currentState.oldestCursor,
        newestCursor: currentState.newestCursor,
      ),
    );

    var searchYear = _urgentSearchYear ?? DateTime.now().year;
    var searchMonth = _urgentSearchMonth ?? DateTime.now().month;

    List<TaskEntity>? foundTasks;
    bool errorOccurred = false;
    final currentYear = DateTime.now().year;

    for (int i = 0; i < 24 && foundTasks == null && !errorOccurred; i++) {
      searchMonth--;
      if (searchMonth == 0) {
        searchMonth = 12;
        searchYear--;
      }

      if (searchYear < currentYear || searchYear < 2020) {
        break;
      }

      final searchParams = currentState.params.copyWith(
        month: searchMonth,
        year: searchYear,
      );

      final result = await _getTasksUseCase(firmId, searchParams);
      result.fold(
        (_) {
          errorOccurred = true;
        },
        (tasksResult) {
          if (tasksResult.tasks.isNotEmpty) {
            foundTasks = tasksResult.tasks;
          }
        },
      );
    }

    if (errorOccurred) {
      emit(
        TasksLoaded(
          result: currentState.result,
          params: currentState.params,
          canLoadMore: false,
          canLoadOlder: currentState.canLoadOlder,
          canLoadNewer: currentState.canLoadNewer,
          oldestCursor: currentState.oldestCursor,
          newestCursor: currentState.newestCursor,
        ),
      );
      return;
    }

    if (foundTasks != null) {
      _urgentSearchYear = searchYear;
      _urgentSearchMonth = searchMonth;

      final allTasks = [...currentState.result.tasks, ...foundTasks!];
      final combinedResult = TasksResult(
        tasks: allTasks,
        paginationMeta: currentState.result.paginationMeta,
      );
      final canLoadMore = searchYear == currentYear && searchMonth > 1;

      emit(
        TasksLoaded(
          result: combinedResult,
          params: currentState.params,
          canLoadMore: canLoadMore,
          canLoadOlder: currentState.canLoadOlder,
          canLoadNewer: currentState.canLoadNewer,
          oldestCursor: currentState.oldestCursor,
          newestCursor: currentState.newestCursor,
        ),
      );
    } else {
      emit(
        TasksLoaded(
          result: currentState.result,
          params: currentState.params,
          canLoadMore: false,
          canLoadOlder: currentState.canLoadOlder,
          canLoadNewer: currentState.canLoadNewer,
          oldestCursor: currentState.oldestCursor,
          newestCursor: currentState.newestCursor,
        ),
      );
    }
  }

  /// Загрузить более старые задачи (timeline).
  Future<void> loadOlderTimelineTasks(String firmId) async {
    final currentState = state;
    if (currentState is! TasksLoaded) return;
    if (currentState.params.viewType != TaskViewType.timeline) return;
    if (!currentState.canLoadOlder) return;

    emit(
      TasksLoadingMore(
        result: currentState.result,
        params: currentState.params,
        loadingOlder: true,
        canLoadMore: currentState.canLoadMore,
        canLoadOlder: currentState.canLoadOlder,
        canLoadNewer: currentState.canLoadNewer,
        oldestCursor: currentState.oldestCursor,
        newestCursor: currentState.newestCursor,
      ),
    );

    final params = currentState.params.copyWith(
      direction: 'older',
      cursorAt: currentState.oldestCursor,
      force: true,
    );

    final result = await _getTasksUseCase(firmId, params);
    result.fold(
      (_) {
        emit(
          TasksLoaded(
            result: currentState.result,
            params: currentState.params,
            canLoadMore: currentState.canLoadMore,
            canLoadOlder: false,
            canLoadNewer: currentState.canLoadNewer,
            oldestCursor: currentState.oldestCursor,
            newestCursor: currentState.newestCursor,
          ),
        );
      },
      (newResult) {
        if (newResult.tasks.isEmpty) {
          emit(
            TasksLoaded(
              result: currentState.result,
              params: currentState.params,
              canLoadMore: currentState.canLoadMore,
              canLoadOlder: false,
              canLoadNewer: currentState.canLoadNewer,
              oldestCursor: currentState.oldestCursor,
              newestCursor: currentState.newestCursor,
            ),
          );
          return;
        }

        final merged = _mergeTimelineTasks(
          currentState.result.tasks,
          newResult.tasks,
        );
        final oldestCursor = merged.first.createdAt.toUtc().toIso8601String();
        final newestCursor = merged.last.createdAt.toUtc().toIso8601String();

        emit(
          TasksLoaded(
            result: TasksResult(
              tasks: merged,
              paginationMeta: currentState.result.paginationMeta,
            ),
            params: currentState.params,
            canLoadMore: currentState.canLoadMore,
            canLoadOlder: newResult.tasks.isNotEmpty,
            canLoadNewer: currentState.canLoadNewer,
            oldestCursor: oldestCursor,
            newestCursor: newestCursor,
          ),
        );
      },
    );
  }

  /// Загрузить более новые задачи (timeline).
  Future<void> loadNewerTimelineTasks(String firmId) async {
    final currentState = state;
    if (currentState is! TasksLoaded) return;
    if (currentState.params.viewType != TaskViewType.timeline) return;
    if (!currentState.canLoadNewer) return;

    emit(
      TasksLoadingMore(
        result: currentState.result,
        params: currentState.params,
        loadingNewer: true,
        canLoadMore: currentState.canLoadMore,
        canLoadOlder: currentState.canLoadOlder,
        canLoadNewer: currentState.canLoadNewer,
        oldestCursor: currentState.oldestCursor,
        newestCursor: currentState.newestCursor,
      ),
    );

    final params = currentState.params.copyWith(
      direction: 'newer',
      cursorAt: currentState.newestCursor,
      force: true,
    );

    final result = await _getTasksUseCase(firmId, params);
    result.fold(
      (_) {
        emit(
          TasksLoaded(
            result: currentState.result,
            params: currentState.params,
            canLoadMore: currentState.canLoadMore,
            canLoadOlder: currentState.canLoadOlder,
            canLoadNewer: false,
            oldestCursor: currentState.oldestCursor,
            newestCursor: currentState.newestCursor,
          ),
        );
      },
      (newResult) {
        if (newResult.tasks.isEmpty) {
          emit(
            TasksLoaded(
              result: currentState.result,
              params: currentState.params,
              canLoadMore: currentState.canLoadMore,
              canLoadOlder: currentState.canLoadOlder,
              canLoadNewer: false,
              oldestCursor: currentState.oldestCursor,
              newestCursor: currentState.newestCursor,
            ),
          );
          return;
        }

        final merged = _mergeTimelineTasks(
          currentState.result.tasks,
          newResult.tasks,
        );
        final oldestCursor = merged.first.createdAt.toUtc().toIso8601String();
        final newestCursor = merged.last.createdAt.toUtc().toIso8601String();

        emit(
          TasksLoaded(
            result: TasksResult(
              tasks: merged,
              paginationMeta: currentState.result.paginationMeta,
            ),
            params: currentState.params,
            canLoadMore: currentState.canLoadMore,
            canLoadOlder: currentState.canLoadOlder,
            canLoadNewer: newResult.tasks.isNotEmpty,
            oldestCursor: oldestCursor,
            newestCursor: newestCursor,
          ),
        );
      },
    );
  }

  Future<bool> saveTask(String firmId, TaskEntity task) async {
    final result = await _saveTaskUseCase(firmId, task);
    return result.fold(
      (_) => false,
      (taskId) {
        final updatedTask = task.copyWith(id: taskId);
        _replaceTaskInState(updatedTask);
        return true;
      },
    );
  }

  Future<bool> updateTaskStatus(
    String firmId,
    String taskId,
    String newStatus,
  ) async {
    final onlyMy = _currentParams?.onlyMy ?? true;
    final getResult = await _getTaskUseCase(
      firmId,
      taskId,
      onlyMy: onlyMy,
    );

    return await getResult.fold(
      (_) async => false,
      (task) async {
        final updatedTask = task.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        final saveResult = await _saveTaskUseCase(firmId, updatedTask);
        return saveResult.fold(
          (_) => false,
          (taskId) {
            _replaceTaskInState(updatedTask.copyWith(id: taskId));
            return true;
          },
        );
      },
    );
  }

  /// Подтянуть самую свежую версию задачи с сервера (без смены общего state на loading).
  /// Возвращает задачу при успехе, иначе `null`.
  Future<TaskEntity?> fetchFreshTask(String firmId, String taskId) async {
    final onlyMy = _currentParams?.onlyMy ?? true;
    final getResult = await _getTaskUseCase(
      firmId,
      taskId,
      onlyMy: onlyMy,
    );

    return getResult.fold(
      (_) => null,
      (task) {
        _replaceTaskInState(task);
        return task;
      },
    );
  }

  List<TaskEntity> _mergeTimelineTasks(
    List<TaskEntity> base,
    List<TaskEntity> incoming,
  ) {
    final byId = <String, TaskEntity>{};
    for (final task in base) {
      byId[task.id] = task;
    }
    for (final task in incoming) {
      byId[task.id] = task;
    }

    final merged = byId.values.toList();
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  void _replaceTaskInState(TaskEntity updatedTask) {
    final currentState = state;
    TasksResult? currentResult;
    late TaskRequestParams params;
    bool canLoadMore = false;
    bool canLoadOlder = false;
    bool canLoadNewer = false;
    String? oldestCursor;
    String? newestCursor;
    bool loadingMore = false;
    bool loadingOlder = false;
    bool loadingNewer = false;

    if (currentState is TasksLoaded) {
      currentResult = currentState.result;
      params = currentState.params;
      canLoadMore = currentState.canLoadMore;
      canLoadOlder = currentState.canLoadOlder;
      canLoadNewer = currentState.canLoadNewer;
      oldestCursor = currentState.oldestCursor;
      newestCursor = currentState.newestCursor;
    } else if (currentState is TasksLoadingMore) {
      currentResult = currentState.result;
      params = currentState.params;
      canLoadMore = currentState.canLoadMore;
      canLoadOlder = currentState.canLoadOlder;
      canLoadNewer = currentState.canLoadNewer;
      oldestCursor = currentState.oldestCursor;
      newestCursor = currentState.newestCursor;
      loadingMore = currentState.loadingMore;
      loadingOlder = currentState.loadingOlder;
      loadingNewer = currentState.loadingNewer;
    } else {
      return;
    }

    final index = currentResult.tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) return;

    final updatedTasks = List<TaskEntity>.from(currentResult.tasks);
    updatedTasks[index] = updatedTask;
    final updatedResult = TasksResult(
      tasks: updatedTasks,
      paginationMeta: currentResult.paginationMeta,
    );

    if (currentState is TasksLoadingMore) {
      emit(
        TasksLoadingMore(
          result: updatedResult,
          params: params,
          loadingMore: loadingMore,
          loadingOlder: loadingOlder,
          loadingNewer: loadingNewer,
          canLoadMore: canLoadMore,
          canLoadOlder: canLoadOlder,
          canLoadNewer: canLoadNewer,
          oldestCursor: oldestCursor,
          newestCursor: newestCursor,
        ),
      );
    } else {
      emit(
        TasksLoaded(
          result: updatedResult,
          params: params,
          canLoadMore: canLoadMore,
          canLoadOlder: canLoadOlder,
          canLoadNewer: canLoadNewer,
          oldestCursor: oldestCursor,
          newestCursor: newestCursor,
        ),
      );
    }
  }
}
