import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import '../entities/client_entity.dart';

abstract class IClientsRepository {
  Future<Either<Failure, List<ClientEntity>>> getClients(String firmId, {bool onlyActual = false});
  Future<Either<Failure, List<ClientEntity>>> getClientVersions(String firmId, String clientName);
  Future<Either<Failure, ClientEntity>> upsertClient(
    String firmId,
    ClientEntity client,
  );
  Future<Either<Failure, Unit>> deleteClient(String firmId, String clientId, DateTime creationDate);
  Future<Either<Failure, Unit>> deleteAllClientVersions(String firmId, String clientName);
}
