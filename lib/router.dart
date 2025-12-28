import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/features/auth/presentation/pages/accept_invitation_page.dart';
import 'package:balansoved_mobile/features/auth/presentation/pages/confirm_registration_page.dart';
import 'package:balansoved_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:balansoved_mobile/features/auth/presentation/pages/password_reset_page.dart';
import 'package:balansoved_mobile/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:balansoved_mobile/features/clients/presentation/pages/client_detail_page.dart';
import 'package:balansoved_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/pages/rustore_notifications_page.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:balansoved_mobile/presentation/pages/home_page.dart';
import 'package:balansoved_mobile/presentation/pages/settings_page.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter with WidgetsBindingObserver {
  AppRouter() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      sl<AuthCubit>().checkAuth();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: UnauthorizedRoute.page, path: '/unauthorized'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: PasswordResetRoute.page, path: '/password-reset'),
    AutoRoute(
      page: AcceptInvitationRoute.page,
      path: '/accept-invitation/:invitationKey?',
    ),
    AutoRoute(
      page: ConfirmRegistrationRoute.page,
      path: '/confirm-registration/:email',
    ),
    AutoRoute(
      page: HomeRoute.page,
      path: '/home',
      initial: true,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: SettingsRoute.page,
      path: '/settings',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: NotificationsRoute.page,
      path: '/notifications',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ClientDetailRoute.page,
      path: '/clients/detail',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: TaskDetailRoute.page,
      path: '/tasks/detail',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: RustoreNotificationsRoute.page,
      path: '/rustore-notifications',
      guards: [AuthGuard()],
    ),
    RedirectRoute(path: '*', redirectTo: '/unauthorized'),
  ];
}

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authCubit = sl<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is AuthAuthenticated) {
      resolver.next(true);
    } else if (currentState is AuthUnauthenticated ||
        currentState is AuthError) {
      authCubit.checkAuth();
      resolver.redirectUntil(const UnauthorizedRoute());
    } else {
      authCubit.checkAuth();
      resolver.redirectUntil(const UnauthorizedRoute());
    }
  }
}

