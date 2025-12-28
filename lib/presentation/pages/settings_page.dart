import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/widgets/rustore_notifications_panel.dart';
import 'package:balansoved_mobile/router.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Аккаунт',
            initiallyExpanded: true,
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AuthAuthenticated) {
                  final user = state.user;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'Email', value: user.email ?? '—'),
                      _InfoRow(label: 'Имя', value: user.userName ?? '—'),
                      _InfoRow(label: 'User ID', value: user.id),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await context.read<AuthCubit>().signOut();
                          if (context.mounted) {
                            context.router.replaceAll(
                              const [UnauthorizedRoute()],
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Выйти'),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Вы не авторизованы'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.router.replaceAll(
                        const [UnauthorizedRoute()],
                      ),
                      child: const Text('Перейти к входу'),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const _SettingsSection(
            title: 'Уведомления',
            child: RustoreNotificationsPanel(),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _SettingsSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 0),
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
