import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';

class TasksFiltersPanel extends StatefulWidget {
  final TaskRequestParams params;
  final List<ClientEntity> clients;
  final bool clientsLoading;
  final ValueChanged<TaskRequestParams> onParamsChanged;

  const TasksFiltersPanel({
    super.key,
    required this.params,
    required this.clients,
    required this.onParamsChanged,
    this.clientsLoading = false,
  });

  @override
  State<TasksFiltersPanel> createState() => _TasksFiltersPanelState();
}

class _TasksFiltersPanelState extends State<TasksFiltersPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _buildViewTypeSwitch()),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: _isExpanded ? 'Свернуть' : 'Развернуть',
                ),
              ],
            ),
          ),
          if (_isExpanded) _buildExpandedBody(context),
        ],
      ),
    );
  }

  Widget _buildViewTypeSwitch() {
    final supportedViewTypes = <TaskViewType>{
      TaskViewType.timeless,
      TaskViewType.dated,
      TaskViewType.all,
    };
    final selectedType =
        supportedViewTypes.contains(widget.params.viewType)
            ? widget.params.viewType
            : TaskViewType.all;

    return DropdownButtonFormField<TaskViewType>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Тип задач',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(
          value: TaskViewType.timeless,
          child: Row(
            children: [
              Icon(Icons.all_inbox, size: 18),
              SizedBox(width: 8),
              Text('Бессрочные'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: TaskViewType.dated,
          child: Row(
            children: [
              Icon(Icons.schedule, size: 18),
              SizedBox(width: 8),
              Text('С крайним сроком'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: TaskViewType.all,
          child: Row(
            children: [
              Icon(Icons.list_alt, size: 18),
              SizedBox(width: 8),
              Text('Общая таблица'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null || value == selectedType) return;
        widget.onParamsChanged(_buildParamsForViewType(value));
      },
    );
  }

  TaskRequestParams _buildParamsForViewType(TaskViewType viewType) {
    final base = widget.params;
    final now = DateTime.now();

    switch (viewType) {
      case TaskViewType.timeless:
        return TaskRequestParams.timeless(
          page: 0,
          clientId: base.clientId,
          status: base.status,
          participants: base.participants,
          participantsMode: base.participantsMode,
          onlyMy: base.onlyMy,
          filterByMonth: base.filterByMonth,
          force: true,
        );
      case TaskViewType.dated:
        return TaskRequestParams.dated(
          month: base.month ?? now.month,
          year: base.year ?? now.year,
          clientId: base.clientId,
          status: base.status,
          participants: base.participants,
          participantsMode: base.participantsMode,
          onlyMy: base.onlyMy,
          filterByMonth: true,
          force: true,
        );
      case TaskViewType.all:
        return TaskRequestParams.all(
          page: 0,
          clientId: base.clientId,
          status: base.status,
          participants: base.participants,
          participantsMode: base.participantsMode,
          onlyMy: base.onlyMy,
          force: true,
        );
      case TaskViewType.timeline:
        return TaskRequestParams.timeline(
          clientId: base.clientId,
          status: base.status,
          participants: base.participants,
          participantsMode: base.participantsMode,
          roleFilter: base.roleFilter ?? 'any',
          force: true,
        );
    }
  }

  Widget _buildExpandedBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClientSelector(context),
          if (widget.params.viewType == TaskViewType.dated) ...[
            const SizedBox(height: 16),
            _buildDatedControls(context),
          ],
        ],
      ),
    );
  }

  Widget _buildClientSelector(BuildContext context) {
    final clientsById = {for (final c in widget.clients) c.id: c};
    final selectedId = widget.params.clientId;

    String labelForClient(ClientEntity client) {
      final inn = (client.inn ?? '').trim();
      return inn.isNotEmpty ? '${client.name} ($inn)' : client.name;
    }

    final selectedLabel = selectedId == null
        ? 'Все клиенты'
        : clientsById.containsKey(selectedId)
        ? labelForClient(clientsById[selectedId]!)
        : 'Клиент: $selectedId';

    return InkWell(
      onTap: widget.clientsLoading
          ? null
          : () async {
              final selected = await _selectClientBottomSheet(
                context,
                clients: widget.clients,
                selectedClientId: selectedId,
              );
              if (!context.mounted) return;
              if (selected == selectedId) return;
              widget.onParamsChanged(
                widget.params.copyWith(clientId: selected, force: true),
              );
            },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Клиент',
          border: const OutlineInputBorder(),
          isDense: true,
          enabled: !widget.clientsLoading,
          suffixIcon: const Icon(Icons.expand_more),
        ),
        child: Text(
          selectedLabel,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Future<String?> _selectClientBottomSheet(
    BuildContext context, {
    required List<ClientEntity> clients,
    required String? selectedClientId,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return _ClientPickerSheet(
                clients: clients,
                selectedClientId: selectedClientId,
                scrollController: scrollController,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDatedControls(BuildContext context) {
    final params = widget.params;
    final now = DateTime.now();
    final selectedDate = DateTime(
      params.year ?? now.year,
      params.month ?? now.month,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Фильтр по месяцу'),
          value: params.filterByMonth,
          onChanged: (value) {
            if (value == false) {
              final current = DateTime.now();
              widget.onParamsChanged(
                params.copyWith(
                  filterByMonth: false,
                  month: current.month,
                  year: current.year,
                  force: true,
                ),
              );
            } else {
              widget.onParamsChanged(
                params.copyWith(filterByMonth: true, force: true),
              );
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (params.filterByMonth) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                  );
                  widget.onParamsChanged(
                    params.copyWith(
                      month: newDate.month,
                      year: newDate.year,
                      force: true,
                    ),
                  );
                },
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Предыдущий месяц',
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _formatMonth(selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final newDate = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                  );
                  widget.onParamsChanged(
                    params.copyWith(
                      month: newDate.month,
                      year: newDate.year,
                      force: true,
                    ),
                  );
                },
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Следующий месяц',
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _ClientPickerSheet extends StatefulWidget {
  final List<ClientEntity> clients;
  final String? selectedClientId;
  final ScrollController scrollController;

  const _ClientPickerSheet({
    required this.clients,
    required this.selectedClientId,
    required this.scrollController,
  });

  @override
  State<_ClientPickerSheet> createState() => _ClientPickerSheetState();
}

class _ClientPickerSheetState extends State<_ClientPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _labelForClient(ClientEntity client) {
    final inn = (client.inn ?? '').trim();
    return inn.isNotEmpty ? '${client.name} ($inn)' : client.name;
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.clients
        : widget.clients.where((c) {
            final label = _labelForClient(c).toLowerCase();
            final inn = (c.inn ?? '').toLowerCase();
            return label.contains(query) || inn.contains(query);
          }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Поиск клиента',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                ListTile(
                  title: const Text('Все клиенты'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: widget.selectedClientId,
                    onChanged: (_) => Navigator.of(context).pop(null),
                  ),
                  onTap: () => Navigator.of(context).pop(null),
                ),
                const Divider(height: 1),
                for (final client in filtered)
                  ListTile(
                    title: Text(_labelForClient(client)),
                    leading: Radio<String?>(
                      value: client.id,
                      groupValue: widget.selectedClientId,
                      onChanged: (_) => Navigator.of(context).pop(client.id),
                    ),
                    onTap: () => Navigator.of(context).pop(client.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
