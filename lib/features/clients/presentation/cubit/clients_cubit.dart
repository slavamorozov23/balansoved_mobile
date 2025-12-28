import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/domain/usecases/get_clients_usecase.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final GetClientsUseCase _getClientsUseCase;

  ClientsCubit({required GetClientsUseCase getClientsUseCase})
      : _getClientsUseCase = getClientsUseCase,
        super(const ClientsState.initial());

  Future<void> fetchClients(String firmId, {bool onlyActual = true}) async {
    emit(state.copyWith(isLoading: true, error: null, noAccess: false));

    final result = await _getClientsUseCase(firmId, onlyActual: onlyActual);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            error: failure.message,
            noAccess: failure is AccessDeniedFailure,
          ),
        );
      },
      (clients) {
        emit(
          state.copyWith(
            isLoading: false,
            clients: clients,
            error: null,
            noAccess: false,
          ),
        );
      },
    );
  }
}
