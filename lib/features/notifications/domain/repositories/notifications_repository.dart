import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required int page,
    bool getArchived = false,
  });

  Future<Either<Failure, NotificationEntity>> getNotificationById(
    String noticeId,
  );

  Future<Either<Failure, void>> archiveNotification(String noticeId);

  Future<Either<Failure, void>> markAsDelivered(List<String> noticeIds);
}
