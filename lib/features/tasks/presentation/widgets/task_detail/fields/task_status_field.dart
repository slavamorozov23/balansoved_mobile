import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table_helpers.dart';

class TaskStatusField extends StatefulWidget {
  final TaskEntity task;

  const TaskStatusField({super.key, required this.task});

  @override
  State<TaskStatusField> createState() => _TaskStatusFieldState();
}

class _TaskStatusFieldState extends State<TaskStatusField> {
  static const Map<String, String> _statuses = {
    'in_progress': 'Активна',
    'completed': 'Завершена',
    'cancelled': 'Отменена',
  };

  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = _normalizeStatus(widget.task.status);
  }

  @override
  void didUpdateWidget(covariant TaskStatusField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.status != widget.task.status) {
      _currentStatus = _normalizeStatus(widget.task.status);
    }
  }

  String _normalizeStatus(String status) {
    if (_statuses.containsKey(status)) return status;
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) {
      return 'cancelled';
    }
    if (lower.contains('complet') || lower.contains('done')) {
      return 'completed';
    }
    if (lower.contains('progress') ||
        lower.contains('ongoing') ||
        lower.contains('todo') ||
        lower.contains('new') ||
        lower.contains('active')) {
      return 'in_progress';
    }
    return 'in_progress';
  }

  String _labelForStatus(String status) {
    return _statuses[status] ?? TasksTableHelpers.translateStatus(status);
  }

  Future<void> _changeStatus(String? newStatus) async {
    if (newStatus == null || newStatus == _currentStatus) return;

    setState(() => _isUpdating = true);

    final firmId = context.read<FirmsCubit>().state.selectedFirm?.id;
    if (firmId == null) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фирма не выбрана')),
        );
      }
      return;
    }

    final ok = await context.read<TasksCubit>().updateTaskStatus(
      firmId,
      widget.task.id,
      newStatus,
    );

    if (!mounted) return;

    setState(() {
      _isUpdating = false;
      if (ok) {
        _currentStatus = newStatus;
      }
    });

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить статус задачи'),
        ),
      );
    }
  }

  Widget _buildBadge(Color statusColor, IconData statusIcon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon, color: statusColor, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    )
        .padding(horizontal: 12, vertical: 8)
        .decorated(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        );
  }

  Widget _buildLoadingBadge(Color statusColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    )
        .padding(horizontal: 12, vertical: 8)
        .decorated(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusLabel = _labelForStatus(_currentStatus);
    final statusColor = TaskStyles.getStatusColor(_currentStatus, colorScheme);
    final statusIcon = TaskStyles.getStatusIcon(_currentStatus);

    final badge =
        _isUpdating
            ? _buildLoadingBadge(statusColor, statusLabel)
            : _buildBadge(statusColor, statusIcon, statusLabel);

    return OfficeFieldFrame(
      label: 'Статус',
      watermarkIcon: Icons.verified_outlined,
      accentColor: statusColor,
      child:
          _isUpdating
              ? badge
              : PopupMenuButton<String>(
                initialValue: _currentStatus,
                padding: EdgeInsets.zero,
                onSelected: _changeStatus,
                itemBuilder: (context) {
                  return _statuses.entries
                      .map(
                        (entry) => PopupMenuItem<String>(
                          value: entry.key,
                          height: 36,
                          child: Text(entry.value),
                        ),
                      )
                      .toList();
                },
                child: badge,
              ),
    );
  }
}
