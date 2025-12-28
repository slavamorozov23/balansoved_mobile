import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class DeleteSubscriptionUseCase {
  final IRustoreNotificationsRepository repository;

  const DeleteSubscriptionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String pushToken) {
    return repository.deleteSubscription(pushToken);
  }
}

