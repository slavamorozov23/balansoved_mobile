import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/attach_rustore_callbacks_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/delete_push_token_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/delete_subscription_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/get_push_token_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/get_user_id_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/register_push_token_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/send_test_notification_usecase.dart';

part 'rustore_notifications_state.dart';

class RustoreNotificationsCubit extends Cubit<RustoreNotificationsState> {
  final EnsureNotificationPermissionUseCase ensurePermission;
  final AttachRustoreCallbacksUseCase attachCallbacks;
  final GetPushTokenUseCase getPushToken;
  final DeletePushTokenUseCase deletePushToken;
  final RegisterPushTokenUseCase registerPushToken;
  final DeleteSubscriptionUseCase deleteSubscription;
  final SendTestNotificationUseCase sendTestNotification;
  final GetUserIdUseCase getUserId;

  RustoreNotificationsCubit({
    required this.ensurePermission,
    required this.attachCallbacks,
    required this.getPushToken,
    required this.deletePushToken,
    required this.registerPushToken,
    required this.deleteSubscription,
    required this.sendTestNotification,
    required this.getUserId,
  }) : super(const RustoreNotificationsState.initial());

  Future<void> initialize() async {
    _log('Инициализация RuStore Push...');
    emit(state.copyWith(isLoading: true));

    final userIdResult = await getUserId();
    final userId = userIdResult.fold(
      (failure) {
        _log('Пользователь не авторизован: ${failure.message}');
        emit(state.copyWith(
          status: RustoreAuthStatus.unauthenticated,
          isLoading: false,
        ));
        return null;
      },
      (value) => value,
    );
    if (userId == null) return;

    emit(state.copyWith(
      status: RustoreAuthStatus.authenticated,
      userId: userId,
    ));

    final permissionResult = await ensurePermission();
    final permissionGranted = permissionResult.fold(
      (failure) {
        _log('Ошибка запроса разрешений: ${failure.message}');
        emit(state.copyWith(isLoading: false));
        return false;
      },
      (granted) => granted,
    );
    if (!permissionGranted) {
      _log('Разрешение на уведомления не предоставлено.');
      emit(state.copyWith(isLoading: false));
      return;
    }

    attachCallbacks(
      onNewToken: (token) async {
        _log('RuStore SDK: получен новый токен: ...${_tail(token)}');
        emit(state.copyWith(pushToken: token));
        await _registerToken(token);
      },
      onMessageReceived: (value) {
        final body = value?.notification?.body?.toString();
        _log('RuStore SDK: получено сообщение: ${body ?? 'без текста'}');
      },
      onDeletedMessages: () => _log('RuStore SDK: сообщения удалены'),
      onError: (value) => _log('RuStore SDK: ошибка: $value'),
      onMessageOpenedApp: (value) {
        final title = value?.notification?.title?.toString();
        _log('RuStore SDK: приложение открыто: ${title ?? 'без заголовка'}');
      },
    );

    final tokenResult = await getPushToken();
    tokenResult.fold(
      (failure) {
        _log('Не удалось получить токен: ${failure.message}');
      },
      (token) async {
        _log('RuStore SDK: текущий токен: ...${_tail(token)}');
        emit(state.copyWith(pushToken: token));
        await _registerToken(token);
      },
    );

    emit(state.copyWith(isLoading: false));
  }

  Future<void> refreshAll() async {
    _log('Обновление подписки...');
    await initialize();
  }

  Future<void> requestNewToken() async {
    _log('Запрос нового push-токена у RuStore SDK...');
    final tokenResult = await getPushToken();
    await tokenResult.fold(
      (failure) async {
        _log('Не удалось получить токен: ${failure.message}');
      },
      (token) async {
        _log('RuStore SDK: получен токен: ...${_tail(token)}');
        emit(state.copyWith(pushToken: token));
        await _registerToken(token);
      },
    );
  }

  Future<void> deleteTokenAndSubscription() async {
    final token = state.pushToken;
    if (token.isEmpty) {
      _log('Нет токена для удаления');
      return;
    }

    _log('Удаление токена...');
    final deleteResult = await deletePushToken();
    deleteResult.fold(
      (failure) => _log('Ошибка удаления токена: ${failure.message}'),
      (_) => _log('RuStore SDK: токен удален локально'),
    );

    final subscriptionResult = await deleteSubscription(token);
    subscriptionResult.fold(
      (failure) => _log('Ошибка удаления подписки: ${failure.message}'),
      (_) => _log('Бэкенд: подписка удалена'),
    );

    emit(state.copyWith(pushToken: '', isTokenRegistered: false));
  }

  Future<void> sendTestPush() async {
    if (state.userId == null) {
      _log('Невозможно отправить уведомление: user_id отсутствует');
      return;
    }
    if (!state.isTokenRegistered) {
      _log('Устройство не зарегистрировано в подписках');
      return;
    }

    _log('Отправка тестового уведомления...');
    final result = await sendTestNotification(
      title: 'Тест с бэкенда',
      body: 'Это уведомление отправлено через API!',
    );
    result.fold(
      (failure) => _log('Ошибка отправки: ${failure.message}'),
      (_) => _log('Команда на отправку уведомления принята'),
    );
  }

  Future<void> _registerToken(String token) async {
    final result = await registerPushToken(token);
    result.fold(
      (failure) {
        _log('Ошибка регистрации токена: ${failure.message}');
        emit(state.copyWith(isTokenRegistered: false));
      },
      (_) {
        _log('Бэкенд: токен зарегистрирован');
        emit(state.copyWith(isTokenRegistered: true));
      },
    );
  }

  void _log(String message) {
    final now = DateTime.now();
    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    final entry = '[$timestamp] $message';
    emit(state.copyWith(logs: [entry, ...state.logs]));
  }

  String _tail(String token) {
    if (token.length <= 10) return token;
    return token.substring(token.length - 10);
  }
}

