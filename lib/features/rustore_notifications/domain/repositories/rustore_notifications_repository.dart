import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:balansoved_mobile/core/error/failure.dart';

abstract class IRustoreNotificationsRepository {
  Future<Either<Failure, bool>> ensureNotificationPermission();

  void attachCallbacks({
    required ValueChanged<String> onNewToken,
    required ValueChanged<dynamic> onMessageReceived,
    required VoidCallback onDeletedMessages,
    required ValueChanged<dynamic> onError,
    required ValueChanged<dynamic> onMessageOpenedApp,
  });

  Future<Either<Failure, String>> getPushToken();
  Future<Either<Failure, Unit>> deletePushToken();

  Future<Either<Failure, Unit>> registerPushToken(String pushToken);
  Future<Either<Failure, Unit>> deleteSubscription(String pushToken);
  Future<Either<Failure, Unit>> sendTestNotification({
    required String title,
    required String body,
  });

  Future<Either<Failure, String>> getUserId();
}

