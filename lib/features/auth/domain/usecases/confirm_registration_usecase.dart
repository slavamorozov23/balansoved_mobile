import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class ConfirmRegistrationUseCase {
  final IAuthRepository repository;
  ConfirmRegistrationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ConfirmRegistrationParams params) {
    return repository.confirmRegistration(
      email: params.email,
      code: params.code,
    );
  }
}

class ConfirmRegistrationParams extends Equatable {
  final String email;
  final String code;
  const ConfirmRegistrationParams({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}


