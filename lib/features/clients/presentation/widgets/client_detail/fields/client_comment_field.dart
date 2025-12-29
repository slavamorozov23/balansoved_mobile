import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientCommentField extends StatelessWidget {
  final String? comment;

  const ClientCommentField({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final value = comment?.trim() ?? '';
    final hasText = value.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = TaskStyles.accentForegroundColor(colorScheme);

    return OfficeFieldFrame(
      label: 'Комментарий',
      watermarkIcon: Icons.note_alt_outlined,
      accentColor: accent,
      decorationVariant: OfficeFieldFrameDecorationVariant.note,
      child: Text(
        hasText ? value : 'Комментарий не заполнен',
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

