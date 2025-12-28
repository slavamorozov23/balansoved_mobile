import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:balansoved_mobile/features/firms/domain/entities/firm_entity.dart';
import 'package:balansoved_mobile/features/firms/domain/usecases/get_firms_usecase.dart';

part 'firms_state.dart';

class FirmsCubit extends Cubit<FirmsState> {
  static const String _selectedFirmIdKey = 'selected_firm_id';

  final GetFirmsUseCase _getFirmsUseCase;
  final SharedPreferences _prefs;

  FirmsCubit({
    required GetFirmsUseCase getFirmsUseCase,
    required SharedPreferences prefs,
  }) : _getFirmsUseCase = getFirmsUseCase,
       _prefs = prefs,
       super(const FirmsState.initial());

  Future<void> loadFirms() async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _getFirmsUseCase();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            firms: const [],
            selectedFirm: null,
            error: failure.message,
          ),
        );
      },
      (firms) {
        if (firms.isEmpty) {
          emit(
            state.copyWith(
              isLoading: false,
              firms: const [],
              selectedFirm: null,
            ),
          );
          return;
        }

        final savedId = _prefs.getString(_selectedFirmIdKey);
        final selected = savedId != null
            ? firms.firstWhere(
                (f) => f.id == savedId,
                orElse: () => firms.first,
              )
            : firms.first;

        emit(
          state.copyWith(
            isLoading: false,
            firms: firms,
            selectedFirm: selected,
          ),
        );
      },
    );
  }

  Future<void> selectFirm(FirmEntity firm) async {
    if (state.selectedFirm?.id == firm.id) return;
    emit(state.copyWith(selectedFirm: firm));
    await _prefs.setString(_selectedFirmIdKey, firm.id);
  }
}
