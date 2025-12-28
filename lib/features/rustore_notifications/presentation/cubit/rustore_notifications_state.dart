part of 'rustore_notifications_cubit.dart';

enum RustoreAuthStatus { unauthenticated, authenticating, authenticated, error }

class RustoreNotificationsState extends Equatable {
  final RustoreAuthStatus status;
  final List<String> logs;
  final String pushToken;
  final bool isTokenRegistered;
  final String? userId;
  final bool isLoading;

  const RustoreNotificationsState({
    required this.status,
    required this.logs,
    required this.pushToken,
    required this.isTokenRegistered,
    required this.userId,
    required this.isLoading,
  });

  const RustoreNotificationsState.initial()
    : status = RustoreAuthStatus.unauthenticated,
      logs = const [],
      pushToken = '',
      isTokenRegistered = false,
      userId = null,
      isLoading = false;

  RustoreNotificationsState copyWith({
    RustoreAuthStatus? status,
    List<String>? logs,
    String? pushToken,
    bool? isTokenRegistered,
    String? userId,
    bool? isLoading,
  }) {
    return RustoreNotificationsState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      pushToken: pushToken ?? this.pushToken,
      isTokenRegistered: isTokenRegistered ?? this.isTokenRegistered,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    status,
    logs,
    pushToken,
    isTokenRegistered,
    userId,
    isLoading,
  ];
}
