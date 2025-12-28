import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/rustore_notifications/data/data_source/rustore_notifications_remote_data_source.dart';
import 'package:balansoved_mobile/features/rustore_notifications/data/data_source/rustore_push_local_data_source.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class RustoreNotificationsRepositoryImpl
    implements IRustoreNotificationsRepository {
  final RustorePushLocalDataSource pushLocalDataSource;
  final RustoreNotificationsRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource authLocalDataSource;

  RustoreNotificationsRepositoryImpl({
    required this.pushLocalDataSource,
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, bool>> ensureNotificationPermission() async {
    try {
      final granted = await pushLocalDataSource.ensureNotificationPermission();
      return Right(granted);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка запроса разрешения на уведомления',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  void attachCallbacks({
    required ValueChanged<String> onNewToken,
    required ValueChanged<dynamic> onMessageReceived,
    required VoidCallback onDeletedMessages,
    required ValueChanged<dynamic> onError,
    required ValueChanged<dynamic> onMessageOpenedApp,
  }) {
    pushLocalDataSource.attachCallbacks(
      onNewToken: onNewToken,
      onMessageReceived: onMessageReceived,
      onDeletedMessages: onDeletedMessages,
      onError: onError,
      onMessageOpenedApp: onMessageOpenedApp,
    );
  }

  @override
  Future<Either<Failure, String>> getPushToken() async {
    try {
      final token = await pushLocalDataSource.getToken();
      if (token.isEmpty) {
        return Left(
          MessageFailure(message: 'RuStore SDK не вернул push-токен'),
        );
      }
      return Right(token);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка получения push-токена',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePushToken() async {
    try {
      await pushLocalDataSource.deleteToken();
      return const Right(unit);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка удаления push-токена',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> registerPushToken(String pushToken) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return Left(AccessDeniedFailure(message: 'Пользователь не авторизован'));
      }
      await remoteDataSource.registerPushToken(
        accessToken: accessToken,
        pushToken: pushToken,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка регистрации push-токена',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubscription(String pushToken) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return Left(AccessDeniedFailure(message: 'Пользователь не авторизован'));
      }
      await remoteDataSource.deleteSubscription(
        accessToken: accessToken,
        pushToken: pushToken,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка удаления подписки',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendTestNotification({
    required String title,
    required String body,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return Left(AccessDeniedFailure(message: 'Пользователь не авторизован'));
      }
      final userId = await _getUserIdFromToken(accessToken);
      if (userId == null || userId.isEmpty) {
        return Left(MessageFailure(message: 'Не удалось определить user_id'));
      }
      await remoteDataSource.sendTestNotification(
        accessToken: accessToken,
        userId: userId,
        title: title,
        body: body,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          details: e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка отправки уведомления',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> getUserId() async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        return Left(AccessDeniedFailure(message: 'Пользователь не авторизован'));
      }
      final userId = await _getUserIdFromToken(accessToken);
      if (userId == null || userId.isEmpty) {
        return Left(MessageFailure(message: 'Не удалось определить user_id'));
      }
      return Right(userId);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Ошибка чтения user_id',
          details: e.toString(),
        ),
      );
    }
  }

  Future<String?> _getAccessToken() async {
    return authLocalDataSource.getAccessToken();
  }

  Future<String?> _getUserIdFromToken(String token) async {
    try {
      final decoded = JwtDecoder.decode(token);
      final value = decoded['user_id'];
      if (value == null) return null;
      return value is String ? value : value.toString();
    } catch (_) {
      return null;
    }
  }
}

