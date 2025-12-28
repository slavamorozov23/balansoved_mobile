import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';

/// Абстракция удалённого источника данных для клиентов.
/// Реализует универсальный endpoint /manage на clients-api.
abstract class IClientsRemoteDataSource {
  /// Получить список клиентов фирмы.
  /// [onlyActual] - если true, возвращает только актуальные версии клиентов
  /// [clientId] - если указан, возвращает все версии конкретного клиента
  Future<List<ClientEntity>> fetchClients(
    String token,
    String firmId, {
    bool onlyActual = false,
    String? clientId,
  });

  /// Создать/обновить клиента.
  Future<ClientEntity> upsertClient(
    String token,
    String firmId,
    ClientEntity client,
  );

  /// Удалить клиента по идентификатору.
  Future<void> deleteClient(
    String token,
    String firmId,
    String clientId,
    DateTime creationDate,
  );
}
