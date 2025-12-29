import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientOnServiceField extends StatelessWidget {
  final bool onService;

  const ClientOnServiceField({super.key, required this.onService});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        onService ? Colors.green.shade700 : TaskStyles.textMuted(colorScheme);
    final statusIcon =
        onService ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final statusColor = onService ? Colors.green.shade600 : colorScheme.error;

    return OfficeFieldFrame(
      label: 'На обслуживании',
      watermarkIcon: Icons.support_agent_outlined,
      accentColor: accent,
      dense: true,
      child: Icon(statusIcon, size: 16, color: statusColor),
    );
  }
}
