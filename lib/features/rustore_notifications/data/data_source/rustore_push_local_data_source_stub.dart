import 'package:flutter/foundation.dart';

class RustorePushLocalDataSource {
  Future<bool> ensureNotificationPermission() async => false;

  void attachCallbacks({
    required ValueChanged<String> onNewToken,
    required ValueChanged<dynamic> onMessageReceived,
    required VoidCallback onDeletedMessages,
    required ValueChanged<dynamic> onError,
    required ValueChanged<dynamic> onMessageOpenedApp,
  }) {}

  Future<String> getToken() async {
    throw UnsupportedError('RuStore Push поддерживается только на Android.');
  }

  Future<void> deleteToken() async {
    throw UnsupportedError('RuStore Push поддерживается только на Android.');
  }
}

