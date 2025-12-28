import 'package:balansoved_mobile/core/logging/clients_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/domain/repositories/clients_repository.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class GetClientVersionsUseCase {
  final IClientsRepository repository;

  GetClientVersionsUseCase(this.repository);

  Future<Either<Failure, List<ClientEntity>>> call(
    String firmId,
    String clientName,
  ) async {
    sl<Talker>().logCustom(
      ClientsLog(
        'GetClientVersionsUseCase: Getting versions for client: $clientName in firmId: $firmId',
      ),
    );

    try {
      final result = await repository.getClientVersions(firmId, clientName);

      return result.fold(
        (failure) {
          sl<Talker>().error(
            'GetClientVersionsUseCase: Repository call failed: ${failure.message}',
          );
          return Left(failure);
        },
        (clientVersions) {
          sl<Talker>().logCustom(
            ClientsLog(
              'GetClientVersionsUseCase: Successfully retrieved ${clientVersions.length} versions for client $clientName',
            ),
          );
          return Right(clientVersions);
        },
      );
    } catch (e) {
      sl<Talker>().error('GetClientVersionsUseCase: Unexpected error: $e');
      return Left(
        UnexpectedFailure(
          message: 'Неожиданная ошибка при получении версий клиента: $e',
        ),
      );
    }
  }
}
