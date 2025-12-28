import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskDescriptionField extends StatelessWidget {
  final String description;

  const TaskDescriptionField({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = TaskStyles.accentForegroundColor(colorScheme);
    final hasText = description.trim().isNotEmpty;

    return OfficeFieldFrame(
      label: 'Описание',
      watermarkIcon: Icons.note_alt_outlined,
      accentColor: accent,
      decorationVariant: OfficeFieldFrameDecorationVariant.note,
      child: Text(
        hasText ? description : 'Описание не заполнено',
        style: TextStyle(
          color:
              hasText
                  ? TaskStyles.textBody(colorScheme)
                  : TaskStyles.textMuted(colorScheme),
          fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }
}
