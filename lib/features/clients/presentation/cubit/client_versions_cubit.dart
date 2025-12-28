import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/domain/usecases/get_client_versions_usecase.dart';

part 'client_versions_state.dart';

class ClientVersionsCubit extends Cubit<ClientVersionsState> {
  final GetClientVersionsUseCase _getClientVersionsUseCase;

  ClientVersionsCubit({
    required GetClientVersionsUseCase getClientVersionsUseCase,
  })  : _getClientVersionsUseCase = getClientVersionsUseCase,
        super(const ClientVersionsState.initial());

  Future<void> fetchVersions(String firmId, String clientName) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _getClientVersionsUseCase(firmId, clientName);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, error: failure.message));
      },
      (versions) {
        ClientEntity? selected;
        if (versions.isNotEmpty) {
          selected = versions.firstWhere(
            (v) => v.isActual,
            orElse: () => versions.first,
          );
        }
        emit(
          state.copyWith(
            isLoading: false,
            versions: versions,
            selectedVersion: selected,
            error: null,
          ),
        );
      },
    );
  }

  void selectVersion(ClientEntity version) {
    emit(state.copyWith(selectedVersion: version));
  }
}
