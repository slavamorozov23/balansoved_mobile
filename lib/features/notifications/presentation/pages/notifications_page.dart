import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:balansoved_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:balansoved_mobile/features/notifications/presentation/widgets/notification_item.dart';
import 'package:balansoved_mobile/features/tasks/domain/usecases/get_task_usecase.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:balansoved_mobile/presentation/widgets/loading_tile.dart';
import 'package:balansoved_mobile/router.dart';

@RoutePage()
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Set<String> _openingTaskIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationsCubit>().loadNotifications(refresh: true);
    });
  }

  Future<void> _openTask(NotificationEntity notification) async {
    final taskId = _extractTaskId(notification);
    if (taskId == null) return;

    final firmId = _resolveFirmId(notification);
    if (firmId == null) {
      _showSnack('Сначала выберите фирму');
      return;
    }

    setState(() => _openingTaskIds.add(taskId));
    _showLoadingDialog();

    final result = await sl<GetTaskUseCase>()(firmId, taskId, onlyMy: false);

    if (!mounted) return;
    Navigator.of(context).maybePop();
    setState(() => _openingTaskIds.remove(taskId));

    result.fold(
      (failure) => _showSnack(failure.message),
      (task) => context.router.push(TaskDetailRoute(task: task)),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showLoadingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  String? _extractTaskId(NotificationEntity notification) {
    final additionalInfo = notification.additionalInfo;
    if (additionalInfo == null) return null;
    final dynamic value =
        additionalInfo['task_id'] ?? additionalInfo['taskId'];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  String? _resolveFirmId(NotificationEntity notification) {
    final additionalInfo = notification.additionalInfo;
    if (additionalInfo != null) {
      final dynamic firmValue =
          additionalInfo['firm_id'] ?? additionalInfo['firmId'];
      if (firmValue is String && firmValue.isNotEmpty) {
        return firmValue;
      }
    }
    return context.read<FirmsCubit>().state.selectedFirm?.id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingTile(height: 60, maxWidth: 350),
                  SizedBox(height: 8),
                  LoadingTile(height: 60, maxWidth: 350),
                  SizedBox(height: 8),
                  LoadingTile(height: 60, maxWidth: 350),
                ],
              ),
            );
          }

          if (state is NotificationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки уведомлений',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<NotificationsCubit>()
                            .loadNotifications(refresh: true);
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationsLoaded || state is NotificationsLoadingMore) {
            final unread =
                state is NotificationsLoaded
                    ? state.unreadNotifications
                    : (state as NotificationsLoadingMore).unreadNotifications;

            if (unread.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет уведомлений',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            final hasMore =
                context.read<NotificationsCubit>().hasMoreNotifications;

            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<NotificationsCubit>()
                    .loadNotifications(refresh: true);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: unread.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (hasMore && index >= unread.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child:
                            state is NotificationsLoadingMore
                                ? const LoadingTile(
                                  height: 40,
                                  maxWidth: double.infinity,
                                )
                                : ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<NotificationsCubit>()
                                        .loadMoreNotifications();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    foregroundColor:
                                        colorScheme.onPrimaryContainer,
                                  ),
                                  child: const Text('Получить ещё'),
                                ),
                      ),
                    );
                  }

                  final notification = unread[index];
                  final taskId = _extractTaskId(notification);
                  final isOpening =
                      taskId != null && _openingTaskIds.contains(taskId);
                  return NotificationItem(
                    notification: notification,
                    isOpeningTask: isOpening,
                    onOpenTask:
                        taskId == null ? null : () => _openTask(notification),
                    onMarkAsDelivered: () {
                      context
                          .read<NotificationsCubit>()
                          .markNotificationsAsDelivered([notification.id]);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
