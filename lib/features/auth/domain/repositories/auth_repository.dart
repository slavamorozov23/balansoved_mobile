import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, Unit>> registerRequest({
    required String email,
    required String password,
    required String userName,
  });
  Future<Either<Failure, Unit>> refreshToken({
    required String email,
    required String password,
  });

  /// Запрос отправки инструкции/кода для сброса пароля на указанный email.
  Future<Either<Failure, Unit>> requestPasswordReset({required String email});

  /// Подтвердить сброс пароля: передать код/хеш из письма и новый пароль.
  /// При успешном сбросе сервер возвращает JWT — реализация должна сохранить его локально.
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String newPassword,
    required String currentPasswordHash,
  });

  Future<Either<Failure, Unit>> acceptInvitation(String invitationKey);
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, Option<UserEntity>>> checkAuthStatus();
  Future<Either<Failure, Unit>> confirmRegistration({
    required String email,
    required String code,
  });
}


