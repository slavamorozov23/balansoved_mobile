import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskAttachmentsField extends StatelessWidget {
  final List<Map<String, dynamic>> attachments;

  const TaskAttachmentsField({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;
    final count = attachments.length;

    final headlineStyle = TextStyle(
      fontWeight: FontWeight.w800,
      color: TaskStyles.textPrimary(colorScheme),
    );

    return OfficeFieldFrame(
      label: 'Вложения',
      watermarkIcon: Icons.attach_file_outlined,
      accentColor: accent,
      decorationVariant: OfficeFieldFrameDecorationVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count > 0 ? 'Всего: $count' : 'Вложений нет', style: headlineStyle),
          if (count > 0) ...[
            const SizedBox(height: 10),
            for (final item in attachments.take(3))
              OfficeBulletLine(
                icon: Icons.insert_drive_file_outlined,
                accentColor: accent,
                text: _attachmentLabel(item),
              ),
            if (count > 3)
              Text(
                'и ещё ${count - 3}',
                style: TextStyle(
                  color: TaskStyles.textMuted(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _attachmentLabel(Map<String, dynamic> item) {
  const keys = ['name', 'file_name', 'filename', 'title', 'url', 'path'];
  for (final k in keys) {
    final v = item[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return 'Файл';
}
