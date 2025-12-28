import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:balansoved_mobile/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    required int page,
    bool getArchived = false,
  }) async {
    return await repository.getNotifications(
      page: page,
      getArchived: getArchived,
    );
  }
}
