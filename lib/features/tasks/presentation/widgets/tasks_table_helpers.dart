import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';

class TasksTableHelpers {
  static String translateStatus(String status) {
    switch (status) {
      case 'todo':
      case 'new':
        return 'Новая';
      case 'in_progress':
      case 'inProgress':
        return 'В работе';
      case 'done':
      case 'completed':
        return 'Готово';
      case 'cancelled':
      case 'canceled':
        return 'Отменена';
      default:
        return status;
    }
  }

  static String translatePriority(String priority) {
    switch (priority) {
      case 'low':
        return 'Низкий';
      case 'medium':
        return 'Средний';
      case 'high':
        return 'Высокий';
      case 'critical':
        return 'Критический';
      default:
        return priority;
    }
  }

  static String formatClientNamesWithInn(
    List<String> clientIds,
    List<ClientEntity> clients,
  ) {
    if (clientIds.isEmpty) return '–';
    if (clients.isEmpty) return clientIds.join(', ');

    final byId = {for (final c in clients) c.id: c};
    final names = clientIds.map((id) {
      final c = byId[id];
      if (c == null) return 'клиент не найден ($id)';
      final inn = (c.inn ?? '').trim();
      return inn.isNotEmpty ? '${c.name} ($inn)' : c.name;
    }).toList();
    return names.join(', ');
  }

  static List<String> formatClientNamesWithInnList(
    List<String> clientIds,
    List<ClientEntity> clients,
  ) {
    if (clientIds.isEmpty) return const [];
    if (clients.isEmpty) return clientIds;

    final byId = {for (final c in clients) c.id: c};
    return clientIds.map((id) {
      final c = byId[id];
      if (c == null) return 'клиент не найден ($id)';
      final inn = (c.inn ?? '').trim();
      return inn.isNotEmpty ? '${c.name} ($inn)' : c.name;
    }).toList();
  }

  static String formatEmployeeNames(
    List<String> userIds,
    List<EmployeeEntity> employees,
  ) {
    if (userIds.isEmpty) return '–';
    if (employees.isEmpty) return userIds.join(', ');

    final byId = {for (final e in employees) e.id: e};
    final names = userIds.map((id) {
      final e = byId[id];
      if (e == null) return id;
      return e.userName ?? e.email ?? e.id;
    }).toList();
    return names.join(', ');
  }
}
