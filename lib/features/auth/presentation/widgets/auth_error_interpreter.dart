enum AuthErrorType {
  duplicateUser, // 409 register-request
  unconfirmedAccount, // 423 login/register-request
  invalidCredentials, // 401 login
  userNotFound, // 404 password/request-reset, register-confirm
  invalidCode, // 400 register-confirm
  invalidHash, // 401 password/reset
  invitationNotFound, // 404 accept-invitation
  badRequest, // 400 generic
  network,
  unknown,
}

class AuthErrorInfo {
  final AuthErrorType type;
  final String displayMessage;
  final int? statusCode;
  const AuthErrorInfo({
    required this.type,
    required this.displayMessage,
    this.statusCode,
  });
}

class AuthErrorInterpreter {
  static AuthErrorInfo interpret(String raw, {int? statusCode}) {
    final lower = raw.toLowerCase();

    // Приоритет: код, переданный из слоя presentation (из Failure.statusCode)
    int? code = statusCode;
    final codeMatch = RegExp(
      r'(status code:|response status:|status:|code)\s*(\d{3})',
      caseSensitive: false,
    ).firstMatch(raw);
    if (code == null && codeMatch != null) {
      code = int.tryParse(codeMatch.group(2) ?? '');
    }

    // Пытаемся достать server message из JSON кусочков в логах
    String? serverMessage;
    final jsonMsg = RegExp(
      r'"message"\s*:\s*"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(raw);
    if (jsonMsg != null) {
      serverMessage = jsonMsg.group(1);
    }
    final lowerMsg = serverMessage?.toLowerCase();

    bool containsAny(String s) =>
        lower.contains(s) || (lowerMsg?.contains(s) ?? false);

    // Известные коды/фразы
    if (containsAny('user with this email already exists') ||
        containsAny('пользователь уже существует') ||
        (code == 409)) {
      return AuthErrorInfo(
        type: AuthErrorType.duplicateUser,
        displayMessage: 'Пользователь с таким email уже существует.',
        statusCode: code ?? 409,
      );
    }

    if (containsAny('account not confirmed') ||
        containsAny('locked') ||
        containsAny('аккаунт не подтвержден') ||
        containsAny('аккаунт не подтверждён') ||
        containsAny('не подтвержден') ||
        (code == 423)) {
      return AuthErrorInfo(
        type: AuthErrorType.unconfirmedAccount,
        displayMessage:
            'Аккаунт не подтверждён. Проверьте email и введите код.',
        statusCode: code ?? 423,
      );
    }

    // Разделяем 401 «неверный хеш» vs «неверные креды»
    if ((code == 401 && (containsAny('hash') || containsAny('неверный хеш'))) ||
        containsAny('invalid hash')) {
      return AuthErrorInfo(
        type: AuthErrorType.invalidHash,
        displayMessage: 'Неверный код из письма (hash).',
        statusCode: code ?? 401,
      );
    }

    if (containsAny('invalid credentials') ||
        containsAny('неверные учетные данные') ||
        containsAny('неверные учётные данные') ||
        (code == 401 && containsAny('login'))) {
      return AuthErrorInfo(
        type: AuthErrorType.invalidCredentials,
        displayMessage: 'Неверные логин или пароль.',
        statusCode: code ?? 401,
      );
    }

    // Эвристика: текст Dio badResponse для login часто не содержит JSON message
    if (containsAny('вход') && containsAny('неверный ответ сервера')) {
      return const AuthErrorInfo(
        type: AuthErrorType.invalidCredentials,
        displayMessage: 'Неверные логин или пароль.',
        statusCode: 401,
      );
    }

    if (containsAny('user not found') ||
        containsAny('пользователь не найден') ||
        (code == 404 &&
            (containsAny('user') ||
                containsAny('email') ||
                containsAny('пользователь') ||
                containsAny('не найден')))) {
      return AuthErrorInfo(
        type: AuthErrorType.userNotFound,
        displayMessage: 'Пользователь не найден.',
        statusCode: code ?? 404,
      );
    }

    if (containsAny('invalid or expired code') ||
        containsAny('код неверен') ||
        containsAny('код просрочен') ||
        (code == 400 && containsAny('code'))) {
      return AuthErrorInfo(
        type: AuthErrorType.invalidCode,
        displayMessage: 'Код неверен или просрочен.',
        statusCode: code ?? 400,
      );
    }

    if ((code == 404 &&
            (containsAny('invitation') || containsAny('приглаш'))) ||
        containsAny('invitation not found')) {
      return AuthErrorInfo(
        type: AuthErrorType.invitationNotFound,
        displayMessage: 'Приглашение не найдено или уже использовано.',
        statusCode: 404,
      );
    }

    if (code == 400 ||
        containsAny('bad request') ||
        containsAny('некорректные данные')) {
      return AuthErrorInfo(
        type: AuthErrorType.badRequest,
        displayMessage: 'Некорректные данные запроса.',
        statusCode: code ?? 400,
      );
    }

    // Fallback «сеть» только если нет специфических кодов/фраз
    if (containsAny('ошибка соединения') ||
        containsAny('networkexception') ||
        containsAny('timeout')) {
      return AuthErrorInfo(
        type: AuthErrorType.network,
        displayMessage: 'Проблема соединения. Повторите попытку.',
        statusCode: code,
      );
    }

    return AuthErrorInfo(
      type: AuthErrorType.unknown,
      displayMessage:
          serverMessage ??
          'Неизвестная ошибка. Повторите попытку или обратитесь в поддержку.',
      statusCode: code,
    );
  }
}
