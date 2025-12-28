import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final IAuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.signOut();
  }
}


