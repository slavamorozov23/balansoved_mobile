part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final int? statusCode;
  const AuthError(this.message, {this.statusCode});
  @override
  List<Object?> get props => [message, statusCode];
}

class AuthAwaitingEmailConfirmation extends AuthState {
  final String email;
  const AuthAwaitingEmailConfirmation(this.email);
  @override
  List<Object?> get props => [email];
}
