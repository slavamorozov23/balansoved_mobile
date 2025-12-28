import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';

class RustoreNotificationsRemoteDataSource {
  final http.Client client;

  RustoreNotificationsRemoteDataSource({required this.client});

  Future<void> registerPushToken({
    required String accessToken,
    required String pushToken,
  }) async {
    final url = Uri.parse(NotificationsApiUrls.subscriptions());
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({'push_token': pushToken});

    try {
      final response = await client.post(url, headers: headers, body: body);
      if (response.statusCode == 201) return;
      throw ServerException(
        message: 'Ошибка регистрации push-токена',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        requestHeaders: headers,
        requestBody: body,
        responseBody: response.body,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при регистрации токена: $e',
        originalError: e.toString(),
        requestUrl: url.toString(),
      );
    }
  }

  Future<void> deleteSubscription({
    required String accessToken,
    required String pushToken,
  }) async {
    final url = Uri.parse(NotificationsApiUrls.subscriptions());
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({'push_token': pushToken});

    try {
      final request = http.Request('DELETE', url)
        ..headers.addAll(headers)
        ..body = body;
      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) return;
      throw ServerException(
        message: 'Ошибка удаления подписки',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        requestHeaders: headers,
        requestBody: body,
        responseBody: responseBody,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при удалении подписки: $e',
        originalError: e.toString(),
        requestUrl: url.toString(),
      );
    }
  }

  Future<void> sendTestNotification({
    required String accessToken,
    required String userId,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse(NotificationsApiUrls.sendNotification());
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final requestBody = jsonEncode({
      'user_id_to_notify': userId,
      'payload': {'title': title, 'body': body},
    });

    try {
      final response = await client.post(
        url,
        headers: headers,
        body: requestBody,
      );
      if (response.statusCode == 200) return;
      throw ServerException(
        message: 'Ошибка отправки уведомления',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        requestHeaders: headers,
        requestBody: requestBody,
        responseBody: response.body,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при отправке уведомления: $e',
        originalError: e.toString(),
        requestUrl: url.toString(),
      );
    }
  }
}

