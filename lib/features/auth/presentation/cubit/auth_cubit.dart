import 'package:balansoved_mobile/core/logging/auth_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:balansoved_mobile/core/error/failure.dart';
import 'package:balansoved_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/register_request_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/confirm_registration_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/accept_invitation_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterRequestUseCase _registerUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final SignOutUseCase _signOutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final ConfirmRegistrationUseCase _confirmRegistrationUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final RequestPasswordResetUseCase _requestPasswordResetUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  bool _isLoggingIn = false;
  // --- Переменные для повторной отправки кода ---
  String? _pendingEmail;
  String? _pendingPassword;
  String? _pendingUserName;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterRequestUseCase registerRequestUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required SignOutUseCase signOutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required ConfirmRegistrationUseCase confirmRegistrationUseCase,
    required AcceptInvitationUseCase acceptInvitationUseCase,
    required RequestPasswordResetUseCase requestPasswordResetUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerRequestUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _signOutUseCase = signOutUseCase,
       _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _confirmRegistrationUseCase = confirmRegistrationUseCase,
       _acceptInvitationUseCase = acceptInvitationUseCase,
       _requestPasswordResetUseCase = requestPasswordResetUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       super(AuthInitial());

  Future<void> checkAuth() async {
    sl<Talker>().logCustom(AuthLog('CUBIT: Проверка статуса авторизации'));
    final result = await _checkAuthStatusUseCase();
    _emitAuthResult(result);
  }

  Future<void> login({required String email, required String password}) async {
    if (_isLoggingIn || state is AuthAuthenticated) return;
    _isLoggingIn = true;
    sl<Talker>().logCustom(AuthLog('CUBIT: Начинаем авторизацию для: $email'));
    emit(AuthLoading());
    // Сохраняем email/password для возможной повторной отправки кода
    _pendingEmail = email;
    _pendingPassword = password;
    _pendingUserName = _pendingUserName ?? '';
    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка авторизации:', failure);
        // Проверяем, не связано ли с неподтвержденной регистрацией
        final details = failure.details ?? failure.message;
        final isNotConfirmed =
            (failure.details?.contains('Status Code: 423') ?? false) ||
            details.toLowerCase().contains('not confirmed') ||
            details.toLowerCase().contains('не подтвержден') ||
            details.toLowerCase().contains('not active');
        if (isNotConfirmed) {
          emit(AuthAwaitingEmailConfirmation(email));
        } else {
          emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode));
        }
        _isLoggingIn = false;
      },
      (_) async {
        sl<Talker>().logCustom(
          AuthLog('CUBIT: Авторизация успешна, проверяем статус'),
        );
        await checkAuth();
        _isLoggingIn = false;
      },
    );
  }

  Future<void> registerRequest({
    required String email,
    required String password,
    required String userName,
  }) async {
    // Сохраняем для возможности повторной отправки кода
    _pendingEmail = email;
    _pendingPassword = password;
    _pendingUserName = userName;
    sl<Talker>().logCustom(AuthLog('CUBIT: Начинаем регистрацию для: $email'));
    emit(AuthLoading());
    final result = await _registerUseCase(
      RegisterRequestParams(
        email: email,
        password: password,
        userName: userName,
      ),
    );
    result.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка регистрации:', failure);
        emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode));
      },
      (_) {
        sl<Talker>().logCustom(
          AuthLog('CUBИТ: Регистрация успешна, требуется подтверждение'),
        );
        emit(AuthAwaitingEmailConfirmation(email));
      },
    );
  }

  /// Повторно отправить код подтверждения
  Future<void> resendVerificationCode() async {
    if (_pendingEmail == null || _pendingPassword == null) {
      sl<Talker>().error('CUBIT: Нет данных для повторной отправки кода', '');
      return;
    }
    final userName = _pendingUserName ?? '';
    sl<Talker>().logCustom(
      AuthLog('CUBIT: Повторная отправка кода для ${_pendingEmail!}'),
    );
    emit(AuthLoading());
    final result = await _registerUseCase(
      RegisterRequestParams(
        email: _pendingEmail!,
        password: _pendingPassword!,
        userName: userName,
      ),
    );
    result.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка повторной отправки кода', failure);
        emit(AuthError(_mapFailure(failure)));
      },
      (_) {
        sl<Talker>().logCustom(AuthLog('CUBIT: Код отправлен повторно'));
        emit(AuthAwaitingEmailConfirmation(_pendingEmail!));
      },
    );
  }

  Future<void> signOut() async {
    sl<Talker>().logCustom(AuthLog('CUBIT: Выход из системы'));
    await _signOutUseCase();
    sl<Talker>().logCustom(AuthLog('CUBIT: Выход завершен'));
    emit(AuthUnauthenticated());
  }

  Future<void> refreshToken({
    required String email,
    required String password,
  }) async {
    sl<Talker>().logCustom(AuthLog('CUBIT: Обновление токена для: $email'));
    emit(AuthLoading());
    final result = await _refreshTokenUseCase(
      RefreshTokenParams(email: email, password: password),
    );
    result.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка обновления токена:', failure);
        emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode));
      },
      (_) async {
        await checkAuth();
      },
    );
  }

  Future<void> confirmRegistration({
    required String email,
    required String code,
  }) async {
    emit(AuthLoading());
    final result = await _confirmRegistrationUseCase(
      ConfirmRegistrationParams(email: email, code: code),
    );
    result.fold((failure) => emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode)), (_) async {
      await checkAuth();
    });
  }

  /// Шаг А: Запросить отправку кода сброса на email
  Future<bool> requestPasswordReset({required String email}) async {
    sl<Talker>().logCustom(AuthLog('CUBIT: Запрос сброса пароля для: $email'));
    emit(AuthLoading());
    final res = await _requestPasswordResetUseCase(
      RequestPasswordResetParams(email: email),
    );
    final ok = res.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка запроса сброса пароля:', failure);
        emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode));
        return false;
      },
      (_) {
        sl<Talker>().logCustom(
          AuthLog('CUBIT: Инструкции отправлены на email'),
        );
        // Сбрасываем лоадер без изменения авторизационного статуса
        emit(AuthInitial());
        return true;
      },
    );
    return ok;
  }

  /// Шаг Б: Подтверждение сброса пароля кодом и установка нового пароля
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    sl<Talker>().logCustom(AuthLog('CUBIT: Подтверждение сброса для: $email'));
    emit(AuthLoading());
    final res = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: email,
        newPassword: newPassword,
        currentPasswordHash: code,
      ),
    );
    res.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка при сбросе пароля:', failure);
        emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode));
      },
      (_) async {
        sl<Talker>().logCustom(
          AuthLog('CUBIT: Пароль сброшен, авторизуем пользователя'),
        );
        await checkAuth();
      },
    );
  }

  Future<bool> acceptInvitation(String invitationKey) async {
    sl<Talker>().logCustom(
      AuthLog('CUBIT: Начинаем подтверждение приглашения'),
    );
    // Не меняем глобальное состояние на Loading, чтобы не блокировать UI
    // Возвращаем bool для локальной обработки в виджете
    final result = await _acceptInvitationUseCase(invitationKey);
    return result.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка подтверждения приглашения:', failure);
        // НЕ меняем глобальное состояние при ошибке приглашения
        // так как это локальная операция, ошибка обрабатывается в UI
        // Возвращаем false при ошибке
        return false;
      },
      (_) {
        sl<Talker>().logCustom(
          AuthLog('CUBIT: Приглашение успешно подтверждено'),
        );
        // При успехе возвращаем true
        // Примечание: обновление профиля должно происходить в вызывающем коде
        // чтобы избежать циклических зависимостей между кубитами
        return true;
      },
    );
  }

  String _mapFailure(Failure failure) {
    // Всегда добавляем детали, если они есть (Server/Network/Cache/Unexpected)
    if (failure.details != null && failure.details!.isNotEmpty) {
      sl<Talker>().logCustom(
        AuthLog('CUBIT: Детали ошибки:\n${failure.details}'),
      );
      return '${failure.message}\n\nДетали: ${failure.details}';
    }
    return failure.message;
  }

  void _emitAuthResult(Either<Failure, Option<UserEntity>> res) {
    res.fold(
      (failure) {
        sl<Talker>().error('CUBIT: Ошибка проверки статуса:', failure);
        emit(AuthError(_mapFailure(failure), statusCode: failure.statusCode));
      },
      (option) => option.fold(
        () {
          sl<Talker>().logCustom(AuthLog('CUBIT: Пользователь не авторизован'));
          emit(AuthUnauthenticated());
        },
        (user) {
          sl<Talker>().logCustom(AuthLog('CUBIT: Пользователь авторизован'));
          emit(AuthAuthenticated(user));
        },
      ),
    );
  }
}


