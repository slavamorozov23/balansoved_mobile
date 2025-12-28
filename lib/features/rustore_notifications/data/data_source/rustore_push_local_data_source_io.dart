import 'package:flutter/foundation.dart';
import 'package:flutter_rustore_push/flutter_rustore_push.dart';
import 'package:permission_handler/permission_handler.dart';

class RustorePushLocalDataSource {
  Future<bool> ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  void attachCallbacks({
    required ValueChanged<String> onNewToken,
    required ValueChanged<dynamic> onMessageReceived,
    required VoidCallback onDeletedMessages,
    required ValueChanged<dynamic> onError,
    required ValueChanged<dynamic> onMessageOpenedApp,
  }) {
    RustorePushClient.attachCallbacks(
      onNewToken: onNewToken,
      onMessageReceived: onMessageReceived,
      onDeletedMessages: onDeletedMessages,
      onError: onError,
      onMessageOpenedApp: onMessageOpenedApp,
    );
  }

  Future<String> getToken() async {
    return RustorePushClient.getToken();
  }

  Future<void> deleteToken() async {
    await RustorePushClient.deleteToken();
  }
}

