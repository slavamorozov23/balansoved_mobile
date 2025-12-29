import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import 'package:balansoved_mobile/features/tariffs_and_storage/presentation/cubit/file_download_cubit.dart';

class ClientAttachmentsField extends StatefulWidget {
  final List<Map<String, dynamic>> attachments;

  const ClientAttachmentsField({super.key, required this.attachments});

  @override
  State<ClientAttachmentsField> createState() => _ClientAttachmentsFieldState();
}

class _ClientAttachmentsFieldState extends State<ClientAttachmentsField> {
  final Set<String> _loadingIds = {};
  String? _completedId;
  bool _expanded = false;
  Timer? _completedTimer;

  @override
  void dispose() {
    _completedTimer?.cancel();
    super.dispose();
  }

  void _markCompleted(String id) {
    _completedTimer?.cancel();
    setState(() => _completedId = id);
    _completedTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _completedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;
    final attachments = widget.attachments;
    final count = attachments.length;
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );
    final visible =
        _expanded || count <= 3 ? attachments : attachments.take(3).toList();

    return OfficeFieldFrame(
      label: 'Файловые вложения',
      watermarkIcon: Icons.attach_file_outlined,
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (count > 0)
            ...[
              for (final item in visible)
                _buildAttachmentLine(item, accent, valueStyle),
              if (!_expanded && count > 3)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = true),
                  child: Text(
                    'и ещё ${count - 3}',
                    style: TextStyle(
                      color: TaskStyles.textMuted(colorScheme),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ]
          else
            const OfficeEmptyValue(),
        ],
      ),
    );
  }

  Widget _buildAttachmentLine(
    Map<String, dynamic> item,
    Color accent,
    TextStyle valueStyle,
  ) {
    final label = _attachmentLabel(item);
    final fileKey = _attachmentFileKey(item);
    final trackingId = fileKey ?? label;
    final isLoading = _loadingIds.contains(trackingId);
    final isCompleted = _completedId == trackingId;

    Widget leading;
    if (isLoading) {
      leading = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: accent.withValues(alpha: 0.85),
        ),
      );
    } else if (isCompleted) {
      leading = Icon(
        Icons.check_circle,
        size: 16,
        color: accent.withValues(alpha: 0.9),
      );
    } else {
      leading = Icon(
        Icons.insert_drive_file_outlined,
        size: 16,
        color: accent.withValues(alpha: 0.8),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          isLoading
              ? null
              : () {
                if (fileKey == null) {
                  _showSnack(context, 'Не найден ключ файла');
                  return;
                }
                final firmId =
                    context.read<FirmsCubit>().state.selectedFirm?.id;
                if (firmId == null) {
                  _showSnack(context, 'Фирма не выбрана');
                  return;
                }
                setState(() => _loadingIds.add(trackingId));
                context
                    .read<FileDownloadCubit>()
                    .downloadFile(
                      firmId: firmId,
                      fileKey: fileKey,
                      fileName: label,
                    )
                    .then((result) {
                      if (!mounted) return;
                      setState(() => _loadingIds.remove(trackingId));
                      if (result != null) {
                        _markCompleted(trackingId);
                      } else {
                        _showSnack(context, 'Не удалось скачать файл');
                      }
                    });
              },
      child: OfficeBulletLine(
        icon: Icons.insert_drive_file_outlined,
        accentColor: accent,
        text: label,
        textStyle: valueStyle,
        leading: leading,
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

String? _attachmentFileKey(Map<String, dynamic> item) {
  const keys = [
    'fileKey',
    'file_key',
    'filekey',
    'key',
    'storage_key',
    's3_key',
  ];
  for (final key in keys) {
    final value = item[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
