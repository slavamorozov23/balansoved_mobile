import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskChecklistsField extends StatefulWidget {
  final TaskEntity task;

  const TaskChecklistsField({super.key, required this.task});

  @override
  State<TaskChecklistsField> createState() => _TaskChecklistsFieldState();
}

class _TaskChecklistsFieldState extends State<TaskChecklistsField> {
  late List<Map<String, dynamic>> _checklist;
  late List<Map<String, dynamic>> _originalChecklist;
  bool _saving = false;
  bool _pendingSave = false;
  Timer? _saveTimer;
  DateTime? _lastChangeAt;
  bool _disposed = false;

  late FirmsCubit _firmsCubit;
  late TasksCubit _tasksCubit;

  @override
  void initState() {
    super.initState();
    _syncChecklist();
  }

  @override
  void didUpdateWidget(covariant TaskChecklistsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _syncChecklist();
    } else if (!_isDirty()) {
      _syncChecklist();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firmsCubit = context.read<FirmsCubit>();
    _tasksCubit = context.read<TasksCubit>();
  }

  @override
  void dispose() {
    _disposed = true;
    _saveTimer?.cancel();

    final firmId = _firmsCubit.state.selectedFirm?.id;
    if (firmId != null && _isDirty()) {
      final delay = _debounceDelay();
      final checklistSnapshot = _cloneChecklist(_checklist);
      final taskSnapshot = widget.task;
      final tasksCubitSnapshot = _tasksCubit;

      unawaited(
        _saveSnapshotAfterDelay(
          delay: delay,
          firmId: firmId,
          task: taskSnapshot,
          checklist: checklistSnapshot,
          tasksCubit: tasksCubitSnapshot,
        ),
      );
    }
    super.dispose();
  }

  void _syncChecklist() {
    _originalChecklist = _cloneChecklist(widget.task.checklist);
    _checklist = _cloneChecklist(_originalChecklist);
  }

  bool _isDirty() {
    if (_checklist.length != _originalChecklist.length) return true;
    for (var i = 0; i < _checklist.length; i++) {
      final local = _isDone(_checklist[i]);
      final original = _isDone(_originalChecklist[i]);
      if (local != original) return true;
    }
    return false;
  }

  Future<void> _toggleItem(int index) async {
    setState(() {
      final current = _isDone(_checklist[index]);
      _setDone(_checklist[index], !current);
    });
    _lastChangeAt = DateTime.now();
    _scheduleSave();
  }

  void _scheduleSave() {
    if (_disposed) return;
    _saveTimer?.cancel();
    final delay = _debounceDelay();
    _saveTimer = Timer(delay, () {
      _runSave();
    });
  }

  Duration _debounceDelay() {
    const minDelay = Duration(seconds: 3);
    final lastChange = _lastChangeAt;
    if (lastChange == null) return minDelay;
    final elapsed = DateTime.now().difference(lastChange);
    final remaining = minDelay - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> _runSave() async {
    if (!_isDirty()) {
      _pendingSave = false;
      return;
    }
    if (_saving) {
      _pendingSave = true;
      return;
    }

    final ok = await _saveChecklistImmediate();

    if (_disposed) return;

    if (ok && (_pendingSave || _isDirty())) {
      _pendingSave = false;
      _scheduleSave();
    }
  }

  Future<bool> _saveChecklistImmediate({bool silent = false}) async {
    if (!_isDirty()) return true;

    if (!silent && mounted) {
      setState(() => _saving = true);
    } else {
      _saving = true;
    }

    final firmId = _firmsCubit.state.selectedFirm?.id;
    if (firmId == null) {
      if (!silent && mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фирма не выбрана')),
        );
      } else {
        _saving = false;
      }
      return false;
    }

    final checklistPayload = _cloneChecklist(_checklist);
    final updatedTask = widget.task.copyWith(
      checklist: checklistPayload,
      updatedAt: DateTime.now(),
    );

    final ok = await _tasksCubit.saveTask(firmId, updatedTask);

    if (!silent && mounted) {
      if (ok) {
        _originalChecklist = _cloneChecklist(checklistPayload);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить чек-лист'),
          ),
        );
      }
      setState(() => _saving = false);
    } else {
      if (ok) {
        _originalChecklist = _cloneChecklist(checklistPayload);
      }
      _saving = false;
    }

    return ok;
  }

  static Future<void> _saveSnapshotAfterDelay({
    required Duration delay,
    required String firmId,
    required TaskEntity task,
    required List<Map<String, dynamic>> checklist,
    required TasksCubit tasksCubit,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    await tasksCubit.saveTask(
      firmId,
      task.copyWith(checklist: _cloneChecklist(checklist), updatedAt: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final count = _checklist.length;

    final headlineStyle = TextStyle(
      fontWeight: FontWeight.w800,
      color: TaskStyles.textPrimary(colorScheme),
    );

    return OfficeFieldFrame(
      label: 'Чек-листы',
      watermarkIcon: Icons.checklist_outlined,
      accentColor: accent,
      decorationVariant: OfficeFieldFrameDecorationVariant.note,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  count > 0 ? 'Пунктов: $count' : 'Чек-лист пустой',
                  style: headlineStyle,
                ),
              ),
              if (_saving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (count > 0) ...[
            const SizedBox(height: 10),
            for (final entry in _checklist.asMap().entries)
              _ChecklistLine(
                item: entry.value,
                accentColor: accent,
                onToggle: () => _toggleItem(entry.key),
              ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistLine extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color accentColor;
  final VoidCallback onToggle;

  const _ChecklistLine({
    required this.item,
    required this.accentColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final done = _isDone(item);
    final title = _firstString(item, const [
      'title',
      'text',
      'name',
      'label',
      'caption',
    ]);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_box_outlined : Icons.check_box_outline_blank,
            size: 20,
            color: done ? accentColor : TaskStyles.textMuted(colorScheme),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title ?? 'Пункт чек-листа',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: TaskStyles.textBody(colorScheme),
                height: 1.35,
              ),
            ),
          ),
        ],
      ).padding(bottom: 8, top: 2),
    );
  }
}

List<Map<String, dynamic>> _cloneChecklist(List<Map<String, dynamic>> source) {
  return source.map((e) => Map<String, dynamic>.from(e)).toList();
}

bool _isDone(Map<String, dynamic> item) {
  for (final key in _doneKeys) {
    if (item.containsKey(key)) {
      return _asBool(item[key]) ?? false;
    }
  }
  return _asBool(item['completed']) ?? false;
}

void _setDone(Map<String, dynamic> item, bool value) {
  var updated = false;
  for (final key in _doneKeys) {
    if (item.containsKey(key)) {
      item[key] = value;
      updated = true;
    }
  }
  if (!updated) {
    item['completed'] = value;
  }
}

const List<String> _doneKeys = [
  'completed',
  'done',
  'is_done',
  'checked',
  'isChecked',
  'is_checked',
];

bool? _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
  }
  return null;
}

String? _firstString(Map<String, dynamic> item, List<String> keys) {
  for (final k in keys) {
    final v = item[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}
