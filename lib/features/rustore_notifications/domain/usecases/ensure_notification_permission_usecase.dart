import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class EnsureNotificationPermissionUseCase {
  final IRustoreNotificationsRepository repository;

  const EnsureNotificationPermissionUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.ensureNotificationPermission();
  }
}

