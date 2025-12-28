import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/_empty/domain/entities/empty_entity.dart';
import 'package:balansoved_mobile/features/_empty/domain/usecases/get_empty_usecase.dart';

class EmptyCubit extends Cubit<EmptyState> {
  final GetEmptyUsecase getEmptyUsecase;

  EmptyCubit({required this.getEmptyUsecase}) : super(const EmptyInitial());

  Future<void> load() async {
    emit(const EmptyLoading());
    final result = await getEmptyUsecase();
    result.fold(
      (failure) => emit(EmptyError(message: failure.message)),
      (entity) => emit(EmptyLoaded(entity: entity)),
    );
  }
}

sealed class EmptyState extends Equatable {
  const EmptyState();

  @override
  List<Object?> get props => [];
}

class EmptyInitial extends EmptyState {
  const EmptyInitial();
}

class EmptyLoading extends EmptyState {
  const EmptyLoading();
}

class EmptyLoaded extends EmptyState {
  final EmptyEntity entity;

  const EmptyLoaded({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class EmptyError extends EmptyState {
  final String message;

  const EmptyError({required this.message});

  @override
  List<Object?> get props => [message];
}

