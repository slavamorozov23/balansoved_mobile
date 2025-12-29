import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:balansoved_mobile/router.dart';
import 'package:balansoved_mobile/core/network/dio_web_adapter.dart'
    as dio_web_adapter;

import 'package:balansoved_mobile/features/auth/data/data_source/auth_local_data_source.dart';
import 'package:balansoved_mobile/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:balansoved_mobile/features/auth/data/repositories/auth_local_data_source_impl.dart';
import 'package:balansoved_mobile/features/auth/data/repositories/auth_remote_data_source_impl.dart';
import 'package:balansoved_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:balansoved_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/accept_invitation_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/confirm_registration_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/register_request_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:balansoved_mobile/features/rustore_notifications/data/data_source/rustore_notifications_remote_data_source.dart';
import 'package:balansoved_mobile/features/rustore_notifications/data/data_source/rustore_push_local_data_source.dart';
import 'package:balansoved_mobile/features/rustore_notifications/data/repositories/rustore_notifications_repository_impl.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/repositories/rustore_notifications_repository.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/attach_rustore_callbacks_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/delete_push_token_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/delete_subscription_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/ensure_notification_permission_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/get_push_token_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/get_user_id_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/register_push_token_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/domain/usecases/send_test_notification_usecase.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/cubit/rustore_notifications_cubit.dart';

import 'package:balansoved_mobile/features/firms/data/data_source/firms_remote_data_source.dart';
import 'package:balansoved_mobile/features/firms/data/repositories/firms_repository_impl.dart';
import 'package:balansoved_mobile/features/firms/domain/repositories/firms_repository.dart';
import 'package:balansoved_mobile/features/firms/domain/usecases/get_firms_usecase.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';

import 'package:balansoved_mobile/features/clients/data/data_source/clients_remote_data_source.dart';
import 'package:balansoved_mobile/features/clients/data/repositories/clients_remote_data_source_impl.dart';
import 'package:balansoved_mobile/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:balansoved_mobile/features/clients/domain/repositories/clients_repository.dart';
import 'package:balansoved_mobile/features/clients/domain/usecases/get_client_versions_usecase.dart';
import 'package:balansoved_mobile/features/clients/domain/usecases/get_clients_usecase.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/client_versions_cubit.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';

import 'package:balansoved_mobile/features/employees/data/data_source/employees_remote_data_source.dart';
import 'package:balansoved_mobile/features/employees/data/repositories/employees_remote_data_source_impl.dart';
import 'package:balansoved_mobile/features/employees/data/repositories/employees_repository_impl.dart';
import 'package:balansoved_mobile/features/employees/domain/repositories/employees_repository.dart';
import 'package:balansoved_mobile/features/employees/domain/usecases/get_employees_usecase.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';

import 'package:balansoved_mobile/features/tasks/data/data_source/tasks_remote_data_source.dart';
import 'package:balansoved_mobile/features/tasks/data/repositories/tasks_remote_data_source_impl.dart';
import 'package:balansoved_mobile/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:balansoved_mobile/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/get_task_usecase.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/save_task_usecase.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';

import 'package:balansoved_mobile/features/notifications/data/data_source/notifications_remote_data_source.dart';
import 'package:balansoved_mobile/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:balansoved_mobile/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:balansoved_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:balansoved_mobile/features/notifications/domain/usecases/mark_as_delivered_usecase.dart';
import 'package:balansoved_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';

