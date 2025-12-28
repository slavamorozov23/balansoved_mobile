import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class SendTestNotificationUseCase {
  final IRustoreNotificationsRepository repository;

  const SendTestNotificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String title,
    required String body,
  }) {
    return repository.sendTestNotification(title: title, body: body);
  }
}

