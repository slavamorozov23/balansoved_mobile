import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/comments/presentation/widgets/comments_section.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_detail_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDetailCard extends StatelessWidget {
  final TaskEntity task;
  final List<EmployeeEntity> employees;
  final List<ClientEntity> clients;
  final bool clientsLoading;
  final double? viewportHeight;

  const TaskDetailCard({
    super.key,
    required this.task,
    required this.employees,
    required this.clients,
    this.clientsLoading = false,
    this.viewportHeight,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFirmId = context.read<FirmsCubit>().state.selectedFirm?.id;

    final description = task.description?.trim() ?? '';

    final taskInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskTitleField(title: task.title),
        const SizedBox(height: 12),
        const TaskFloralDivider(),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: TaskStatusField(task: task)),
              const SizedBox(width: 12),
              Expanded(child: TaskPriorityField(priority: task.priority)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const TaskFloralDivider(),
        const SizedBox(height: 12),
        TaskClientsField(
          clientIds: task.clientIds,
          clients: clients,
          clientsLoading: clientsLoading,
        ),
        const SizedBox(height: 12),
        TaskAssigneesField(assigneeIds: task.assigneeIds, employees: employees),
        const SizedBox(height: 12),
        TaskObserversField(observerIds: task.observerIds, employees: employees),
        const SizedBox(height: 12),
        TaskCreatorsField(creatorIds: task.creatorIds, employees: employees),
        const SizedBox(height: 12),
        const TaskFloralDivider(),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: TaskDueDateField(date: task.dueDate)),
              const SizedBox(width: 12),
              Expanded(child: TaskCompletedAtField(date: task.completedAt)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const TaskFloralDivider(),
        const SizedBox(height: 12),
        TaskAttachmentsField(attachments: task.attachments),
        const SizedBox(height: 12),
        TaskChecklistsField(task: task),
        const SizedBox(height: 12),
        TaskRemindersField(reminders: task.reminders),
        const SizedBox(height: 12),
        const TaskFloralDivider(),
        const SizedBox(height: 12),
        TaskDescriptionField(description: description),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        taskInfo,
        const SizedBox(height: 16),
        if (selectedFirmId != null)
          _CommentsSectionSpacer(
            firmId: selectedFirmId,
            taskId: task.id,
            viewportHeight: viewportHeight,
          ),
      ],
    );
  }
}

class _CommentsSectionSpacer extends StatefulWidget {
  final String firmId;
  final String taskId;
  final double? viewportHeight;

  const _CommentsSectionSpacer({
    required this.firmId,
    required this.taskId,
    this.viewportHeight,
  });

  @override
  State<_CommentsSectionSpacer> createState() => _CommentsSectionSpacerState();
}

class _CommentsSectionSpacerState extends State<_CommentsSectionSpacer> {
  final GlobalKey _sectionKey = GlobalKey();
  double _sectionHeight = 0;

  @override
  void initState() {
    super.initState();
    _scheduleMeasure();
  }

  @override
  void didUpdateWidget(covariant _CommentsSectionSpacer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskId != widget.taskId ||
        oldWidget.viewportHeight != widget.viewportHeight) {
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _sectionKey.currentContext;
      if (context == null) return;
      final size = context.size;
      if (size == null) return;
      if (size.height != _sectionHeight) {
        setState(() => _sectionHeight = size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewport =
        widget.viewportHeight ?? MediaQuery.of(context).size.height;
    final spacerHeight =
        _sectionHeight > 0 ? (viewport - _sectionHeight) : 0.0;
    final adjustedSpacer = spacerHeight > 0 ? spacerHeight : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (_) {
            _scheduleMeasure();
            return false;
          },
          child: SizeChangedLayoutNotifier(
            child: KeyedSubtree(
              key: _sectionKey,
              child: CommentsSection(
                firmId: widget.firmId,
                taskId: widget.taskId,
              ),
            ),
          ),
        ),
        if (adjustedSpacer > 0) SizedBox(height: adjustedSpacer),
      ],
    );
  }
}
