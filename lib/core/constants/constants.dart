/// Ссылки для внешних API и внутренних сервисов.
///
/// Для удобства и читаемости каждая группа эндпоинтов вынесена
/// в отдельный класс. При необходимости добавляйте новые классы
/// с суффиксом `Urls`.
library;

// === OpenWeather ===
class WeatherUrls {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'c1f8f2f4a6f7896c7bfa5450cfc742d4';

  static String currentWeatherByName(String city) =>
      '$_baseUrl/weather?q=$city&appid=$_apiKey';

  static String weatherIcon(String iconCode) =>
      'http://openweathermap.org/img/wn/$iconCode@2x.png';
}

// === Balansoved Auth-API (Yandex Cloud Gateway) ===
class AuthApiUrls {
  /// Базовый URL шлюза API (см. `test_auth_api.py`).
  static const String _baseUrl =
      'https://d5dq1774ef3d58c82i0p.laqt4bj7.apigw.yandexcloud.net';

  /// Запрос регистрации. Телом запроса должен быть JSON:
  /// `{ "email": ..., "password": ..., "user_name": ... }`
  static String registerRequest() => '$_baseUrl/register-request';

  /// Авторизация. Телом запроса – `{ "email": ..., "password": ... }`.
  /// В ответе ожидается JSON с полем `token`.
  static String login() => '$_baseUrl/login';

  /// Принудительное обновление токена. Тело запроса идентично login.
  /// В ответе также поле `token`.
  static String refreshToken() => '$_baseUrl/refresh-token';

  /// Активация приглашения.
  static String acceptInvitation() => '$_baseUrl/accept-invitation';

  /// Подтвердить регистрацию с помощью кода из email. Телом запроса – `{ "email": ..., "code": ... }`.
  static String registerConfirm() => '$_baseUrl/register-confirm';

  /// Запросить отправку инструкции/кода для сброса пароля на указанный email.
  static String requestPasswordReset() => '$_baseUrl/password/request-reset';

  /// Подтвердить сброс пароля и установить новый пароль.
  /// Тело запроса: `{ "email": ..., "new_password": ..., "current_password_hash": ... }`
  /// В ответе ожидается JSON с полем `token`.
  static String resetPassword() => '$_baseUrl/password/reset';
}

// === Balansoved Management API (Employees, Firms, Tasks) ===
class ManagementApiUrls {
  /// Базовый URL шлюза employees-and-firms API (см. спецификацию Gateway).
  static const String _baseUrl =
      'https://d5dgn7jib7h7qjl33tdp.laqt4bj7.apigw.yandexcloud.net';

  /// Получить все данные пользователя (информация, фирмы, задачи) по JWT.
  static String getUserData() => '$_baseUrl/get-user-data';

  /// Редактирование/получение информации о сотрудниках (POST).
  static String editEmployees() => '$_baseUrl/employees/edit';

  /// Создание сотрудника (POST).
  static String createEmployee() => '$_baseUrl/employees/create';

  /// Приглашение сотрудника (POST).
  static String inviteEmployee() => '$_baseUrl/employees/invite';

  /// Удаление сотрудника (POST).
  static String deleteEmployee() => '$_baseUrl/employees/delete';

  /// Создать новую фирму (POST).
  static String createFirm() => '$_baseUrl/firms/create';
}

// === Balansoved Clients API (Clients management) ===
class ClientsApiUrls {
  /// Базовый URL шлюза clients-api (см. спецификацию Gateway).
  static const String _baseUrl =
      'https://d5domf1ev0daigtm42of.y1haggxy.apigw.yandexcloud.net';

  /// Универсальный endpoint для работы с клиентами (GET, UPSERT, DELETE).
  /// Для всех операций используется метод POST.
  static String manage() => '$_baseUrl/manage';

  /// Универсальный endpoint для работы с оплатами клиентов (GET, UPSERT, DELETE).
  /// Для всех операций используется метод POST.
  static String managePayments() => '$_baseUrl/payments/manage';

