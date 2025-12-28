part of 'firms_cubit.dart';

class FirmsState extends Equatable {
  final List<FirmEntity> firms;
  final FirmEntity? selectedFirm;
  final bool isLoading;
  final String? error;

  const FirmsState({
    required this.firms,
    required this.selectedFirm,
    required this.isLoading,
    this.error,
  });

  const FirmsState.initial()
      : this(firms: const [], selectedFirm: null, isLoading: true);

  FirmsState copyWith({
    List<FirmEntity>? firms,
    FirmEntity? selectedFirm,
    bool? isLoading,
    String? error,
  }) {
    return FirmsState(
      firms: firms ?? this.firms,
      selectedFirm: selectedFirm ?? this.selectedFirm,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [firms, selectedFirm, isLoading, error];
}
