import 'package:flutter/foundation.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';

class AttachRustoreCallbacksUseCase {
  final IRustoreNotificationsRepository repository;

  const AttachRustoreCallbacksUseCase(this.repository);

  void call({
    required ValueChanged<String> onNewToken,
    required ValueChanged<dynamic> onMessageReceived,
    required VoidCallback onDeletedMessages,
    required ValueChanged<dynamic> onError,
    required ValueChanged<dynamic> onMessageOpenedApp,
  }) {
    repository.attachCallbacks(
      onNewToken: onNewToken,
      onMessageReceived: onMessageReceived,
      onDeletedMessages: onDeletedMessages,
      onError: onError,
      onMessageOpenedApp: onMessageOpenedApp,
    );
  }
}

