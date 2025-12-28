import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:balansoved_mobile/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required int page,
    bool getArchived = false,
    required String token,
  });

  Future<NotificationModel> getNotificationById(String noticeId, String token);

  Future<void> archiveNotification(String noticeId, String token);

  Future<void> markAsDelivered(List<String> noticeIds, String token);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final http.Client client;

  NotificationsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<NotificationModel>> getNotifications({
    required int page,
    bool getArchived = false,
    required String token,
  }) async {
    final uri = Uri.parse(NotificationsApiUrls.getNotices()).replace(
      queryParameters: {
        'page': page.toString(),
        'get_archived': getArchived.toString(),
      },
    );

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> noticesJson = jsonResponse['data'] ?? [];

        return noticesJson
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to load notifications',
        statusCode: response.statusCode,
        requestUrl: uri.toString(),
        responseBody: response.body,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException(
        message: 'Ошибка сети при получении уведомлений: $e',
        requestUrl: uri.toString(),
      );
    }
  }

  @override
  Future<NotificationModel> getNotificationById(
    String noticeId,
    String token,
  ) async {
    final uri = Uri.parse(NotificationsApiUrls.getNoticeById(noticeId));
    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return NotificationModel.fromJson(jsonResponse);
      }

      throw ServerException(
        message: 'Failed to load notification',
        statusCode: response.statusCode,
        requestUrl: uri.toString(),
        responseBody: response.body,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException(
        message: 'Ошибка сети при получении уведомления: $e',
        requestUrl: uri.toString(),
      );
    }
  }

  @override
  Future<void> archiveNotification(String noticeId, String token) async {
    final uri = Uri.parse(NotificationsApiUrls.archiveNotice());
    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'notice_id': noticeId}),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to archive notification',
          statusCode: response.statusCode,
          requestUrl: uri.toString(),
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException(
        message: 'Ошибка сети при архивировании уведомления: $e',
        requestUrl: uri.toString(),
      );
    }
  }

  @override
  Future<void> markAsDelivered(List<String> noticeIds, String token) async {
    final uri = Uri.parse(NotificationsApiUrls.markAsDelivered());
    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'notice_ids': noticeIds}),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to mark notifications as delivered',
          statusCode: response.statusCode,
          requestUrl: uri.toString(),
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw NetworkException(
        message: 'Ошибка сети при отметке уведомлений как доставленных: $e',
        requestUrl: uri.toString(),
      );
    }
  }
}
