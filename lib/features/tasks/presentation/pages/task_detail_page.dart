import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail_card.dart';

@RoutePage()
class TaskDetailPage extends StatefulWidget {
  final TaskEntity task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskEntity _task;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _ensureReferenceData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTask();
    });
  }

  void _ensureReferenceData() {
    final firmId = context.read<FirmsCubit>().state.selectedFirm?.id;
    if (firmId == null) return;

    final employeesState = context.read<EmployeesCubit>().state;
    if (!employeesState.isLoading && employeesState.employees.isEmpty) {
      context.read<EmployeesCubit>().fetchEmployees(firmId);
    }

    final clientsState = context.read<ClientsCubit>().state;
    if (!clientsState.isLoading &&
        clientsState.clients.isEmpty &&
        !clientsState.noAccess) {
      context.read<ClientsCubit>().fetchClients(firmId);
    }
  }

  Future<void> _refreshTask() async {
    final firmId = context.read<FirmsCubit>().state.selectedFirm?.id;
    if (firmId == null) return;

    setState(() => _isRefreshing = true);
    final fresh = await context.read<TasksCubit>().fetchFreshTask(
      firmId,
      _task.id,
    );
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
      if (fresh != null) {
        _task = fresh;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Задача')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<EmployeesCubit, EmployeesState>(
            builder: (context, employeesState) {
              return BlocBuilder<ClientsCubit, ClientsState>(
                builder: (context, clientsState) {
                  return BlocBuilder<TasksCubit, TasksState>(
                    builder: (context, tasksState) {
                      TaskEntity currentTask = _task;
                      List<TaskEntity>? tasks;
                      if (tasksState is TasksLoaded) {
                        tasks = tasksState.tasks;
                      } else if (tasksState is TasksLoadingMore) {
                        tasks = tasksState.tasks;
                      }

                      if (tasks != null) {
                        final updated =
                            tasks.where((t) => t.id == _task.id).toList();
                        if (updated.isNotEmpty) {
                          currentTask = updated.first;
                        }
                      }

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (_isRefreshing) ...[
                            const LinearProgressIndicator(),
                            const SizedBox(height: 16),
                          ],
                          TaskDetailCard(
                            task: currentTask,
                            employees: employeesState.employees,
                            clients: clientsState.clients,
                            clientsLoading: clientsState.isLoading,
                            viewportHeight: constraints.maxHeight,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
