import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_chrome_cubit.dart';
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
  bool _filtersCollapsed = false;
  late TaskRequestParams _currentParams;
  String? _lastRequestedFirmId;
  TaskRequestParams? _lastRequestedParams;
  String? _lastRequestedClientsFirmId;
  String? _lastRequestedEmployeesFirmId;

  @override
  void initState() {
    super.initState();
    _currentParams = TaskRequestParams.timeline();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TasksChromeCubit>().setCollapsed(_filtersCollapsed);
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
    });
    final firmId = context.read<FirmsCubit>().state.selectedFirm?.id;
    if (firmId != null) {
      _fetchTasks(firmId, params);
    }
  }

  void _setFiltersCollapsed(bool value) {
    if (_filtersCollapsed == value) return;
    setState(() => _filtersCollapsed = value);
    context.read<TasksChromeCubit>().setCollapsed(value);
  }

  void _scheduleReferenceFetchIfNeeded(
    String firmId,
    ClientsState clientsState,
    EmployeesState employeesState,
  ) {
    if (clientsState.clients.isEmpty &&
        !clientsState.isLoading &&
        !clientsState.noAccess &&
        _lastRequestedClientsFirmId != firmId) {
      _lastRequestedClientsFirmId = firmId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ClientsCubit>().fetchClients(firmId);
      });
    }

    if (employeesState.employees.isEmpty &&
        !employeesState.isLoading &&
        employeesState.error == null &&
        _lastRequestedEmployeesFirmId != firmId) {
      _lastRequestedEmployeesFirmId = firmId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<EmployeesCubit>().fetchEmployees(firmId);
      });
    }
  }

  TaskRequestParams _updateOnlyMyForParams(
    TaskRequestParams params,
    bool onlyMy,
  ) {
    final viewType = params.viewType;
    if (viewType == TaskViewType.timeline) {
      return params.copyWith(
        onlyMy: onlyMy,
        direction: 'initial',
        cursorAt: null,
        force: true,
      );
    }
    return viewType == TaskViewType.timeless || viewType == TaskViewType.all
        ? params.copyWith(onlyMy: onlyMy, page: 0, force: true)
        : params.copyWith(onlyMy: onlyMy, force: true);
  }

  TaskRequestParams _updateStatusForParams(
    TaskRequestParams params,
    String? status,
  ) {
    if (params.viewType == TaskViewType.timeline) {
      return params.copyWith(
        status: status,
        direction: 'initial',
        cursorAt: null,
        force: true,
      );
    }
    return params.copyWith(status: status, page: 0, force: true);
  }

  Future<void> _openFiltersSheet(
    BuildContext context, {
    required ClientsState clientsState,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        TaskRequestParams sheetParams = _currentParams;

        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.82,
            minChildSize: 0.55,
            maxChildSize: 0.96,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, setSheetState) {
                  void apply(TaskRequestParams params) {
                    setSheetState(() => sheetParams = params);
                    _applyParams(params);
                  }

                  return ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Фильтры',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Закрыть',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Только моё'),
                        value: sheetParams.onlyMy,
                        onChanged: (value) {
                          final next = value ?? true;
                          apply(_updateOnlyMyForParams(sheetParams, next));
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        value: sheetParams.status,
                        decoration: const InputDecoration(
                          labelText: 'Статус',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          for (final option in _taskStatusOptions)
                            DropdownMenuItem<String?>(
                              value: option.value,
                              child: Text(option.label),
                            ),
                        ],
                        onChanged: (value) {
                          apply(_updateStatusForParams(sheetParams, value));
                        },
                      ),
                      const SizedBox(height: 12),
                      TasksFiltersPanel(
                        params: sheetParams,
                        clients: clientsState.clients,
                        clientsLoading: clientsState.isLoading,
                        onParamsChanged: apply,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
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
                final employeesState = context.watch<EmployeesCubit>().state;
                _scheduleReferenceFetchIfNeeded(
                  firmId,
                  clientsState,
                  employeesState,
                );

                final filtersSection = Column(
                  key: const ValueKey('tasks_filters_section'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Поиск задач',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed:
                                () => _openFiltersSheet(
                                  context,
                                  clientsState: clientsState,
                                ),
                            icon: const Icon(Icons.tune_rounded),
                            tooltip: 'Фильтры',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );

                return Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child:
                          _filtersCollapsed
                              ? const SizedBox.shrink(
                                key: ValueKey('tasks_filters_hidden'),
                              )
                              : filtersSection,
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.axis != Axis.vertical) {
                            return false;
                          }

                          if (notification is UserScrollNotification) {
                            if (notification.direction ==
                                ScrollDirection.reverse) {
                              _setFiltersCollapsed(true);
                            } else if (notification.direction ==
                                ScrollDirection.forward) {
                              _setFiltersCollapsed(false);
                            }
                          } else if (notification is ScrollUpdateNotification) {
                            final delta = notification.scrollDelta;
                            if (delta != null && delta != 0) {
                              _setFiltersCollapsed(delta > 0);
                            }
                          } else if (notification is ScrollEndNotification) {
                            if (notification.metrics.pixels <= 0) {
                              _setFiltersCollapsed(false);
                            }
                          }

                          return false;
                        },
                        child: _buildBody(
                          firmId,
                          tasksState,
                          clientsState,
                          employeesState,
                        ),
                      ),
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

  Widget _buildBody(
    String firmId,
    TasksState tasksState,
    ClientsState clientsState,
    EmployeesState employeesState,
  ) {
    TaskRequestParams? activeParams;
    List<TaskEntity>? activeTasks;
    bool canLoadMore = false;
    bool canLoadOlder = false;
    bool canLoadNewer = false;
    bool loadingMore = false;
    bool loadingOlder = false;
    bool loadingNewer = false;

    if (tasksState is TasksLoaded) {
      activeParams = tasksState.params;
      activeTasks = tasksState.tasks;
      canLoadMore = tasksState.canLoadMore;
      canLoadOlder = tasksState.canLoadOlder;
      canLoadNewer = tasksState.canLoadNewer;
    } else if (tasksState is TasksLoadingMore) {
      activeParams = tasksState.params;
      activeTasks = tasksState.tasks;
      canLoadMore = tasksState.canLoadMore;
      canLoadOlder = tasksState.canLoadOlder;
      canLoadNewer = tasksState.canLoadNewer;
      loadingMore = tasksState.loadingMore;
      loadingOlder = tasksState.loadingOlder;
      loadingNewer = tasksState.loadingNewer;
    }

    final paramsOutOfSync =
        activeParams != null && activeParams != _currentParams;
    if (tasksState is TasksLoading ||
        tasksState is TasksInitial ||
        paramsOutOfSync ||
        clientsState.isLoading ||
        employeesState.isLoading ||
        (employeesState.employees.isEmpty && employeesState.error == null) ||
        (clientsState.clients.isEmpty &&
            clientsState.error == null &&
            !clientsState.noAccess)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasksState is TasksNoAccess) {
      return Center(child: Text(tasksState.message));
    }
    if (tasksState is TasksError) {
      return Center(child: Text(tasksState.message));
    }
    if (activeTasks == null || activeParams == null) {
      return const Center(child: Text('Нет данных о задачах'));
    }

    final filtered = _applySearch(
      activeTasks,
      clientsState.clients,
      employeesState.employees,
    );
    if (filtered.isEmpty) {
      return const Center(child: Text('Нет задач'));
    }

    return _buildTasksTableSection(
      firmId,
      activeParams,
      filtered,
      clientsState.clients,
      employeesState.employees,
      canLoadMore: canLoadMore,
      canLoadOlder: canLoadOlder,
      canLoadNewer: canLoadNewer,
      loadingMore: loadingMore,
      loadingOlder: loadingOlder,
      loadingNewer: loadingNewer,
    );
  }

  Widget _buildTasksTableSection(
    String firmId,
    TaskRequestParams params,
    List<TaskEntity> tasks,
    List<ClientEntity> clients,
    List<EmployeeEntity> employees, {
    required bool canLoadMore,
    required bool canLoadOlder,
    required bool canLoadNewer,
    required bool loadingMore,
    required bool loadingOlder,
    required bool loadingNewer,
  }) {
    Widget? topRow;
    Widget? bottomRow;
    VoidCallback? topRowTap;
    VoidCallback? bottomRowTap;

    if (params.viewType == TaskViewType.timeline) {
      if (canLoadNewer || loadingNewer) {
        topRow = _buildLoadButton(
          label: loadingNewer ? 'Загружаем...' : 'Загрузить новые задачи',
          icon: Icons.arrow_upward,
          isLoading: loadingNewer,
          onPressed:
              loadingNewer
                  ? null
                  : () => context.read<TasksCubit>().loadNewerTimelineTasks(
                    firmId,
                  ),
        );
        topRowTap =
            loadingNewer
                ? null
                : () =>
                    context.read<TasksCubit>().loadNewerTimelineTasks(firmId);
      }
    }

    if (params.viewType == TaskViewType.timeline) {
      if (canLoadOlder || loadingOlder) {
        bottomRow = _buildLoadButton(
          label: loadingOlder ? 'Загружаем...' : 'Загрузить старые задачи',
          icon: Icons.arrow_downward,
          isLoading: loadingOlder,
          onPressed:
              loadingOlder
                  ? null
                  : () => context.read<TasksCubit>().loadOlderTimelineTasks(
                    firmId,
                  ),
        );
        bottomRowTap =
            loadingOlder
                ? null
                : () =>
                    context.read<TasksCubit>().loadOlderTimelineTasks(firmId);
      }
    } else if (params.viewType == TaskViewType.timeless ||
        params.viewType == TaskViewType.all) {
      if (canLoadMore || loadingMore) {
        bottomRow = _buildLoadButton(
          label: loadingMore ? 'Загружаем...' : 'Загрузить ещё задач',
          icon: Icons.expand_more,
          isLoading: loadingMore,
          onPressed:
              loadingMore
                  ? null
                  : () => context.read<TasksCubit>().loadMoreTasks(firmId),
        );
        bottomRowTap =
            loadingMore
                ? null
                : () => context.read<TasksCubit>().loadMoreTasks(firmId);
      }
    } else if (params.viewType == TaskViewType.dated && !params.filterByMonth) {
      if (canLoadMore || loadingMore) {
        bottomRow = _buildLoadButton(
          label: loadingMore ? 'Загружаем...' : 'Загрузить ещё задач',
          icon: Icons.expand_more,
          isLoading: loadingMore,
          onPressed:
              loadingMore
                  ? null
                  : () =>
                      context.read<TasksCubit>().loadMoreUrgentTasks(firmId),
        );
        bottomRowTap =
            loadingMore
                ? null
                : () =>
                    context.read<TasksCubit>().loadMoreUrgentTasks(firmId);
      }
    }

    return TasksTable(
      tasks: tasks,
      clients: clients,
      employees: employees,
      onOpen: (task) {
        context.router.push(TaskDetailRoute(task: task));
      },
      topFullWidthRow: topRow,
      bottomFullWidthRow: bottomRow,
      onTopRowTap: topRowTap,
      onBottomRowTap: bottomRowTap,
    );
  }

  Widget _buildLoadButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed == null ? color.withValues(alpha: 0.5) : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
