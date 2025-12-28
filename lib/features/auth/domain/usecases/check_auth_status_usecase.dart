import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final IAuthRepository repository;
  CheckAuthStatusUseCase(this.repository);

  Future<Either<Failure, Option<UserEntity>>> call() {
    return repository.checkAuthStatus();
  }
}


