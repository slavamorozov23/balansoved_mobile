import 'dart:convert';
import 'package:balansoved_mobile/core/logging/auth_logger.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:balansoved_mobile/core/constants/constants.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../data_source/auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final Dio? dio;
  final http.Client? httpClient;

  AuthRemoteDataSourceImpl({this.dio, this.httpClient})
    : assert(
        dio != null || httpClient != null,
        'Either dio or httpClient must be provided',
      );

  @override
  Future<void> registerRequest({
    required String email,
    required String password,
    required String userName,
  }) async {
    if (dio != null) {
      return _registerRequestDio(email, password, userName);
    } else {
      return _registerRequestHttp(email, password, userName);
    }
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    if (dio != null) {
      return _loginDio(email, password);
    } else {
      return _loginHttp(email, password);
    }
  }

  @override
  Future<String> refreshToken({
    required String email,
    required String password,
  }) async {
    if (dio != null) {
      return _refreshTokenDio(email, password);
    } else {
      return _refreshTokenHttp(email, password);
    }
  }

  @override
  Future<void> acceptInvitation(String invitationKey) async {
    if (dio != null) {
      return _acceptInvitationDio(invitationKey);
    } else {
      return _acceptInvitationHttp(invitationKey);
    }
  }

  @override
  Future<String> confirmRegistration({
    required String email,
    required String code,
  }) async {
    if (dio != null) {
      return _confirmRegistrationDio(email, code);
    } else {
      return _confirmRegistrationHttp(email, code);
    }
  }

  // Dio версии методов
  Future<void> _registerRequestDio(
    String email,
    String password,
    String userName,
  ) async {
    final url = AuthApiUrls.registerRequest();
    final requestBody = {
      'email': email,
      'password': password,
      'user_name': userName,
    };
    final logRequestBody = {
      'email': email,
      'password': '*****',
      'user_name': userName,
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [DIO] Отправка запроса регистрации'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(
        AuthLog('Request Body: ${jsonEncode(logRequestBody)}'),
      );

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        sl<Talker>().logCustom(AuthLog('✅ [DIO] Регистрация успешна'));
        return;
      }

      // Любой не-200 статус трактуем как ServerException и пробрасываем наверх
      String? serverMessage;
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        serverMessage = raw['message']?.toString();
      } else if (raw is String) {
        try {
          final body = jsonDecode(raw);
          if (body is Map<String, dynamic>) {
            serverMessage = body['message']?.toString();
          }
        } catch (_) {}
      }
      final exception = ServerException(
        message: serverMessage ?? 'Ошибка регистрации',
        statusCode: response.statusCode,
        requestUrl: url,
        requestHeaders: dio!.options.headers.cast<String, String>(),
        requestBody: jsonEncode(logRequestBody),
        responseBody: response.data?.toString(),
      );
      sl<Talker>().error('❌ [DIO] Ошибка регистрации:', exception);
      throw exception;
    } on DioException catch (e, stackTrace) {
      // Если это ответ сервера с кодом, пробрасываем как ServerException, иначе NetworkException
      final status = e.response?.statusCode;
      if (status != null) {
        String? serverMessage;
        final raw = e.response?.data;
        if (raw is Map<String, dynamic>) {
          serverMessage = raw['message']?.toString();
        } else if (raw is String) {
          try {
            final body = jsonDecode(raw);
            if (body is Map<String, dynamic>) {
              serverMessage = body['message']?.toString();
            }
          } catch (_) {}
        }
        final exception = ServerException(
          message: serverMessage ?? 'Ошибка регистрации',
          statusCode: status,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: e.response?.data?.toString(),
          stackTrace: stackTrace.toString(),
        );
        sl<Talker>().error('❌ [DIO] Ошибка регистрации (код сервера):', exception);
        throw exception;
      }

      final errorDetails = _extractDioErrorDetails(e);
      final exception = NetworkException(
        message:
            'Ошибка соединения при регистрации: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
      sl<Talker>().error('❌ [DIO] Сетевая ошибка регистрации:', exception);
      sl<Talker>().logCustom(
        AuthLog('🔍 Детали Dio ошибки: ${errorDetails['details']}'),
      );
      throw exception;
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [DIO] Неожиданная ошибка регистрации:', e);
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        message: 'Неожиданная ошибка регистрации: $e',
        requestUrl: url,
        requestBody: jsonEncode(logRequestBody),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<String> _loginDio(String email, String password) async {
    final url = AuthApiUrls.login();
    final requestBody = {'email': email, 'password': password};
    final logRequestBody = {'email': email, 'password': '*****'};

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [DIO] Отправка запроса входа'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(
        AuthLog('Request Body: ${jsonEncode(logRequestBody)}'),
      );

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        // Ответ из шлюза может прийти как String (например, при неверном Content-Type),
        // поэтому аккуратно приводим к Map<String, dynamic> перед извлечением токена.
        final raw = response.data;
        Map<String, dynamic>? body;
        if (raw is Map<String, dynamic>) {
          body = raw;
        } else if (raw is String) {
          try {
            body = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            body = null;
          }
        }

        final token = body?['token'] as String?;
        if (token != null) {
          sl<Talker>().logCustom(AuthLog('✅ [DIO] Токен получен успешно'));
          return token;
        }
        final exception = ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: response.data?.toString(),
        );
        sl<Talker>().error('❌ [DIO] Токен отсутствует:', exception);
        throw exception;
      } else if (response.statusCode == 423) {
        throw ServerException(
          message: 'Account not confirmed',
          statusCode: 423,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: response.data?.toString(),
        );
      } else {
        final exception = ServerException(
          message: 'Ошибка авторизации',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: response.data?.toString(),
        );
        sl<Talker>().error('❌ [DIO] Ошибка авторизации:', exception);
        throw exception;
      }
    } on DioException catch (e, stackTrace) {
      // Если сервер вернул код (например 401/423), трактуем как ServerException, чтобы UI мог отобразить причину
      final status = e.response?.statusCode;
      if (status != null) {
        String? serverMessage;
        final raw = e.response?.data;
        if (raw is Map<String, dynamic>) {
          serverMessage = raw['message']?.toString();
        } else if (raw is String) {
          try {
            final body = jsonDecode(raw);
            if (body is Map<String, dynamic>) {
              serverMessage = body['message']?.toString();
            }
          } catch (_) {}
        }
        final exception = ServerException(
          message: serverMessage ?? (status == 423 ? 'Account not confirmed' : 'Ошибка авторизации'),
          statusCode: status,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: e.response?.data?.toString(),
          stackTrace: stackTrace.toString(),
        );
        sl<Talker>().error('❌ [DIO] Ошибка авторизации (код сервера):', exception);
        throw exception;
      }

      final errorDetails = _extractDioErrorDetails(e);
      final exception = NetworkException(
        message: 'Ошибка соединения при входе: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
      sl<Talker>().error('❌ [DIO] Сетевая ошибка входа:', exception);
      sl<Talker>().logCustom(
        AuthLog('🔍 Детали Dio ошибки: ${errorDetails['details']}'),
      );
      throw exception;
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [DIO] Неожиданная ошибка входа:', e);
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        message: 'Неожиданная ошибка входа: $e',
        requestUrl: url,
        requestBody: jsonEncode(logRequestBody),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<String> _refreshTokenDio(String email, String password) async {
    final url = AuthApiUrls.refreshToken();
    final requestBody = {'email': email, 'password': password};
    final logRequestBody = {'email': email, 'password': '*****'};

    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [DIO] Отправка запроса обновления токена'),
      );
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(
        AuthLog('Request Body: ${jsonEncode(logRequestBody)}'),
      );

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        // Ответ из шлюза может прийти как String (например, при неверном Content-Type),
        // поэтому аккуратно приводим к Map<String, dynamic> перед извлечением токена.
        final raw = response.data;
        Map<String, dynamic>? body;
        if (raw is Map<String, dynamic>) {
          body = raw;
        } else if (raw is String) {
          try {
            body = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            body = null;
          }
        }

        final token = body?['token'] as String?;
        if (token != null) {
          sl<Talker>().logCustom(AuthLog('✅ [DIO] Токен получен успешно'));
          return token;
        }
        final exception = ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: response.data?.toString(),
        );
        sl<Talker>().error('❌ [DIO] Токен отсутствует:', exception);
        throw exception;
      } else {
        final exception = ServerException(
          message: 'Ошибка обновления токена',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: dio!.options.headers.cast<String, String>(),
          requestBody: jsonEncode(logRequestBody),
          responseBody: response.data?.toString(),
        );
        sl<Talker>().error('❌ [DIO] Ошибка обновления токена:', exception);
        throw exception;
      }
    } on DioException catch (e, stackTrace) {
      final errorDetails = _extractDioErrorDetails(e);
      final exception = NetworkException(
        message:
            'Ошибка соединения при обновлении токена: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
      sl<Talker>().error(
        '❌ [DIO] Сетевая ошибка обновления токена:',
        exception,
      );
      sl<Talker>().logCustom(
        AuthLog('🔍 Детали Dio ошибки: ${errorDetails['details']}'),
      );
      throw exception;
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [DIO] Неожиданная ошибка обновления токена:', e);
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        message: 'Неожиданная ошибка обновления токена: $e',
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  // HTTP версии методов
  Future<void> _registerRequestHttp(
    String email,
    String password,
    String userName,
  ) async {
    final url = AuthApiUrls.registerRequest();
    final requestBody = jsonEncode({
      'email': email,
      'password': password,
      'user_name': userName,
    });
    final logRequestBody = jsonEncode({
      'email': email,
      'password': '*****',
      'user_name': userName,
    });
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [HTTP] Отправка запроса регистрации'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Headers: $headers'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));

      final response = await httpClient!
          .post(Uri.parse(url), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (!(response.statusCode == 200 ||
          response.statusCode == 409 ||
          response.statusCode == 423)) {
        final exception = ServerException(
          message: 'Ошибка регистрации',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: headers,
          requestBody: logRequestBody,
          responseBody: response.body,
        );
        sl<Talker>().error('❌ [HTTP] Ошибка регистрации:', exception);
        throw exception;
      }

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Регистрация успешна'));
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [HTTP] Ошибка регистрации:', e);
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при регистрации: $e',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<String> _loginHttp(String email, String password) async {
    final url = AuthApiUrls.login();
    final requestBody = jsonEncode({'email': email, 'password': password});
    final logRequestBody = jsonEncode({'email': email, 'password': '*****'});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [HTTP] Отправка запроса входа'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Headers: $headers'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));

      final response = await httpClient!
          .post(Uri.parse(url), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'] as String?;
        if (token != null) {
          sl<Talker>().logCustom(AuthLog('✅ [HTTP] Токен получен успешно'));
          return token;
        }
        final exception = ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: headers,
          requestBody: logRequestBody,
          responseBody: response.body,
        );
        sl<Talker>().error('❌ [HTTP] Токен отсутствует:', exception);
        throw exception;
      } else if (response.statusCode == 423) {
        throw ServerException(
          message: 'Account not confirmed',
          statusCode: 423,
          requestUrl: url,
          requestHeaders: headers,
          requestBody: logRequestBody,
          responseBody: response.body,
        );
      } else {
        final exception = ServerException(
          message: 'Ошибка авторизации',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: headers,
          requestBody: logRequestBody,
          responseBody: response.body,
        );
        sl<Talker>().error('❌ [HTTP] Ошибка авторизации:', exception);
        throw exception;
      }
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [HTTP] Ошибка входа:', e);
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при входе: $e',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<String> _refreshTokenHttp(String email, String password) async {
    final url = AuthApiUrls.refreshToken();
    final requestBody = jsonEncode({'email': email, 'password': password});
    final logRequestBody = jsonEncode({'email': email, 'password': '*****'});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      sl<Talker>().logCustom(
        AuthLog('🔵 [HTTP] Отправка запроса обновления токена'),
      );
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Headers: $headers'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));

      final response = await httpClient!
          .post(Uri.parse(url), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'] as String?;
        if (token != null) {
          sl<Talker>().logCustom(AuthLog('✅ [HTTP] Токен получен успешно'));
          return token;
        }
        final exception = ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: headers,
          requestBody: logRequestBody,
          responseBody: response.body,
        );
        sl<Talker>().error('❌ [HTTP] Токен отсутствует:', exception);
        throw exception;
      } else {
        final exception = ServerException(
          message: 'Ошибка обновления токена',
          statusCode: response.statusCode,
          requestUrl: url,
          requestHeaders: headers,
          requestBody: logRequestBody,
          responseBody: response.body,
        );
        sl<Talker>().error('❌ [HTTP] Ошибка обновления токена:', exception);
        throw exception;
      }
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [HTTP] Ошибка обновления токена:', e);
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при обновлении токена: $e',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<void> _acceptInvitationDio(String key) async {
    final url = AuthApiUrls.acceptInvitation();
    final requestBody = {"invitation_key": key};
    final logRequestBody = {
      "invitation_key":
          "...${key.length > 4 ? key.substring(key.length - 4) : key}",
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [DIO] Подтверждение приглашения'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));
      sl<Talker>().logCustom(AuthLog('Headers: ${dio!.options.headers}'));

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        sl<Talker>().logCustom(
          AuthLog('✅ [DIO] Приглашение успешно подтверждено'),
        );
        return;
      }

      final exception = ServerException(
        message: 'Ошибка подтверждения приглашения',
        statusCode: response.statusCode,
        requestUrl: url,
        requestHeaders: dio!.options.headers.cast<String, String>(),
        requestBody: logRequestBody.toString(),
        responseBody: response.data?.toString(),
      );
      sl<Talker>().error(
        '❌ [DIO] Ошибка подтверждения приглашения:',
        exception,
      );
      throw exception;
    } on DioException catch (e, stackTrace) {
      final errorDetails = _extractDioErrorDetails(e);
      final exception = NetworkException(
        message:
            'Ошибка соединения при подтверждении приглашения: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
      sl<Talker>().error(
        '❌ [DIO] Сетевая ошибка подтверждения приглашения:',
        exception,
      );
      sl<Talker>().logCustom(
        AuthLog('🔍 Детали Dio ошибки: ${errorDetails['details']}'),
      );
      throw exception;
    } catch (e, stackTrace) {
      sl<Talker>().error(
        '❌ [DIO] Неожиданная ошибка подтверждения приглашения:',
        e,
      );
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        message: 'Неожиданная ошибка подтверждения приглашения: $e',
        requestUrl: url,
        requestBody: logRequestBody.toString(),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<void> _acceptInvitationHttp(String key) async {
    final url = Uri.parse(AuthApiUrls.acceptInvitation());
    final requestBody = jsonEncode({"invitation_key": key});
    final logRequestBody = jsonEncode({
      "invitation_key":
          "...${key.length > 4 ? key.substring(key.length - 4) : key}",
    });
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [HTTP] Подтверждение приглашения'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Headers: $headers'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));

      final response = await httpClient!
          .post(url, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (response.statusCode == 200) {
        sl<Talker>().logCustom(
          AuthLog('✅ [HTTP] Приглашение успешно подтверждено'),
        );
        return;
      }

      final exception = ServerException(
        message: 'Ошибка подтверждения приглашения',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        requestHeaders: headers,
        requestBody: logRequestBody,
        responseBody: response.body,
      );
      sl<Talker>().error(
        '❌ [HTTP] Ошибка подтверждения приглашения:',
        exception,
      );
      throw exception;
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [HTTP] Ошибка подтверждения приглашения:', e);
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при подтверждении приглашения: $e',
        originalError: e.toString(),
        requestUrl: url.toString(),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  // ========== Новый метод подтверждения регистрации (Dio) ==========
  Future<String> _confirmRegistrationDio(String email, String code) async {
    final url = AuthApiUrls.registerConfirm();
    final requestBody = {'email': email, 'code': code};
    try {
      sl<Talker>().logCustom(AuthLog('🔵 [DIO] Подтверждение регистрации'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Request Body: $requestBody'));

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        // Ответ из шлюза может прийти как String (например, при неверном Content-Type),
        // поэтому аккуратно приводим к Map<String, dynamic> перед извлечением токена.
        final raw = response.data;
        Map<String, dynamic>? body;
        if (raw is Map<String, dynamic>) {
          body = raw;
        } else if (raw is String) {
          try {
            body = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            body = null;
          }
        }

        final token = body?['token'] as String?;
        if (token != null) return token;
        throw ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          responseBody: response.data?.toString(),
        );
      }
      throw ServerException(
        message: 'Ошибка подтверждения регистрации',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.data?.toString(),
      );
    } on DioException catch (e, stackTrace) {
      final errorDetails = _extractDioErrorDetails(e);
      throw NetworkException(
        message:
            'Ошибка соединения при подтверждении регистрации: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  // ========== Новый метод подтверждения регистрации (HTTP) ==========
  Future<String> _confirmRegistrationHttp(String email, String code) async {
    final url = AuthApiUrls.registerConfirm();
    final requestBody = jsonEncode({'email': email, 'code': code});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    try {
      sl<Talker>().logCustom(AuthLog('🔵 [HTTP] Подтверждение регистрации'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));

      final response = await httpClient!
          .post(Uri.parse(url), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'] as String?;
        if (token != null) return token;
        throw ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          responseBody: response.body,
        );
      }
      throw ServerException(
        message: 'Ошибка подтверждения регистрации',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.body,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при подтверждении регистрации: $e',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  // ======= Методы для сброса пароля =======
  @override
  Future<void> requestPasswordReset({required String email}) async {
    if (dio != null) {
      return _requestPasswordResetDio(email);
    } else {
      return _requestPasswordResetHttp(email);
    }
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String newPassword,
    required String currentPasswordHash,
  }) async {
    if (dio != null) {
      return _resetPasswordDio(email, newPassword, currentPasswordHash);
    } else {
      return _resetPasswordHttp(email, newPassword, currentPasswordHash);
    }
  }

  // Dio версии
  Future<void> _requestPasswordResetDio(String email) async {
    final url = AuthApiUrls.requestPasswordReset();
    final requestBody = {'email': email};
    try {
      sl<Talker>().logCustom(AuthLog('🔵 [DIO] Запрос на сброс пароля'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Request Body: $requestBody'));

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        return;
      }

      throw ServerException(
        message: 'Ошибка запроса сброса пароля',
        statusCode: response.statusCode,
        requestUrl: url,
        requestHeaders: dio!.options.headers.cast<String, String>(),
        requestBody: requestBody.toString(),
        responseBody: response.data?.toString(),
      );
    } on DioException catch (e, stackTrace) {
      final errorDetails = _extractDioErrorDetails(e);
      final exception = NetworkException(
        message:
            'Ошибка соединения при запросе сброса пароля: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: AuthApiUrls.requestPasswordReset(),
        stackTrace: stackTrace.toString(),
      );
      sl<Talker>().error(
        '❌ [DIO] Сетевая ошибка requestPasswordReset:',
        exception,
      );
      sl<Talker>().logCustom(
        AuthLog('🔍 Детали Dio ошибки: ${errorDetails['details']}'),
      );
      throw exception;
    } catch (e) {
      sl<Talker>().error('❌ [DIO] Неожиданная ошибка requestPasswordReset:', e);
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        message: 'Неожиданная ошибка requestPasswordReset: $e',
      );
    }
  }

  Future<String> _resetPasswordDio(
    String email,
    String newPassword,
    String currentPasswordHash,
  ) async {
    final url = AuthApiUrls.resetPassword();
    final requestBody = {
      'email': email,
      'new_password': newPassword,
      'current_password_hash': currentPasswordHash,
    };
    final logRequestBody = {
      'email': email,
      'new_password': '*****',
      'current_password_hash': '*****',
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [DIO] Подтверждение сброса пароля'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));

      final response = await dio!.post(url, data: requestBody);

      sl<Talker>().logCustom(AuthLog('✅ [DIO] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.data}'));

      if (response.statusCode == 200) {
        // Ответ из шлюза может прийти как String (например, при неверном Content-Type),
        // поэтому аккуратно приводим к Map<String, dynamic> перед извлечением токена.
        final raw = response.data;
        Map<String, dynamic>? body;
        if (raw is Map<String, dynamic>) {
          body = raw;
        } else if (raw is String) {
          try {
            body = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            body = null;
          }
        }

        final token = body?['token'] as String?;
        if (token != null) return token;

        throw ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          responseBody: response.data?.toString(),
        );
      }

      throw ServerException(
        message: 'Ошибка при сбросе пароля',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.data?.toString(),
      );
    } on DioException catch (e, stackTrace) {
      final errorDetails = _extractDioErrorDetails(e);
      throw NetworkException(
        message:
            'Ошибка соединения при сбросе пароля: ${errorDetails['message']}',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  // HTTP версии
  Future<void> _requestPasswordResetHttp(String email) async {
    final url = Uri.parse(AuthApiUrls.requestPasswordReset());
    final requestBody = jsonEncode({'email': email});
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [HTTP] Запрос на сброс пароля'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Request Body: $requestBody'));

      final response = await httpClient!
          .post(url, headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (response.statusCode == 200) {
        return;
      }

      throw ServerException(
        message: 'Ошибка запроса сброса пароля',
        statusCode: response.statusCode,
        requestUrl: url.toString(),
        requestHeaders: headers,
        requestBody: requestBody,
        responseBody: response.body,
      );
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [HTTP] Ошибка requestPasswordReset:', e);
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при запросе сброса пароля: $e',
        originalError: e.toString(),
        requestUrl: url.toString(),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  Future<String> _resetPasswordHttp(
    String email,
    String newPassword,
    String currentPasswordHash,
  ) async {
    final url = AuthApiUrls.resetPassword();
    final requestBody = jsonEncode({
      'email': email,
      'new_password': newPassword,
      'current_password_hash': currentPasswordHash,
    });
    final logRequestBody = jsonEncode({
      'email': email,
      'new_password': '*****',
      'current_password_hash': '*****',
    });
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      sl<Talker>().logCustom(AuthLog('🔵 [HTTP] Подтверждение сброса пароля'));
      sl<Talker>().logCustom(AuthLog('URL: $url'));
      sl<Talker>().logCustom(AuthLog('Request Body: $logRequestBody'));

      final response = await httpClient!
          .post(Uri.parse(url), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      sl<Talker>().logCustom(AuthLog('✅ [HTTP] Ответ получен'));
      sl<Talker>().logCustom(AuthLog('Status Code: ${response.statusCode}'));
      sl<Talker>().logCustom(AuthLog('Response Body: ${response.body}'));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'] as String?;
        if (token != null) return token;
        throw ServerException(
          message: 'Токен отсутствует в ответе сервера',
          statusCode: response.statusCode,
          requestUrl: url,
          responseBody: response.body,
        );
      }

      throw ServerException(
        message: 'Ошибка при сбросе пароля',
        statusCode: response.statusCode,
        requestUrl: url,
        responseBody: response.body,
      );
    } catch (e, stackTrace) {
      sl<Talker>().error('❌ [HTTP] Ошибка resetPassword:', e);
      if (e is ServerException) rethrow;
      throw NetworkException(
        message: 'Ошибка соединения при сбросе пароля: $e',
        originalError: e.toString(),
        requestUrl: url,
        stackTrace: stackTrace.toString(),
      );
    }
  }

  // Вспомогательный метод для извлечения деталей DioException
  Map<String, String> _extractDioErrorDetails(DioException e) {
    final buffer = StringBuffer();
    buffer.writeln('DioException Details:');
    buffer.writeln('Type: ${e.type}');
    buffer.writeln('Message: ${e.message}');

    if (e.response != null) {
      buffer.writeln('Response Status: ${e.response?.statusCode}');
      buffer.writeln('Response Headers: ${e.response?.headers}');
      buffer.writeln('Response Data: ${e.response?.data}');
    }

    buffer.writeln('Request URL: ${e.requestOptions.uri}');
    buffer.writeln('Request Method: ${e.requestOptions.method}');
    buffer.writeln('Request Headers: ${e.requestOptions.headers}');
    buffer.writeln('Request Data: ${e.requestOptions.data}');

    final message = switch (e.type) {
      DioExceptionType.connectionTimeout => 'Таймаут соединения',
      DioExceptionType.sendTimeout => 'Таймаут отправки',
      DioExceptionType.receiveTimeout => 'Таймаут получения',
      DioExceptionType.badCertificate => 'Проблема с сертификатом',
      DioExceptionType.badResponse => 'Неверный ответ сервера',
      DioExceptionType.cancel => 'Запрос отменен',
      DioExceptionType.connectionError => 'Ошибка соединения',
      DioExceptionType.unknown => 'Неизвестная ошибка',
    };

    return {'message': message, 'details': buffer.toString()};
  }
}


