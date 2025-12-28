part of 'tasks_cubit.dart';

abstract class TasksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskEntity> tasks;
  final TaskRequestParams params;

  TasksLoaded({required this.tasks, required this.params});

  @override
  List<Object?> get props => [tasks, params];
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
