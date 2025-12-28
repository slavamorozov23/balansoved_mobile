import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      email: params.email,
      newPassword: params.newPassword,
      currentPasswordHash: params.currentPasswordHash,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String email;
  final String newPassword;
  final String currentPasswordHash;
  const ResetPasswordParams({
    required this.email,
    required this.newPassword,
    required this.currentPasswordHash,
  });

  @override
  List<Object?> get props => [email, newPassword, currentPasswordHash];
}


