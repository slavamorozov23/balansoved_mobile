import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:balansoved_mobile/router.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final isLoading =
            state is NotificationsLoading || state is NotificationsInitial;
        int undeliveredCount = 0;
        if (state is NotificationsLoaded) {
          undeliveredCount = state.undeliveredCount;
        } else if (state is NotificationsLoadingMore) {
          undeliveredCount = state.undeliveredCount;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              IconButton(
                onPressed:
                    isLoading
                        ? null
                        : () => context.router.push(
                          const NotificationsRoute(),
                        ),
                icon:
                    isLoading
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                        : Icon(
                          Icons.notifications_outlined,
                          color: colorScheme.onSurface,
                          size: 24,
                        ),
                tooltip: isLoading ? 'Загрузка' : 'Уведомления',
              ),
              if (!isLoading && undeliveredCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      undeliveredCount >= 100
                          ? '99+'
                          : undeliveredCount.toString(),
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