import 'package:balansoved_mobile/features/comments/data/data_source/comments_remote_data_source.dart';
import 'package:balansoved_mobile/features/comments/data/repositories/comments_repository_impl.dart';
import 'package:balansoved_mobile/features/comments/domain/repositories/comments_repository.dart';
import 'package:balansoved_mobile/features/comments/domain/usecases/get_comments_usecase.dart';
import 'package:balansoved_mobile/features/comments/domain/usecases/create_comment_usecase.dart';
import 'package:balansoved_mobile/features/comments/domain/usecases/update_comment_usecase.dart';
import 'package:balansoved_mobile/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:balansoved_mobile/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/data_source/tariffs_and_storage_remote_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/data_source/file_download_remote_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/data_source/file_save_local_data_source.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/repositories/file_download_remote_data_source_impl.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/repositories/file_save_local_data_source_impl.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/repositories/tariffs_and_storage_remote_data_source_impl.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/data/repositories/tariffs_and_storage_repository_impl.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/domain/repositories/tariffs_and_storage_repository.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/domain/usecases/download_and_save_file_usecase.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/domain/usecases/download_file_usecase.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/presentation/cubit/file_download_cubit.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/presentation/cubit/tariffs_and_storage_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      enabled: true,
      useHistory: true,
      maxHistoryItems: 100,
      useConsoleLogs: true,
    ),
    logger: TalkerLogger(settings: TalkerLoggerSettings(enableColors: true)),
  );
  sl.registerSingleton<Talker>(talker);

  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 15);
  dio.options.receiveTimeout = const Duration(minutes: 5);
  dio.options.sendTimeout = const Duration(minutes: 5);
  dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';

  dio.interceptors.add(
    TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printRequestData: false,
        printResponseData: false,
        printRequestHeaders: false,
        printResponseHeaders: false,
      ),
    ),
  );

  dio_web_adapter.configureDioForWeb(dio, withCredentials: false);
  if (kIsWeb) {
    sl<Talker>().log('[SETUP] Using browser adapter for Dio');
  } else {
    sl<Talker>().log('[SETUP] Using default Dio adapter');
  }

  sl.registerSingleton<Dio>(dio);
  sl.registerLazySingleton(() => http.Client());

  sl.registerSingleton<AppRouter>(AppRouter());

  _registerAuthFeature();
  _registerRustoreNotificationsFeature();
  _registerFirmsFeature();
  _registerClientsFeature();
  _registerEmployeesFeature();
  _registerTasksFeature();
  _registerNotificationsFeature();
  _registerCommentsFeature();
  _registerTariffsAndStorageFeature();

  sl<Talker>().log('[SETUP] Dependencies registered');
}

