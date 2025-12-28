part of 'tasks_cubit.dart';

abstract class TasksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final TasksResult result;
  final TaskRequestParams params;
  final bool canLoadMore;
  final bool canLoadOlder;
  final bool canLoadNewer;
  final String? oldestCursor;
  final String? newestCursor;

  TasksLoaded({
    required this.result,
    required this.params,
    this.canLoadMore = false,
    this.canLoadOlder = false,
    this.canLoadNewer = false,
    this.oldestCursor,
    this.newestCursor,
  });

  List<TaskEntity> get tasks => result.tasks;
  TaskPaginationMeta? get paginationMeta => result.paginationMeta;

  @override
  List<Object?> get props => [
    result,
    params,
    canLoadMore,
    canLoadOlder,
    canLoadNewer,
    oldestCursor,
    newestCursor,
  ];
}

class TasksLoadingMore extends TasksState {
  final TasksResult result;
  final TaskRequestParams params;
  final bool loadingMore;
  final bool loadingOlder;
  final bool loadingNewer;
  final bool canLoadMore;
  final bool canLoadOlder;
  final bool canLoadNewer;
  final String? oldestCursor;
  final String? newestCursor;

  TasksLoadingMore({
    required this.result,
    required this.params,
    this.loadingMore = false,
    this.loadingOlder = false,
    this.loadingNewer = false,
    this.canLoadMore = false,
    this.canLoadOlder = false,
    this.canLoadNewer = false,
    this.oldestCursor,
    this.newestCursor,
  });

  List<TaskEntity> get tasks => result.tasks;
  TaskPaginationMeta? get paginationMeta => result.paginationMeta;

  @override
  List<Object?> get props => [
    result,
    params,
    loadingMore,
    loadingOlder,
    loadingNewer,
    canLoadMore,
    canLoadOlder,
    canLoadNewer,
    oldestCursor,
    newestCursor,
  ];
}

class TasksNoAccess extends TasksState {
  final String message;

  TasksNoAccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TasksError extends TasksState {
  final String message;

  TasksError(this.message);

  @override
  List<Object?> get props => [message];
}
