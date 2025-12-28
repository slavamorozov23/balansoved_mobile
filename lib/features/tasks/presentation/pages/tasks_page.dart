import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_filters_panel.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table_helpers.dart';
import 'package:balansoved_mobile/router.dart';

class _TaskStatusOption {
  final String? value;
  final String label;

  const _TaskStatusOption({required this.value, required this.label});
}

const List<_TaskStatusOption> _taskStatusOptions = [
  _TaskStatusOption(value: null, label: 'Не выбрано'),
  _TaskStatusOption(value: 'in_progress', label: 'Активна'),
  _TaskStatusOption(value: 'completed', label: 'Завершена'),
  _TaskStatusOption(value: 'cancelled', label: 'Отменена'),
];

@RoutePage()
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _onlyMy = true;
  String? _statusFilter;
  late TaskRequestParams _currentParams;
  String? _lastRequestedFirmId;
  TaskRequestParams? _lastRequestedParams;

  @override
  void initState() {
    super.initState();
    _currentParams = TaskRequestParams.all();
    _onlyMy = _currentParams.onlyMy;
    _statusFilter = _currentParams.status;
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchTasks(String firmId, TaskRequestParams params) {
    _lastRequestedFirmId = firmId;
    _lastRequestedParams = params;
    context.read<TasksCubit>().fetchTasks(firmId, params);
  }

  void _scheduleFetchIfNeeded(String firmId, TasksState tasksState) {
    final alreadyRequested =
        _lastRequestedFirmId == firmId &&
        _lastRequestedParams == _currentParams;
    if (alreadyRequested || tasksState is TasksLoading) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stillNeeded =
          _lastRequestedFirmId != firmId ||
          _lastRequestedParams != _currentParams;
      if (stillNeeded) {
        _fetchTasks(firmId, _currentParams);
      }
    });
  }

  void _applyParams(TaskRequestParams params) {
    setState(() {
      _currentParams = params;
      _onlyMy = params.onlyMy;
      _statusFilter = params.status;
    });
    final firmId = context.read<FirmsCubit>().state.selectedFirm?.id;
    if (firmId != null) {
      _fetchTasks(firmId, params);
    }
  }

  void _updateOnlyMy(bool? value) {
    final newValue = value ?? true;
    if (_currentParams.onlyMy == newValue && _onlyMy == newValue) {
      return;
    }
    final viewType = _currentParams.viewType;
    final updated =
        viewType == TaskViewType.timeless || viewType == TaskViewType.all
            ? _currentParams.copyWith(onlyMy: newValue, page: 0, force: true)
            : _currentParams.copyWith(onlyMy: newValue, force: true);
    _applyParams(updated);
  }

  void _onStatusSelected(String? value) {
    if (_statusFilter == value) {
      return;
    }
    final updated = _currentParams.copyWith(
      status: value,
      page: 0,
      force: true,
    );
    _applyParams(updated);
  }

  Widget _buildStatusFilterDropdown(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _statusFilter,
          onChanged: _onStatusSelected,
          isDense: true,
          icon: const Icon(Icons.expand_more, size: 20),
          items:
              _taskStatusOptions
                  .map(
                    (option) => DropdownMenuItem<String?>(
                      value: option.value,
                      child: Text(option.label, style: textTheme.bodyMedium),
                    ),
                  )
                  .toList(),
          selectedItemBuilder:
              (context) =>
                  _taskStatusOptions
                      .map(
                        (option) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Только: ${option.label}',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      )
                      .toList(),
        ),
      ),
    );
  }

  List<TaskEntity> _applySearch(
    List<TaskEntity> tasks,
    List<ClientEntity> clients,
    List<EmployeeEntity> employees,
  ) {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      final clientsText = TasksTableHelpers.formatClientNamesWithInn(
        task.clientIds,
        clients,
      );
      final assigneesText = TasksTableHelpers.formatEmployeeNames(
        task.assigneeIds,
        employees,
      );
      final haystack =
          [
            task.title,
            task.description ?? '',
            TasksTableHelpers.translateStatus(task.status),
            TasksTableHelpers.translatePriority(task.priority),
            clientsText,
            assigneesText,
          ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirmsCubit, FirmsState>(
      builder: (context, firmState) {
        if (firmState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (firmState.selectedFirm == null) {
          return const Center(child: Text('Фирма не выбрана'));
        }

        final firmId = firmState.selectedFirm!.id;

        return BlocBuilder<ClientsCubit, ClientsState>(
          builder: (context, clientsState) {
            return BlocBuilder<TasksCubit, TasksState>(
              builder: (context, tasksState) {
                _scheduleFetchIfNeeded(firmId, tasksState);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 600;
                          final searchField = TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Поиск задач',
                            ),
                          );

                          final onlyMyToggle = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _onlyMy,
                                onChanged: _updateOnlyMy,
                              ),
                              const SizedBox(width: 8),
                              const Text('Только моё'),
                            ],
                          );

                          final quickFilters = Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              onlyMyToggle,
                              _buildStatusFilterDropdown(context),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                searchField,
                                const SizedBox(height: 12),
                                quickFilters,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: searchField),
                              const SizedBox(width: 16),
                              quickFilters,
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TasksFiltersPanel(
                        params: _currentParams,
                        clients: clientsState.clients,
                        clientsLoading: clientsState.isLoading,
                        onParamsChanged: _applyParams,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildBody(tasksState, clientsState),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBody(TasksState tasksState, ClientsState clientsState) {
    final employeesState = context.watch<EmployeesCubit>().state;
    final paramsOutOfSync =
        tasksState is TasksLoaded && tasksState.params != _currentParams;
    if (tasksState is TasksLoading ||
        tasksState is TasksInitial ||
        paramsOutOfSync ||
        clientsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasksState is TasksNoAccess) {
      return Center(child: Text(tasksState.message));
    }
    if (tasksState is TasksError) {
      return Center(child: Text(tasksState.message));
    }
    if (tasksState is! TasksLoaded) {
      return const Center(child: Text('Нет данных о задачах'));
    }

    final filtered = _applySearch(
      tasksState.tasks,
      clientsState.clients,
      employeesState.employees,
    );
    if (filtered.isEmpty) {
      return const Center(child: Text('Нет задач'));
    }

    return TasksTable(
      tasks: filtered,
      clients: clientsState.clients,
      employees: employeesState.employees,
      onOpen: (task) {
        context.router.push(TaskDetailRoute(task: task));
      },
    );
  }
}
