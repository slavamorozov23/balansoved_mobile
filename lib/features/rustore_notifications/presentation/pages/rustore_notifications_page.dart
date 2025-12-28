import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/cubit/rustore_notifications_cubit.dart';
import 'package:balansoved_mobile/features/rustore_notifications/presentation/widgets/rustore_notifications_panel.dart';

@RoutePage()
class RustoreNotificationsPage extends StatelessWidget {
  const RustoreNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RuStore Push подписки')),
      body: RefreshIndicator(
        onRefresh: () => context.read<RustoreNotificationsCubit>().refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [RustoreNotificationsPanel()],
        ),
      ),
    );
  }
}

