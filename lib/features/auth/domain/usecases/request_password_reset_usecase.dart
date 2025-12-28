import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final IAuthRepository repository;
  RequestPasswordResetUseCase(this.repository);

  Future<Either<Failure, Unit>> call(RequestPasswordResetParams params) {
    return repository.requestPasswordReset(email: params.email);
  }
}

class RequestPasswordResetParams extends Equatable {
  final String email;
  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}


