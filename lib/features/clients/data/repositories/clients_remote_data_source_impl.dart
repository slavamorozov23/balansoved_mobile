// -------------------------------------------------------------
// ⚠️ ВАЖНО — НЕ УДАЛЯТЬ
// -------------------------------------------------------------
// Этот класс реализует HTTP-взаимодействие c Gateway API
// (clients-api) и Cloud Function `edit-client`. Порядок полей в
// теле запроса формируется через [ClientModel.toJson]. Если
// изменится серверная спецификация, УДОСТОВЕРЬТЕСЬ, что
// соответствующие изменения внесены в ClientModel и здесь, чтобы
// бэкенд продолжал корректно понимать запросы.
// -------------------------------------------------------------

import 'dart:convert';

import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/core/logging/clients_logger.dart';
import 'package:balansoved_mobile/features/clients/data/data_source/clients_remote_data_source.dart';
import 'package:balansoved_mobile/features/clients/data/models/client_model.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class ClientsRemoteDataSourceImpl implements IClientsRemoteDataSource {
  final Dio? dio;
  final http.Client? httpClient;

  ClientsRemoteDataSourceImpl({this.dio, this.httpClient})
    : assert(
        dio != null || httpClient != null,
        'Either dio or httpClient must be provided',
      );

  @override
  Future<List<ClientEntity>> fetchClients(
    String token,
    String firmId, {
    bool onlyActual = false,
    String? clientId,
  }) async {
    sl<Talker>().logCustom(
      ClientsLog(
        'CLIENT DATA SOURCE: Начинаем получение клиентов для firmId: $firmId${clientId != null ? ', clientId: $clientId' : ''}',
      ),
    );

    final url = Uri.parse(ClientsApiUrls.manage());
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final requestData = {
      'firm_id': firmId,
      'action': 'GET',
      'page': 0,
      if (onlyActual) 'only_actual': true,
      if (clientId != null) 'client_id': clientId,
    };
    final body = jsonEncode(requestData);

    sl<Talker>().logCustom(ClientsLog('CLIENT DATA SOURCE: URL: $url'));
    sl<Talker>().logCustom(
      ClientsLog('CLIENT DATA SOURCE: Request body: $requestData'),
    );

    try {
      if (kIsWeb && httpClient != null) {
        final response = await httpClient!.post(
          url,
          headers: headers,
          body: body,
        );
        sl<Talker>().logCustom(
          ClientsLog(
            'CLIENT DATA SOURCE: HTTP Response status: ${response.statusCode}',
          ),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          final List<dynamic> clientsJson = responseData['data'] ?? [];
          final List<ClientEntity> clients =
              clientsJson
                  .map((json) => ClientModel.fromJson(json).toEntity())
                  .toList();

          sl<Talker>().logCustom(
            ClientsLog(
              'CLIENT DATA SOURCE: Успешно получено ${clients.length} клиентов через HTTP',
            ),
          );
          for (final client in clients) {
            sl<Talker>().logCustom(
              ClientsLog(
                'CLIENT DATA SOURCE: Client ${client.name} - profitTaxTypes: ${client.profitTaxTypes}',
              ),
            );
          }
          return clients;
        } else {
          sl<Talker>().error(
            'CLIENT DATA SOURCE: HTTP Error:',
            'Status ${response.statusCode}: ${response.body}',
          );
          throw ServerException(
            message: 'HTTP ${response.statusCode}: ${response.body}',
          );
        }
      } else if (dio != null) {
        final response = await dio!.post(
          url.toString(),
          options: Options(headers: headers),
          data: body,
        );

        sl<Talker>().logCustom(
          ClientsLog(
            'CLIENT DATA SOURCE: DIO Response status: ${response.statusCode}',
          ),
        );
        sl<Talker>().logCustom(
          ClientsLog('CLIENT DATA SOURCE: DIO Response: ${response.data}'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = _normalizeResponse(
            response.data,
          );
          final List<dynamic> clientsJson = _extractClientsList(
            responseData['data'],
          );
          final List<ClientEntity> clients =
              clientsJson
                  .map((json) => ClientModel.fromJson(json).toEntity())
                  .toList();

          sl<Talker>().logCustom(
            ClientsLog(
              'CLIENT DATA SOURCE: Успешно получено ${clients.length} клиентов через DIO',
            ),
          );
          for (final client in clients) {
            sl<Talker>().logCustom(
              ClientsLog(
                'CLIENT DATA SOURCE: Client ${client.name} - profitTaxTypes: ${client.profitTaxTypes}',
              ),
            );
          }
          return clients;
        } else {
          sl<Talker>().error(
            'CLIENT DATA SOURCE: DIO Error:',
            'Status ${response.statusCode}: ${response.data}',
          );
          throw ServerException(
            message: 'DIO ${response.statusCode}: ${response.data}',
          );
        }
      } else {
        throw NetworkException(message: 'Нет доступных HTTP клиентов');
      }
    } catch (e, stackTrace) {
      sl<Talker>().error(
        'CLIENT DATA SOURCE: Exception in fetchClients:',
        e,
        stackTrace,
      );
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException(message: 'Ошибка сети при получении клиентов: $e');
    }
  }

  @override
  Future<ClientEntity> upsertClient(
    String token,
    String firmId,
    ClientEntity client,
  ) {
    return dio != null
        ? _upsertClientDio(token, firmId, client)
        : _upsertClientHttp(token, firmId, client);
  }

  Future<ClientEntity> _upsertClientDio(
    String token,
    String firmId,
    ClientEntity client,
  ) async {
    final url = ClientsApiUrls.manage();
    try {
      sl<Talker>().info('CLIENT DATA SOURCE: UPSERT клиента ${client.id}');
      final response = await dio!.post(
        url,
        data: {
          'firm_id': firmId,
          'action': 'UPSERT',
          'client_id': client.id.isEmpty ? null : client.id,
          'payload': ClientModel.fromEntity(client).toJson(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      sl<Talker>().logCustom(
        ClientsLog('CLIENT DATA SOURCE: Ответ DIO: ${response.statusCode}'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Если есть данные клиента в ответе, используем их
        if (response.data != null) {
          final normalized = _normalizeResponse(response.data);
          final payload = _extractClientPayload(normalized['data']);
          if (payload != null) {
            final clientModel = ClientModel.fromJson(payload);
            return clientModel.toEntity();
          }
        }
        // Если статус 200/201 но нет данных клиента, возвращаем исходного клиента
        // Это нормально для операций UPDATE, когда сервер возвращает только подтверждение
        return client;
      }
      throw ServerException(
        message: 'Ошибка сохранения клиента',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.data.toString(),
      );
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Dio error',
        originalError: e.toString(),
        requestUrl: url,
      );
    }
  }

  Future<ClientEntity> _upsertClientHttp(
    String token,
    String firmId,
    ClientEntity client,
  ) async {
    final url = Uri.parse(ClientsApiUrls.manage());
    try {
      final response = await httpClient!.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firm_id': firmId,
          'action': 'UPSERT',
          'client_id': client.id.isEmpty ? null : client.id,
          'payload': ClientModel.fromEntity(client).toJson(),
        }),
      );
      sl<Talker>().info(
        'CLIENT DATA SOURCE: HTTP status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Если есть данные клиента в ответе, используем их
        if (response.body.isNotEmpty) {
          final responseJson = jsonDecode(response.body);
          if (responseJson != null && responseJson['data'] != null) {
            final responseData = responseJson['data'];
            final clientModel = ClientModel.fromJson(responseData);
            return clientModel.toEntity();
          }
        }
        // Если статус 200/201 но нет данных клиента, возвращаем исходного клиента
        // Это нормально для операций UPDATE, когда сервер возвращает только подтверждение
        return client;
      }
      throw ServerException(
        message: 'Ошибка сохранения клиента',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        responseBody: response.body,
      );
    } catch (e) {
      throw NetworkException(message: e.toString(), requestUrl: url.toString());
    }
  }

  @override
  Future<void> deleteClient(
    String token,
    String firmId,
    String clientId,
    DateTime creationDate,
  ) {
    return dio != null
        ? _deleteClientDio(token, firmId, clientId, creationDate)
        : _deleteClientHttp(token, firmId, clientId, creationDate);
  }

  Future<void> _deleteClientDio(
    String token,
    String firmId,
    String clientId,
    DateTime creationDate,
  ) async {
    final url = ClientsApiUrls.manage();
    try {
      final response = await dio!.post(
        url,
        data: {
          'firm_id': firmId,
          'action': 'DELETE',
          'client_id': clientId,
          'creation_date': creationDate.toIso8601String().split('T')[0],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) return;
      throw ServerException(
        message: 'Ошибка удаления клиента',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.data.toString(),
      );
    } on DioException catch (e) {
      throw NetworkException(
        message: e.message ?? 'Dio error',
        originalError: e.toString(),
        requestUrl: url,
      );
    }
  }

  Future<void> _deleteClientHttp(
    String token,
    String firmId,
    String clientId,
    DateTime creationDate,
  ) async {
    final url = Uri.parse(ClientsApiUrls.manage());
    try {
      final response = await httpClient!.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firm_id': firmId,
          'action': 'DELETE',
          'client_id': clientId,
          'creation_date':
              creationDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
        }),
      );
      if (response.statusCode == 200) return;
      throw ServerException(
        message: 'Ошибка удаления клиента',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        responseBody: response.body,
      );
    } catch (e) {
      throw NetworkException(message: e.toString(), requestUrl: url.toString());
    }
  }

  Map<String, dynamic> _normalizeResponse(dynamic raw) {
    if (raw is String) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    if (raw is Map<String, dynamic>) {
      final body = raw['body'];
      if (body is String) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      if (body is Map<String, dynamic>) {
        return body;
      }
      return raw;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractClientsList(dynamic payload) {
    if (payload is List) {
      return payload;
    }
    if (payload is String) {
      final decoded = jsonDecode(payload);
      if (decoded is List) {
        return decoded;
      }
    }
    return const [];
  }

  Map<String, dynamic>? _extractClientPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is String) {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }
    return null;
  }
}
