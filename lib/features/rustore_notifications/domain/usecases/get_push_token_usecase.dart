import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class GetPushTokenUseCase {
  final IRustoreNotificationsRepository repository;

  const GetPushTokenUseCase(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.getPushToken();
  }
}

