import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table_helpers.dart';
import 'package:balansoved_mobile/presentation/widgets/resizable_data_table.dart';

class TasksTable extends StatefulWidget {
  final List<TaskEntity> tasks;
  final List<ClientEntity> clients;
  final List<EmployeeEntity> employees;
  final ValueChanged<TaskEntity> onOpen;

  const TasksTable({
    super.key,
    required this.tasks,
    required this.clients,
    required this.employees,
    required this.onOpen,
  });

  @override
  State<TasksTable> createState() => _TasksTableState();
}

class _TasksTableState extends State<TasksTable> {
  int _sortColumnIndex = 0;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    final data = List<TaskEntity>.from(widget.tasks);
    data.sort((a, b) {
      int res;
      switch (_sortColumnIndex) {
        case 0:
          res = a.title.compareTo(b.title);
          break;
        case 1:
          res = TasksTableHelpers.translateStatus(a.status).compareTo(
            TasksTableHelpers.translateStatus(b.status),
          );
          break;
        case 2:
          res = TasksTableHelpers.translatePriority(a.priority).compareTo(
            TasksTableHelpers.translatePriority(b.priority),
          );
          break;
        case 3:
          final aClient = TasksTableHelpers.formatClientNamesWithInn(
            a.clientIds,
            widget.clients,
          ).toLowerCase();
          final bClient = TasksTableHelpers.formatClientNamesWithInn(
            b.clientIds,
            widget.clients,
          ).toLowerCase();
          res = aClient.compareTo(bClient);
          break;
        case 4:
          final aEmp = TasksTableHelpers.formatEmployeeNames(
            a.assigneeIds,
            widget.employees,
          ).toLowerCase();
          final bEmp = TasksTableHelpers.formatEmployeeNames(
            b.assigneeIds,
            widget.employees,
          ).toLowerCase();
          res = aEmp.compareTo(bEmp);
          break;
        case 5:
          final aDate = a.dueDate ?? DateTime(2099);
          final bDate = b.dueDate ?? DateTime(2099);
          res = aDate.compareTo(bDate);
          break;
        default:
          res = 0;
      }
      return _sortAsc ? res : -res;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SelectionArea(
        child: ResizableDataTable(
          prefsKey: 'tasks_table_columns',
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAsc,
          initialColumnWidths: const [200, 150, 120, 220, 200, 100, 160],
          columns: [
            DataColumn(
              label: const Text('Название'),
              onSort: (i, asc) => setState(() {
                _sortColumnIndex = i;
                _sortAsc = asc;
              }),
            ),
            DataColumn(
              label: const Text('Статус'),
              onSort: (i, asc) => setState(() {
                _sortColumnIndex = i;
                _sortAsc = asc;
              }),
            ),
            DataColumn(
              label: const Text('Приоритет'),
              onSort: (i, asc) => setState(() {
                _sortColumnIndex = i;
                _sortAsc = asc;
              }),
            ),
            DataColumn(
              label: const Text('Клиент (ИНН)'),
              onSort: (i, asc) => setState(() {
                _sortColumnIndex = i;
                _sortAsc = asc;
              }),
            ),
            DataColumn(
              label: const Text('Исполнитель'),
              onSort: (i, asc) => setState(() {
                _sortColumnIndex = i;
                _sortAsc = asc;
              }),
            ),
            DataColumn(
              label: const Text('Срок'),
              onSort: (i, asc) => setState(() {
                _sortColumnIndex = i;
                _sortAsc = asc;
              }),
            ),
            const DataColumn(label: Text('Действия')),
          ],
          rows: data
              .map(
                (t) => DataRow(
                  onSelectChanged: (_) => widget.onOpen(t),
                  cells: [
                    DataCell(
                      Text(
                        t.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    DataCell(
                      Text(TasksTableHelpers.translateStatus(t.status)),
                    ),
                    DataCell(
                      Text(TasksTableHelpers.translatePriority(t.priority)),
                    ),
                    DataCell(
                      Text(
                        TasksTableHelpers.formatClientNamesWithInn(
                          t.clientIds,
                          widget.clients,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        t.assigneeIds.isNotEmpty
                            ? TasksTableHelpers.formatEmployeeNames(
                              t.assigneeIds,
                              widget.employees,
                            )
                            : '–',
                      ),
                    ),
                    DataCell(
                      Text(
                        t.dueDate != null
                            ? TaskDetailUtils.formatDate(t.dueDate)
                            : '–',
                      ),
                    ),
                    DataCell(
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: const Icon(Icons.visibility),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => widget.onOpen(t),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
