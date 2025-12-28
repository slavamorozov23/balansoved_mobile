import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';

class AcceptInvitationUseCase {
  final IAuthRepository repository;
  AcceptInvitationUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String invitationKey) {
    return repository.acceptInvitation(invitationKey);
  }
}


