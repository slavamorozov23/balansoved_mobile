/// Интерфейс удалён от зависимости Yandex SDK и содержит
/// исключительно методы, необходимые для взаимодействия с нашим
/// Auth-API.
/// Расположен в features/yandex_oauth/data/data_source/
library;

abstract class IAuthRemoteDataSource {
  /// Отправка запроса регистрации.
  /// - 200: код подтверждения отправлен на email.
  /// - 409: пользователь уже существует (тоже считаем успехом с точки зрения UI).
  Future<void> registerRequest({
    required String email,
    required String password,
    required String userName,
  });

  /// Авторизация. Возвращает JWT-токен.
  Future<String> login({required String email, required String password});

  /// Принудительное обновление токена. Возвращает новый токен.
  Future<String> refreshToken({
    required String email,
    required String password,
  });

  /// Принять приглашение сотрудника с помощью ключа.
  Future<void> acceptInvitation(String invitationKey);

  /// Подтвердить регистрацию по email и коду. Возвращает JWT-токен при успехе.
  Future<String> confirmRegistration({
    required String email,
    required String code,
  });

  /// Запросить отправку инструкции/кода для сброса пароля на указанный email.
  Future<void> requestPasswordReset({required String email});

  /// Подтвердить сброс пароля (код из письма) и установить новый пароль.
  /// Возвращает JWT-токен при успешном сбросе.
  Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String currentPasswordHash,
  });
}
