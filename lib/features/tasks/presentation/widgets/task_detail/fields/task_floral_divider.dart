import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskFloralDivider extends StatelessWidget {
  const TaskFloralDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = TaskStyles.dividerColor(colorScheme).withValues(
      alpha: 0.55,
    );
    final iconColor = TaskStyles.accentForegroundColor(
      colorScheme,
    ).withValues(alpha: 0.5);

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Icon(Icons.local_florist_outlined, size: 16, color: iconColor).padding(
          horizontal: 10,
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }
}