void _registerAuthFeature() {
  sl.registerLazySingleton(
    () => AuthCubit(
      loginUseCase: sl(),
      registerRequestUseCase: sl(),
      refreshTokenUseCase: sl(),
      signOutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      confirmRegistrationUseCase: sl(),
      acceptInvitationUseCase: sl(),
      requestPasswordResetUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterRequestUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => AcceptInvitationUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmRegistrationUseCase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(prefs: sl()),
  );
}

void _registerRustoreNotificationsFeature() {
  sl.registerLazySingleton(
    () => RustorePushLocalDataSource(),
  );
  sl.registerLazySingleton(
    () => RustoreNotificationsRemoteDataSource(client: sl()),
  );

  sl.registerLazySingleton<IRustoreNotificationsRepository>(
    () => RustoreNotificationsRepositoryImpl(
      pushLocalDataSource: sl(),
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => EnsureNotificationPermissionUseCase(sl()));
  sl.registerLazySingleton(() => AttachRustoreCallbacksUseCase(sl()));
  sl.registerLazySingleton(() => GetPushTokenUseCase(sl()));
  sl.registerLazySingleton(() => DeletePushTokenUseCase(sl()));
  sl.registerLazySingleton(() => RegisterPushTokenUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => SendTestNotificationUseCase(sl()));
  sl.registerLazySingleton(() => GetUserIdUseCase(sl()));

  sl.registerFactory(
    () => RustoreNotificationsCubit(
      ensurePermission: sl(),
      attachCallbacks: sl(),
      getPushToken: sl(),
      deletePushToken: sl(),
      registerPushToken: sl(),
      deleteSubscription: sl(),
      sendTestNotification: sl(),
      getUserId: sl(),
    ),
  );
}

void _registerFirmsFeature() {
  sl.registerLazySingleton<FirmsRemoteDataSource>(
    () => FirmsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<FirmsRepository>(
    () => FirmsRepositoryImpl(remote: sl(), authLocal: sl()),
  );

  sl.registerLazySingleton(() => GetFirmsUseCase(sl()));

  sl.registerLazySingleton(
    () => FirmsCubit(getFirmsUseCase: sl(), prefs: sl()),
  );
}

void _registerClientsFeature() {
  sl.registerLazySingleton<IClientsRemoteDataSource>(
    () => ClientsRemoteDataSourceImpl(
      httpClient: kIsWeb ? sl<http.Client>() : null,
      dio: kIsWeb ? null : sl<Dio>(),
    ),
  );

  sl.registerLazySingleton<IClientsRepository>(
    () => ClientsRepositoryImpl(remote: sl(), localAuth: sl()),
  );

  sl.registerLazySingleton(() => GetClientsUseCase(sl()));
  sl.registerLazySingleton(() => GetClientVersionsUseCase(sl()));

  sl.registerFactory(() => ClientsCubit(getClientsUseCase: sl()));
  sl.registerFactory(
    () => ClientVersionsCubit(getClientVersionsUseCase: sl()),
  );
}

void _registerEmployeesFeature() {
  sl.registerLazySingleton<EmployeesRemoteDataSource>(
    () => EmployeesRemoteDataSourceImpl(
      httpClient: kIsWeb ? sl<http.Client>() : null,
      dio: kIsWeb ? null : sl<Dio>(),
    ),
  );

  sl.registerLazySingleton<EmployeesRepository>(
    () => EmployeesRepositoryImpl(remote: sl(), authLocal: sl()),
  );

  sl.registerLazySingleton(() => GetEmployeesUseCase(sl()));

  sl.registerFactory(() => EmployeesCubit(getEmployeesUseCase: sl()));
}

void _registerTasksFeature() {
  sl.registerLazySingleton<TasksRemoteDataSource>(
    () => TasksRemoteDataSourceImpl(
      client: sl(),
      getToken: () => sl<SharedPreferences>().getString('access_token'),
    ),
  );

  sl.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetTaskUseCase(sl()));
  sl.registerLazySingleton(() => SaveTaskUseCase(sl()));

  sl.registerFactory(
    () => TasksCubit(
      getTasksUseCase: sl(),
      getTaskUseCase: sl(),
      saveTaskUseCase: sl(),
    ),
  );
}

void _registerNotificationsFeature() {
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsDeliveredUseCase(sl()));

  sl.registerLazySingleton(
    () => NotificationsCubit(
      getNotifications: sl(),
      markAsDelivered: sl(),
      authCubit: sl(),
    ),
  );
}

void _registerCommentsFeature() {
  sl.registerFactory(
    () => CommentsCubit(
      getCommentsUseCase: sl(),
      createCommentUseCase: sl(),
      updateCommentUseCase: sl(),
      deleteCommentUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));
  sl.registerLazySingleton(() => CreateCommentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));

  sl.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(
      remoteDataSource: sl(),
      localAuth: sl(),
    ),
  );

  sl.registerLazySingleton<CommentsRemoteDataSource>(
    () => CommentsRemoteDataSourceImpl(dio: sl()),
  );
}

void _registerTariffsAndStorageFeature() {
  sl.registerLazySingleton<ITariffsAndStorageRemoteDataSource>(
    () => TariffsAndStorageRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<IFileDownloadRemoteDataSource>(
    () => FileDownloadRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<IFileSaveLocalDataSource>(
    () => FileSaveLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<ITariffsAndStorageRepository>(
    () => TariffsAndStorageRepositoryImpl(
      remoteDataSource: sl(),
      fileDownloadRemoteDataSource: sl(),
      fileSaveLocalDataSource: sl(),
      localAuth: sl(),
    ),
  );

  sl.registerLazySingleton(() => DownloadFileUseCase(sl()));
  sl.registerLazySingleton(() => DownloadAndSaveFileUseCase(sl()));

  sl.registerFactory(
    () => TariffsAndStorageCubit(downloadFileUseCase: sl()),
  );

  sl.registerLazySingleton(
    () => FileDownloadCubit(downloadAndSaveFileUseCase: sl()),
  );
}

