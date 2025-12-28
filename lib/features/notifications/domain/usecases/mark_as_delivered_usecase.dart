import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/notifications/domain/repositories/notifications_repository.dart';

class MarkAsDeliveredUseCase {
  final NotificationsRepository repository;

  MarkAsDeliveredUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> noticeIds) async {
    return await repository.markAsDelivered(noticeIds);
  }
}
