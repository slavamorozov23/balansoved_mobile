import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class DeletePushTokenUseCase {
  final IRustoreNotificationsRepository repository;

  const DeletePushTokenUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.deletePushToken();
  }
}

