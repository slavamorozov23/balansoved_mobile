import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class StatusDropdownCell extends StatefulWidget {
  final TaskEntity task;

  const StatusDropdownCell({super.key, required this.task});

  @override
  State<StatusDropdownCell> createState() => _StatusDropdownCellState();
}

class _StatusDropdownCellState extends State<StatusDropdownCell> {
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
  void didUpdateWidget(covariant StatusDropdownCell oldWidget) {
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
        const SnackBar(content: Text('Не удалось обновить статус')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = TaskStyles.getStatusColor(
      _currentStatus,
      theme.colorScheme,
    );

    final label = _statuses[_currentStatus] ?? _currentStatus;

    final content =
        _isUpdating
            ? Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
            : PopupMenuButton<String>(
              initialValue: _currentStatus,
              padding: EdgeInsets.zero,
              onSelected: _changeStatus,
              itemBuilder:
                  (context) =>
                      _statuses.entries
                          .map(
                            (entry) => PopupMenuItem<String>(
                              value: entry.key,
                              height: 36,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 18, color: theme.hintColor),
                ],
              ),
            );

    return SizedBox(width: 140, child: content);
  }
}
