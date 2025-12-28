part of 'client_versions_cubit.dart';

class ClientVersionsState extends Equatable {
  final List<ClientEntity> versions;
  final ClientEntity? selectedVersion;
  final bool isLoading;
  final String? error;

  const ClientVersionsState({
    required this.versions,
    required this.selectedVersion,
    required this.isLoading,
    this.error,
  });

  const ClientVersionsState.initial()
      : this(versions: const [], selectedVersion: null, isLoading: false);

  ClientVersionsState copyWith({
    List<ClientEntity>? versions,
    ClientEntity? selectedVersion,
    bool? isLoading,
    String? error,
  }) {
    return ClientVersionsState(
      versions: versions ?? this.versions,
      selectedVersion: selectedVersion ?? this.selectedVersion,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [versions, selectedVersion, isLoading, error];
}
