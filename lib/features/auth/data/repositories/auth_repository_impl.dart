import 'package:balansoved_mobile/core/logging/auth_logger.dart';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:balansoved_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remote;
  final IAuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, Unit>> registerRequest({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Начинаем регистрацию пользователя: $email'),
      );
      await remote.registerRequest(
        email: email,
        password: password,
        userName: userName,
      );
      sl<Talker>().logCustom(AuthLog('✅ [REPO] Регистрация завершена успешно'));
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка сервера при регистрации:\n$e');
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error('❌ [REPO] Сетевая ошибка при регистрации:\n$e');
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [REPO] Неожиданная ошибка при регистрации: $e');
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Начинаем авторизацию пользователя: $email'),
      );
      final token = await remote.login(email: email, password: password);
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Токен получен, сохраняем локально'),
      );
      await local.cacheAccessToken(token);
      sl<Talker>().logCustom(AuthLog('✅ [REPO] Авторизация завершена успешно'));
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка сервера при авторизации:\n$e');
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error('❌ [REPO] Сетевая ошибка при авторизации:\n$e');
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка кэша при авторизации:\n$e');
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [REPO] Неожиданная ошибка при авторизации: $e');
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshToken({
    required String email,
    required String password,
  }) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Начинаем обновление токена для: $email'),
      );
      final token = await remote.refreshToken(email: email, password: password);
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Новый токен получен, сохраняем локально'),
      );
      await local.cacheAccessToken(token);
      sl<Talker>().logCustom(
        AuthLog('✅ [REPO] Обновление токена завершено успешно'),
      );
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка сервера при обновлении токена:\n$e');
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error('❌ [REPO] Сетевая ошибка при обновлении токена:\n$e');
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка кэша при обновлении токена:\n$e');
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error(
        '❌ [REPO] Неожиданная ошибка при обновлении токена: $e',
      );
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptInvitation(String invitationKey) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Активируем приглашение: $invitationKey'),
      );
      await remote.acceptInvitation(invitationKey);
      sl<Talker>().logCustom(AuthLog('✅ [REPO] Приглашение активировано'));
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Ошибка сервера при активации приглашения:\n$e',
      );
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Сетевая ошибка при активации приглашения:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error(
        '❌ [REPO] Неожиданная ошибка при активации приглашения: $e',
      );
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      sl<Talker>().logCustom(AuthLog('🔵 [REPO] Начинаем выход из системы'));
      await local.clearAccessToken();
      sl<Talker>().logCustom(
        AuthLog('✅ [REPO] Выход из системы завершен успешно'),
      );
      return const Right(unit);
    } on CacheException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка кэша при выходе:\n$e');
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [REPO] Неожиданная ошибка при выходе: $e');
      return Left(
        CacheFailure(message: e.toString(), details: stackTrace.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, Option<UserEntity>>> checkAuthStatus() async {
    try {
      sl<Talker>().logCustom(AuthLog('🔵 [REPO] Проверяем статус авторизации'));
      final token = await local.getAccessToken();
      if (token == null || token.isEmpty) {
        sl<Talker>().logCustom(
          AuthLog('ℹ️ [REPO] Токен отсутствует, пользователь не авторизован'),
        );
        return const Right(None());
      }
      sl<Talker>().logCustom(
        AuthLog('✅ [REPO] Токен найден, пользователь авторизован'),
      );
      // Пытаемся извлечь данные пользователя из JWT (payload)
      final user = _extractUserFromToken(token);
      sl<Talker>().logCustom(
        AuthLog(
          '👤 [REPO] Пользователь из JWT: id=${user.id}, email=${user.email}, userName=${user.userName}',
        ),
      );
      return Right(Some(user));
    } on CacheException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка кэша при проверке статуса:\n$e');
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error(
        '❌ [REPO] Неожиданная ошибка при проверке статуса: $e',
      );
      return Left(
        CacheFailure(message: e.toString(), details: stackTrace.toString()),
      );
    }
  }

  /// Безопасно декодирует JWT и извлекает поля пользователя
  UserEntity _extractUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        sl<Talker>().logCustom(AuthErrorLog('JWT malformed: parts < 2'));
        return const UserEntity(id: '', email: null, userName: null);
      }
      final payloadJson = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final dynamic decoded = jsonDecode(payloadJson);
      if (decoded is! Map) {
        sl<Talker>().logCustom(
          AuthErrorLog('JWT payload is not a Map: ${decoded.runtimeType}'),
        );
        return const UserEntity(id: '', email: null, userName: null);
      }
      // Строгое соответствие серверным полям (см. Obsidian: jwt-database, gateway auth-api)
      final map = Map<String, dynamic>.from(decoded);
      final idRaw = map['user_id'];
      final emailRaw = map['email'];
      final userNameRaw = map['user_name'];
      final id = idRaw is String ? idRaw : idRaw?.toString() ?? '';
      final email = emailRaw is String ? emailRaw : null;
      final userName = userNameRaw is String ? userNameRaw : null;
      return UserEntity(id: id, email: email, userName: userName);
    } catch (e) {
      sl<Talker>().logCustom(AuthErrorLog('JWT decode failed: $e'));
      return const UserEntity(id: '', email: null, userName: null);
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmRegistration({
    required String email,
    required String code,
  }) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Подтверждаем регистрацию для: $email'),
      );
      final token = await remote.confirmRegistration(email: email, code: code);
      await local.cacheAccessToken(token);
      sl<Talker>().logCustom(
        AuthLog('✅ [REPO] Регистрация подтверждена, токен сохранён'),
      );
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Ошибка сервера при подтверждении регистрации:\n$e',
      );
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Сетевая ошибка при подтверждении регистрации:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error(
        '❌ [REPO] Неожиданная ошибка при подтверждении регистрации: $e',
      );
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }

  // --- Password reset methods ---
  @override
  Future<Either<Failure, Unit>> requestPasswordReset({
    required String email,
  }) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Запрос сброса пароля для: $email'),
      );
      await remote.requestPasswordReset(email: email);
      sl<Talker>().logCustom(
        AuthLog('✅ [REPO] Инструкции по сбросу пароля отправлены'),
      );
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Ошибка сервера при запросе сброса пароля:\n$e',
      );
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Сетевая ошибка при запросе сброса пароля:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error(
        '❌ [REPO] Неожиданная ошибка requestPasswordReset: $e',
      );
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String newPassword,
    required String currentPasswordHash,
  }) async {
    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [REPO] Подтверждение сброса пароля для: $email'),
      );
      final token = await remote.resetPassword(
        email: email,
        newPassword: newPassword,
        currentPasswordHash: currentPasswordHash,
      );
      await local.cacheAccessToken(token);
      sl<Talker>().logCustom(
        AuthLog('✅ [REPO] Пароль сброшен, токен сохранён'),
      );
      return const Right(unit);
    } on ServerException catch (e) {
      sl<Talker>().error('❌ [REPO] Ошибка сервера при сбросе пароля:\n$e');
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      sl<Talker>().error('❌ [REPO] Сетевая ошибка при сбросе пароля:\n$e');
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      sl<Talker>().error(
        '❌ [REPO] Ошибка кэша при сохранении токена после сброса пароля:\n$e',
      );
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [REPO] Неожиданная ошибка resetPassword: $e');
      return Left(
        UnexpectedFailure(
          message: e.toString(),
          details: stackTrace.toString(),
        ),
      );
    }
  }
}