  /// Универсальный endpoint для работы с метаданными клиентов (GET, UPSERT, DELETE).
  /// Для всех операций используется метод POST.
  static String manageMetadata() => '$_baseUrl/metadata/manage';
}

// === Balansoved Tasks API (Tasks management) ===
class TasksApiUrls {
  /// Базовый URL шлюза tasks-api (см. спецификацию Gateway).
  static const String _baseUrl =
      'https://d5d7ct0sul274igh4vij.aqkd4clz.apigw.yandexcloud.net';

  /// Универсальный endpoint для работы с задачами (GET, UPSERT, DELETE).
  /// Для всех операций используется метод POST.
  static String manage() => '$_baseUrl/manage';
}

// === Balansoved Tariffs and Storage API (Tariffs and Storage management) ===
class TariffsAndStorageApiUrls {
  /// Базовый URL шлюза tariffs-and-storage-api (см. спецификацию Gateway).
  static const String _baseUrl =
      'https://d5d5vaj6bd49bcvhnfbh.sk0vql13.apigw.yandexcloud.net';

  /// Универсальный endpoint для работы с тарифами и хранилищем.
  /// Поддерживает действия: GET_RECORD, UPDATE_JSON, CLEAR_JSON,
  /// GET_UPLOAD_URL, GET_DOWNLOAD_URL, CONFIRM_UPLOAD, DELETE_FILE.
  /// Для всех операций используется метод POST.
  static String manage() => '$_baseUrl/manage';

  /// Универсальный endpoint для работы с интеграциями фирмы (GET, UPSERT, DELETE).
  /// Для всех операций используется метод POST.
  static String integrations() => '$_baseUrl/integrations';
}

// === Balansoved Scheduler API (Scheduled events) ===
class SchedulerApiUrls {
  static const String _baseUrl =
      'https://d5dln4usaaktunc0kvia.8wihnuyr.apigw.yandexcloud.net';

  /// Универсальный endpoint manage (GET, UPSERT, DELETE)
  static String manage() => '$_baseUrl/manage';

  /// Триггер ручного запуска (не используется здесь, но оставим для справки)
  static String trigger() => '$_baseUrl/trigger';
}

// === Balansoved Notifications API (Notifications management) ===
class NotificationsApiUrls {
  /// Базовый URL шлюза notifications-api (см. спецификацию Gateway).
  static const String _baseUrl =
      'https://d5dcdq2hqt509q04gjkc.bixf7e87.apigw.yandexcloud.net';

  /// Получить список уведомлений (новых или архивных)
  static String getNotices() => '$_baseUrl/notices';

  /// Получить одно уведомление по ID
  static String getNoticeById(String noticeId) => '$_baseUrl/notices/$noticeId';

  /// Архивировать одно уведомление
  static String archiveNotice() => '$_baseUrl/notices/archive';

  /// Пометить уведомления как доставленные
  static String markAsDelivered() => '$_baseUrl/notices/mark-as-delivered';

  /// Подписка устройства на push-уведомления
  static String subscriptions() => '$_baseUrl/subscriptions';

  /// Отправка тестового уведомления
  static String sendNotification() => '$_baseUrl/send-notification';
}

// === Balansoved Comments API (Comments management) ===
class CommentsApiUrls {
  /// Базовый URL шлюза comments-manager API.
  static const String _baseUrl =
      'https://d5dsvummtfvdrh6kirdt.a6hc9vya.apigw.yandexcloud.net';

  /// Универсальный endpoint manage (GET, UPSERT, DELETE)
  static String manage() => '$_baseUrl/manage';
}

// === Balansoved Version API (Static application version) ===
class VersionApiUrls {
  /// Базовый URL шлюза version-api (см. спецификацию Gateway).
  static const String _baseUrl =
      'https://d5d9ls5ofsa9qung38ra.lievo6ut.apigw.yandexcloud.net';

  /// Получить актуальную версию приложения.
  static String current() => '$_baseUrl/current';
}
