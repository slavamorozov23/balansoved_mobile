import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table_helpers.dart';
import 'package:balansoved_mobile/presentation/widgets/loading_tile.dart';

class TaskClientsField extends StatelessWidget {
  final List<String> clientIds;
  final List<ClientEntity> clients;
  final bool clientsLoading;

  const TaskClientsField({
    super.key,
    required this.clientIds,
    required this.clients,
    this.clientsLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = TaskStyles.accentForegroundColor(colorScheme);

    Widget body;
    if (clientsLoading && clientIds.isNotEmpty) {
      body = const LoadingTile(height: 18, maxWidth: 220);
    } else {
      final names = TasksTableHelpers.formatClientNamesWithInnList(
        clientIds,
        clients,
      );
      body =
          names.isEmpty
              ? const OfficeEmptyValue()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final name in names)
                    OfficeBulletLine(
                      icon: Icons.folder_outlined,
                      accentColor: accent,
                      text: name,
                    ),
                ],
              );
    }

    return OfficeFieldFrame(
      label: 'Клиенты',
      watermarkIcon: Icons.business_outlined,
      accentColor: accent,
      child: body,
    );
  }
}
