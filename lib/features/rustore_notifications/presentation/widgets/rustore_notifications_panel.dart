import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/cubit/rustore_notifications_cubit.dart';

class RustoreNotificationsPanel extends StatefulWidget {
  const RustoreNotificationsPanel({super.key});

  @override
  State<RustoreNotificationsPanel> createState() =>
      _RustoreNotificationsPanelState();
}

class _RustoreNotificationsPanelState extends State<RustoreNotificationsPanel> {
  @override
  void initState() {
    super.initState();
    context.read<RustoreNotificationsCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RustoreNotificationsCubit, RustoreNotificationsState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(context, state),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.isTokenRegistered
                  ? context
                      .read<RustoreNotificationsCubit>()
                      .deleteTokenAndSubscription
                  : null,
              child: const Text('Удалить токен (и подписку)'),
            ),
            const SizedBox(height: 8),
            if (!state.isTokenRegistered) ...[
              ElevatedButton(
                onPressed: state.status == RustoreAuthStatus.authenticated
                    ? context
                        .read<RustoreNotificationsCubit>()
                        .requestNewToken
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                child: const Text('Создать токен / подписку'),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: state.status == RustoreAuthStatus.authenticated &&
                      state.isTokenRegistered
                  ? context.read<RustoreNotificationsCubit>().sendTestPush
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Отправить тестовый PUSH (через бэкенд)'),
            ),
            const Divider(height: 32),
            Text(
              'Логи операций:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: scheme.surfaceContainerHighest,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.logs.length,
                itemBuilder: (context, index) {
                  return Text(
                    state.logs[index],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    RustoreNotificationsState state,
  ) {
    final info = _statusInfo(state);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final backgroundColor = info.background(theme);
    final foregroundColor = info.foreground(theme);
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foregroundColor),
          child: IconTheme.merge(
            data: IconThemeData(color: foregroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(info.icon),
                    const SizedBox(width: 8),
                    Text(
                      info.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(info.subtitle),
                if (state.pushToken.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Push Token: ...${_tail(state.pushToken)}'),
                ],
                if (state.isLoading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusInfo _statusInfo(RustoreNotificationsState state) {
    // Цвета делаем theme-aware через ColorScheme контейнеры,
    // чтобы в dark theme не было "белое на светлом".
    switch (state.status) {
      case RustoreAuthStatus.authenticated:
        return _StatusInfo(
          Icons.gpp_good,
          'Авторизован',
          'User ID: ${state.userId ?? '-'}',
          _StatusColor.primaryContainer,
        );
      case RustoreAuthStatus.authenticating:
        return _StatusInfo(
          Icons.sync,
          'Авторизация...',
          'Пожалуйста, подождите',
          _StatusColor.secondaryContainer,
        );
      case RustoreAuthStatus.error:
        return _StatusInfo(
          Icons.error,
          'Ошибка авторизации',
          'Проверьте логи и конфигурацию',
          _StatusColor.errorContainer,
        );
      case RustoreAuthStatus.unauthenticated:
        return _StatusInfo(
          Icons.gpp_bad,
          'Не авторизован',
          'Подписка недоступна без входа',
          _StatusColor.tertiaryContainer,
        );
    }
  }

  String _tail(String token) {
    if (token.length <= 15) return token;
    return token.substring(token.length - 15);
  }
}

class _StatusInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  final _StatusColor color;

  const _StatusInfo(this.icon, this.title, this.subtitle, this.color);

  Color background(ThemeData theme) {
    final scheme = theme.colorScheme;
    return switch (color) {
      _StatusColor.primaryContainer => scheme.primaryContainer,
      _StatusColor.secondaryContainer => scheme.secondaryContainer,
      _StatusColor.tertiaryContainer => scheme.tertiaryContainer,
      _StatusColor.errorContainer => scheme.errorContainer,
    };
  }

  Color foreground(ThemeData theme) {
    final scheme = theme.colorScheme;
    return switch (color) {
      _StatusColor.primaryContainer => scheme.onPrimaryContainer,
      _StatusColor.secondaryContainer => scheme.onSecondaryContainer,
      _StatusColor.tertiaryContainer => scheme.onTertiaryContainer,
      _StatusColor.errorContainer => scheme.onErrorContainer,
    };
  }
}

enum _StatusColor {
  primaryContainer,
  secondaryContainer,
  tertiaryContainer,
  errorContainer,
}
