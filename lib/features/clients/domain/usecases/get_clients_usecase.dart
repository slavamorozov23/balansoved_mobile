import 'package:balansoved_mobile/core/logging/clients_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/domain/repositories/clients_repository.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class GetClientsUseCase {
  final IClientsRepository repository;

  GetClientsUseCase(this.repository);

  Future<Either<Failure, List<ClientEntity>>> call(
    String firmId, {
    bool onlyActual = false,
  }) async {
    sl<Talker>().logCustom(
      ClientsLog('🔵 GetClientsUseCase: Starting call for firmId: $firmId'),
    );

    try {
      final result = await repository.getClients(
        firmId,
        onlyActual: onlyActual,
      );

      return result.fold(
        (failure) {
          sl<Talker>().error(
            'GetClientsUseCase: Repository call failed: ${failure.message}',
          );
          return Left(failure);
        },
        (clients) {
          sl<Talker>().logCustom(
            ClientsLog(
              '🟢 GetClientsUseCase: Successfully retrieved ${clients.length} clients',
            ),
          );
          return Right(clients);
        },
      );
    } catch (e) {
      sl<Talker>().error('GetClientsUseCase: Unexpected error: $e');
      return Left(
        UnexpectedFailure(
          message: 'Неожиданная ошибка при получении клиентов: $e',
        ),
      );
    }
  }
}
