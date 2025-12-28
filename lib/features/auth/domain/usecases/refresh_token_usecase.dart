import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final IAuthRepository repository;
  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, Unit>> call(RefreshTokenParams params) {
    return repository.refreshToken(
      email: params.email,
      password: params.password,
    );
  }
}

class RefreshTokenParams extends Equatable {
  final String email;
  final String password;
  const RefreshTokenParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}


