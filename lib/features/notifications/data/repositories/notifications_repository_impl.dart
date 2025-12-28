import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/core/logging/notifications_logger.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/notifications/data/data_source/notifications_remote_data_source.dart';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:balansoved_mobile/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource authLocalDataSource;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required int page,
    bool getArchived = false,
  }) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) {
        debugPrint('❌ [NOTIFICATIONS_REPO] Токен доступа не найден');
        return const Left(
          CacheFailure(
            message: 'Токен доступа не найден',
            details: 'Пользователь не авторизован',
          ),
        );
      }

      sl<Talker>().logCustom(
        NotificationsLog(
          '📤 [NOTIFICATIONS_REPO] Запрос уведомлений: страница $page, архивные: $getArchived',
        ),
      );

      final notifications = await remoteDataSource.getNotifications(
        page: page,
        getArchived: getArchived,
        token: token,
      );
      final entities = notifications.map((model) => model.toEntity()).toList();

      sl<Talker>().logCustom(
        NotificationsLog(
          '📥 [NOTIFICATIONS_REPO] Получено ${entities.length} уведомлений',
        ),
      );
      return Right(entities);
    } on ServerException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка сервера при получении уведомлений:\n$e',
      );
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Сетевая ошибка при получении уведомлений:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка кэша при получении уведомлений:\n$e',
      );
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Неожиданная ошибка при получении уведомлений: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      return Left(
        UnexpectedFailure(
          message: 'Неожиданная ошибка при получении уведомлений',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> getNotificationById(
    String noticeId,
  ) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) {
        debugPrint('❌ [NOTIFICATIONS_REPO] Токен доступа не найден');
        return const Left(
          CacheFailure(
            message: 'Токен доступа не найден',
            details: 'Пользователь не авторизован',
          ),
        );
      }

      sl<Talker>().logCustom(
        NotificationsLog(
          '📤 [NOTIFICATIONS_REPO] Запрос уведомления по ID: $noticeId',
        ),
      );

      final notification = await remoteDataSource.getNotificationById(
        noticeId,
        token,
      );
      final entity = notification.toEntity();

      sl<Talker>().logCustom(
        NotificationsLog(
          '📥 [NOTIFICATIONS_REPO] Получено уведомление с ID: $noticeId',
        ),
      );
      return Right(entity);
    } on ServerException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка сервера при получении уведомления:\n$e',
      );
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Сетевая ошибка при получении уведомления:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка кэша при получении уведомления:\n$e',
      );
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Неожиданная ошибка при получении уведомления: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      return Left(
        UnexpectedFailure(
          message: 'Неожиданная ошибка при получении уведомления',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> archiveNotification(String noticeId) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) {
        debugPrint('❌ [NOTIFICATIONS_REPO] Токен доступа не найден');
        return const Left(
          CacheFailure(
            message: 'Токен доступа не найден',
            details: 'Пользователь не авторизован',
          ),
        );
      }

      sl<Talker>().logCustom(
        NotificationsLog(
          '📤 [NOTIFICATIONS_REPO] Архивирование уведомления: $noticeId',
        ),
      );

      await remoteDataSource.archiveNotification(noticeId, token);
      sl<Talker>().logCustom(
        NotificationsLog(
          '📥 [NOTIFICATIONS_REPO] Уведомление архивировано: $noticeId',
        ),
      );
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка сервера при архивировании уведомления:\n$e',
      );
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Сетевая ошибка при архивировании уведомления:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка кэша при архивировании уведомления:\n$e',
      );
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Неожиданная ошибка при архивировании уведомления: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      return Left(
        UnexpectedFailure(
          message: 'Неожиданная ошибка при архивировании уведомления',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAsDelivered(
    List<String> noticeIds,
  ) async {
    try {
      final token = await authLocalDataSource.getAccessToken();
      if (token == null) {
        debugPrint('❌ [NOTIFICATIONS_REPO] Токен доступа не найден');
        return const Left(
          CacheFailure(
            message: 'Токен доступа не найден',
            details: 'Пользователь не авторизован',
          ),
        );
      }

      sl<Talker>().logCustom(
        NotificationsLog(
          '📤 [NOTIFICATIONS_REPO] Отметить как доставленные: ${noticeIds.join(', ')}',
        ),
      );

      await remoteDataSource.markAsDelivered(noticeIds, token);
      sl<Talker>().logCustom(
        NotificationsLog(
          '📥 [NOTIFICATIONS_REPO] Уведомления отмечены как доставленные: ${noticeIds.length}',
        ),
      );
      return const Right(null);
    } on ServerException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка сервера при отметке уведомлений как доставленных:\n$e',
      );
      return Left(ServerFailure(message: e.message, details: e.toString()));
    } on NetworkException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Сетевая ошибка при отметке уведомлений как доставленных:\n$e',
      );
      return Left(NetworkFailure(message: e.message, details: e.toString()));
    } on CacheException catch (e) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Ошибка кэша при отметке уведомлений как доставленных:\n$e',
      );
      return Left(CacheFailure(message: e.message, details: e.toString()));
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [NOTIFICATIONS_REPO] Неожиданная ошибка при отметке уведомлений как доставленных: $e',
      );
      debugPrint('Stack trace: $stackTrace');
      return Left(
        UnexpectedFailure(
          message:
              'Неожиданная ошибка при отметке уведомлений как доставленных',
          details: e.toString(),
        ),
      );
    }
  }
}
