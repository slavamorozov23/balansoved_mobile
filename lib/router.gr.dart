// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AcceptInvitationPage]
class AcceptInvitationRoute extends PageRouteInfo<AcceptInvitationRouteArgs> {
  AcceptInvitationRoute({
    Key? key,
    String? invitationKey,
    List<PageRouteInfo>? children,
  }) : super(
         AcceptInvitationRoute.name,
         args: AcceptInvitationRouteArgs(
           key: key,
           invitationKey: invitationKey,
         ),
         rawPathParams: {'invitationKey': invitationKey},
         initialChildren: children,
       );

  static const String name = 'AcceptInvitationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AcceptInvitationRouteArgs>(
        orElse: () => AcceptInvitationRouteArgs(
          invitationKey: pathParams.optString('invitationKey'),
        ),
      );
      return AcceptInvitationPage(
        key: args.key,
        invitationKey: args.invitationKey,
      );
    },
  );
}

class AcceptInvitationRouteArgs {
  const AcceptInvitationRouteArgs({this.key, this.invitationKey});

  final Key? key;

  final String? invitationKey;

  @override
  String toString() {
    return 'AcceptInvitationRouteArgs{key: $key, invitationKey: $invitationKey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AcceptInvitationRouteArgs) return false;
    return key == other.key && invitationKey == other.invitationKey;
  }

  @override
  int get hashCode => key.hashCode ^ invitationKey.hashCode;
}

/// generated route for
/// [ConfirmRegistrationPage]
class ConfirmRegistrationRoute
    extends PageRouteInfo<ConfirmRegistrationRouteArgs> {
  ConfirmRegistrationRoute({
    Key? key,
    required String email,
    List<PageRouteInfo>? children,
  }) : super(
         ConfirmRegistrationRoute.name,
         args: ConfirmRegistrationRouteArgs(key: key, email: email),
         rawPathParams: {'email': email},
         initialChildren: children,
       );

  static const String name = 'ConfirmRegistrationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ConfirmRegistrationRouteArgs>(
        orElse: () =>
            ConfirmRegistrationRouteArgs(email: pathParams.getString('email')),
      );
      return ConfirmRegistrationPage(key: args.key, email: args.email);
    },
  );
}

class ConfirmRegistrationRouteArgs {
  const ConfirmRegistrationRouteArgs({this.key, required this.email});

  final Key? key;

  final String email;

  @override
  String toString() {
    return 'ConfirmRegistrationRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConfirmRegistrationRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [ClientDetailPage]
class ClientDetailRoute extends PageRouteInfo<ClientDetailRouteArgs> {
  ClientDetailRoute({
    Key? key,
    required String clientName,
    List<PageRouteInfo>? children,
  }) : super(
         ClientDetailRoute.name,
         args: ClientDetailRouteArgs(key: key, clientName: clientName),
         initialChildren: children,
       );

  static const String name = 'ClientDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClientDetailRouteArgs>();
      return ClientDetailPage(key: args.key, clientName: args.clientName);
    },
  );
}

class ClientDetailRouteArgs {
  const ClientDetailRouteArgs({this.key, required this.clientName});

  final Key? key;

  final String clientName;

  @override
  String toString() {
    return 'ClientDetailRouteArgs{key: $key, clientName: $clientName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ClientDetailRouteArgs) return false;
    return key == other.key && clientName == other.clientName;
  }

  @override
  int get hashCode => key.hashCode ^ clientName.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [PasswordResetPage]
class PasswordResetRoute extends PageRouteInfo<void> {
  const PasswordResetRoute({List<PageRouteInfo>? children})
    : super(PasswordResetRoute.name, initialChildren: children);

  static const String name = 'PasswordResetRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PasswordResetPage();
    },
  );
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [RustoreNotificationsPage]
class RustoreNotificationsRoute extends PageRouteInfo<void> {
  const RustoreNotificationsRoute({List<PageRouteInfo>? children})
    : super(RustoreNotificationsRoute.name, initialChildren: children);

  static const String name = 'RustoreNotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RustoreNotificationsPage();
    },
  );
}

/// generated route for
/// [TaskDetailPage]
class TaskDetailRoute extends PageRouteInfo<TaskDetailRouteArgs> {
  TaskDetailRoute({
    Key? key,
    required TaskEntity task,
    List<PageRouteInfo>? children,
  }) : super(
         TaskDetailRoute.name,
         args: TaskDetailRouteArgs(key: key, task: task),
         initialChildren: children,
       );

  static const String name = 'TaskDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TaskDetailRouteArgs>();
      return TaskDetailPage(key: args.key, task: args.task);
    },
  );
}

class TaskDetailRouteArgs {
  const TaskDetailRouteArgs({this.key, required this.task});

  final Key? key;

  final TaskEntity task;

  @override
  String toString() {
    return 'TaskDetailRouteArgs{key: $key, task: $task}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TaskDetailRouteArgs) return false;
    return key == other.key && task == other.task;
  }

  @override
  int get hashCode => key.hashCode ^ task.hashCode;
}

/// generated route for
/// [UnauthorizedPage]
class UnauthorizedRoute extends PageRouteInfo<void> {
  const UnauthorizedRoute({List<PageRouteInfo>? children})
    : super(UnauthorizedRoute.name, initialChildren: children);

  static const String name = 'UnauthorizedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UnauthorizedPage();
    },
  );
}
