part of 'clients_cubit.dart';

class ClientsState extends Equatable {
  final List<ClientEntity> clients;
  final bool isLoading;
  final bool noAccess;
  final String? error;

  const ClientsState({
    required this.clients,
    required this.isLoading,
    required this.noAccess,
    this.error,
  });

  const ClientsState.initial()
      : this(clients: const [], isLoading: false, noAccess: false);

  ClientsState copyWith({
    List<ClientEntity>? clients,
    bool? isLoading,
    bool? noAccess,
    String? error,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      noAccess: noAccess ?? this.noAccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [clients, isLoading, noAccess, error];
}
