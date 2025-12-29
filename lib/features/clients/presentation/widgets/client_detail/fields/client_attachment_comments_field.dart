import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientAttachmentCommentsField extends StatelessWidget {
  final String? comments;

  const ClientAttachmentCommentsField({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final value = comments?.trim() ?? '';
    final hasText = value.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;

    return OfficeFieldFrame(
      label: 'Комментарии к вложению',
      watermarkIcon: Icons.chat_bubble_outline,
      accentColor: accent,
      decorationVariant: OfficeFieldFrameDecorationVariant.note,
      child: Text(
        hasText ? value : 'Комментариев нет',
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
