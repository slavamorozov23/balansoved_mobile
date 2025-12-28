import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/core/logging/clients_logger.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/clients/data/data_source/clients_remote_data_source.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class ClientsRepositoryImpl implements IClientsRepository {
  final IClientsRemoteDataSource remote;
  final IAuthLocalDataSource localAuth;

  ClientsRepositoryImpl({required this.remote, required this.localAuth});

  @override
  Future<Either<Failure, List<ClientEntity>>> getClients(
    String firmId, {
    bool onlyActual = false,
  }) async {
    try {
      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Starting getClients for firmId: $firmId, onlyActual: $onlyActual',
        ),
      );

      sl<Talker>().logCustom(
        ClientsLog('CLIENT REPO: Получаем JWT из локального хранилища'),
      );
      final token = await localAuth.getAccessToken();
      if (token == null) {
        sl<Talker>().error(
          'ClientsRepositoryImpl: No access token available',
          '',
        );
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }
      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Got token, calling remote.fetchClients',
        ),
      );

      // Всегда получаем все версии клиентов
      final allClients = await remote.fetchClients(
        token,
        firmId,
        onlyActual: false,
        clientId: null,
      );

      List<ClientEntity> resultClients;
      if (onlyActual) {
        // Фильтруем по manual_creation_date, оставляя только самые актуальные версии
        final clientGroups = <String, List<ClientEntity>>{};

        // Группируем клиентов по имени
        for (final client in allClients) {
          if (clientGroups[client.name] == null) {
            clientGroups[client.name] = [];
          }
          clientGroups[client.name]!.add(client);
        }

        // Для каждой группы выбираем версию с наиболее актуальным manual_creation_date
        resultClients = [];
        for (final group in clientGroups.values) {
          if (group.isNotEmpty) {
            group.sort((a, b) {
              final aDate =
                  a.manualCreationDate ?? a.creationDate ?? DateTime(1970);
              final bDate =
                  b.manualCreationDate ?? b.creationDate ?? DateTime(1970);
              return bDate.compareTo(
                aDate,
              ); // Сортируем по убыванию (новые первые)
            });
            resultClients.add(group.first); // Берем самую актуальную версию
          }
        }
      } else {
        resultClients = allClients;
      }

      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Successfully got ${resultClients.length} clients',
        ),
      );

      sl<Talker>().logCustom(
        ClientsLog(
          'CLIENT REPO: Данные получены (сырые): ${resultClients.length} клиентов',
        ),
      );
      return Right(resultClients);
    } catch (e, stackTrace) {
      sl<Talker>().error('ClientsRepositoryImpl: Exception in getClients', e);
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, details: e.toString()));
      } else if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, details: e.toString()));
      } else {
        return Left(
          UnexpectedFailure(
            message: e.toString(),
            details: stackTrace.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteClient(
    String firmId,
    String clientId,
    DateTime creationDate,
  ) async {
    try {
      final token = await localAuth.getAccessToken();
      if (token == null) {
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }

      await remote.deleteClient(token, firmId, clientId, creationDate);
      return const Right(unit);
    } catch (e, stackTrace) {
      sl<Talker>().error('ClientsRepositoryImpl: Exception in deleteClient', e);
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, details: e.toString()));
      } else if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, details: e.toString()));
      } else {
        return Left(
          UnexpectedFailure(
            message: e.toString(),
            details: stackTrace.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> getClientVersions(
    String firmId,
    String clientName,
  ) async {
    try {
      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Starting getClientVersions for firmId: $firmId, clientName: $clientName',
        ),
      );
      final token = await localAuth.getAccessToken();
      if (token == null) {
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }

      // Сначала получаем все клиенты для поиска client_id по имени
      final allClients = await remote.fetchClients(
        token,
        firmId,
        onlyActual: false,
        clientId: null,
      );

      // Находим client_id по имени клиента
      final clientWithName = allClients.firstWhere(
        (client) => client.name == clientName,
        orElse:
            () => throw Exception('Client with name "$clientName" not found'),
      );

      // Теперь получаем все версии конкретного клиента по client_id
      final versions = await remote.fetchClients(
        token,
        firmId,
        onlyActual: false,
        clientId: clientWithName.id,
      );

      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Successfully got ${versions.length} versions for client $clientName',
        ),
      );

      sl<Talker>().logCustom(
        ClientsLog(
          'CLIENT REPO: Получено ${versions.length} версий клиента $clientName',
        ),
      );
      return Right(versions);
    } catch (e, stackTrace) {
      sl<Talker>().error(
        'ClientsRepositoryImpl: Exception in getClientVersions',
        e,
      );
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, details: e.toString()));
      } else if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, details: e.toString()));
      } else {
        return Left(
          UnexpectedFailure(
            message: e.toString(),
            details: stackTrace.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> upsertClient(
    String firmId,
    ClientEntity client,
  ) async {
    try {
      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Starting upsertClient for firmId: $firmId, clientId: ${client.id}',
        ),
      );
      final token = await localAuth.getAccessToken();
      if (token == null) {
        sl<Talker>().error(
          'ClientsRepositoryImpl: No access token available for upsertClient',
          '',
        );
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }

      final savedClient = await remote.upsertClient(token, firmId, client);
      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Successfully saved client ${savedClient.id}',
        ),
      );
      return Right(savedClient);
    } catch (e, stackTrace) {
      sl<Talker>().error('ClientsRepositoryImpl: Exception in upsertClient', e);
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, details: e.toString()));
      } else if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, details: e.toString()));
      } else {
        return Left(
          UnexpectedFailure(
            message: e.toString(),
            details: stackTrace.toString(),
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllClientVersions(
    String firmId,
    String clientName,
  ) async {
    try {
      sl<Talker>().logCustom(
        ClientsLog(
          'ClientsRepositoryImpl: Starting deleteAllClientVersions for firmId: $firmId, clientName: $clientName',
        ),
      );
      final token = await localAuth.getAccessToken();
      if (token == null) {
        return Left(ConnectionFailure(message: 'Токен доступа отсутствует'));
      }

      // Получаем все версии клиента
      final versionsResult = await getClientVersions(firmId, clientName);

      return versionsResult.fold((failure) => Left(failure), (versions) async {
        sl<Talker>().logCustom(
          ClientsLog(
            'ClientsRepositoryImpl: Found ${versions.length} versions to delete for client $clientName',
          ),
        );

        // Удаляем каждую версию
        for (final version in versions) {
          // Используем manualCreationDate, если доступно, иначе fallback на creationDate
          final dateToUse = version.manualCreationDate ?? version.creationDate;
          if (dateToUse != null) {
            await remote.deleteClient(token, firmId, version.id, dateToUse);
          }
        }

        sl<Talker>().logCustom(
          ClientsLog(
            'ClientsRepositoryImpl: Successfully deleted all versions for client $clientName',
          ),
        );
        return const Right(unit);
      });
    } catch (e, stackTrace) {
      sl<Talker>().error(
        'ClientsRepositoryImpl: Exception in deleteAllClientVersions',
        e,
      );
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message, details: e.toString()));
      } else if (e is NetworkException) {
        return Left(NetworkFailure(message: e.message, details: e.toString()));
      } else {
        return Left(
          UnexpectedFailure(
            message: e.toString(),
            details: stackTrace.toString(),
          ),
        );
      }
    }
  }
}
