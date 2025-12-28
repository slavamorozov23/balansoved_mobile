import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:balansoved_mobile/injection_container.dart' as di;
import 'package:balansoved_mobile/injection_container.dart';
import 'package:balansoved_mobile/router.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/cubit/rustore_notifications_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_chrome_cubit.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.setupLocator();

    if (kDebugMode) {
      sl<Talker>().log('[MAIN] Starting app');
    }

    Bloc.observer = TalkerBlocObserver(
      talker: GetIt.I<Talker>(),
      settings: const TalkerBlocLoggerSettings(
        printStateFullData: false,
        printEventFullData: false,
      ),
    );

    runApp(const MainApp());
  }, (e, st) => GetIt.I<Talker>().handle(e, st));

  FlutterError.onError =
      (details) => GetIt.I<Talker>().handle(details.exception, details.stack);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GetIt.I<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: di.sl<AuthCubit>()..checkAuth()),
        BlocProvider<ClientsCubit>.value(value: di.sl<ClientsCubit>()),
        BlocProvider<EmployeesCubit>.value(value: di.sl<EmployeesCubit>()),
        BlocProvider<FirmsCubit>.value(value: di.sl<FirmsCubit>()),
        BlocProvider<TasksCubit>.value(value: di.sl<TasksCubit>()),
        BlocProvider<TasksChromeCubit>(create: (_) => TasksChromeCubit()),
        BlocProvider<NotificationsCubit>.value(
          value: di.sl<NotificationsCubit>(),
        ),
        BlocProvider<RustoreNotificationsCubit>(
          create: (_) => di.sl<RustoreNotificationsCubit>(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Balansoved',
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4513),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4513),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: router.config(
          navigatorObservers: () => [TalkerRouteObserver(di.sl())],
        ),
      ),
    );
  }
}

