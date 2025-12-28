import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/auth/domain/entities/user_entity.dart';

class UserDisplayWidget extends StatelessWidget {
  final UserEntity user;
  const UserDisplayWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              (user.userName ?? user.email ?? '?')
                  .substring(0, 1)
                  .toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            user.userName ?? user.email ?? 'Пользователь',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}


