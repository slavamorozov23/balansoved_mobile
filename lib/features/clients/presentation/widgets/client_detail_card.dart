import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';

class ClientDetailCard extends StatelessWidget {
  final ClientEntity client;

  const ClientDetailCard({super.key, required this.client});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailBlock(context, label: 'Наименование', value: client.name),
        _detailBlock(
          context,
          label: 'Сокращенное имя',
          value: client.shortName ?? '–',
        ),
        _detailBlock(context, label: 'ИНН', value: client.inn ?? '–'),
        _detailBlock(
          context,
          label: 'Форма собственности',
          value: client.ownershipForm ?? '–',
        ),
        _detailBlock(
          context,
          label: 'Система налогообложения',
          value:
              client.taxSystems.isNotEmpty
                  ? client.taxSystems.join(', ')
                  : '–',
        ),
        _detailBlock(
          context,
          label: 'На обслуживании',
          value: client.onService ? 'Да' : 'Нет',
        ),
        _detailBlock(
          context,
          label: 'Дата версии',
          value: _formatDate(client.manualCreationDate ?? client.creationDate),
        ),
        _detailBlock(context, label: 'Обновлено', value: _formatDate(client.updatedAt)),
        _detailBlock(context, label: 'Комментарий', value: client.comment ?? '–'),
      ],
    );
  }

  Widget _detailBlock(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
