import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/presentation/widgets/resizable_data_table.dart';

class ClientsTable extends StatefulWidget {
  final List<ClientEntity> clients;
  final ValueChanged<ClientEntity> onOpen;

  const ClientsTable({
    super.key,
    required this.clients,
    required this.onOpen,
  });

  @override
  State<ClientsTable> createState() => _ClientsTableState();
}

class _ClientsTableState extends State<ClientsTable> {
  int _sortColumnIndex = 0;
  bool _sortAsc = true;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final enableSelection =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    final data = List<ClientEntity>.from(widget.clients);
    data.sort((a, b) {
      int res;
      switch (_sortColumnIndex) {
        case 0:
          res = (a.shortName ?? '').compareTo(b.shortName ?? '');
          break;
        case 2:
          res = (a.ownershipForm ?? '').compareTo(b.ownershipForm ?? '');
          break;
        case 3:
          res = a.name.compareTo(b.name);
          break;
        case 4:
          res = (a.inn ?? '').compareTo(b.inn ?? '');
          break;
        case 5:
          res = (a.taxSystems.isNotEmpty ? a.taxSystems.first : '').compareTo(
            b.taxSystems.isNotEmpty ? b.taxSystems.first : '',
          );
          break;
        case 6:
          res = (a.creationDate ?? DateTime(1970)).compareTo(
            b.creationDate ?? DateTime(1970),
          );
          break;
        case 7:
          res = (a.updatedAt ?? DateTime(1970)).compareTo(
            b.updatedAt ?? DateTime(1970),
          );
          break;
        default:
          res = 0;
      }
      return _sortAsc ? res : -res;
    });

    final table = ResizableDataTable(
      prefsKey: 'clients_table_column_widths_v2',
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAsc,
      columns: [
        DataColumn(
          label: const Text('Сокращенное наименование'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        const DataColumn(label: Text('На обслуживании')),
        DataColumn(
          label: const Text('Форма собственности'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn(
          label: const Text('Наименование'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn(
          label: const Text('ИНН'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn(
          label: const Text('Сист. налогообл.'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn(
          label: const Text('Создан'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        DataColumn(
          label: const Text('Обновлён'),
          onSort: (i, asc) => setState(() {
            _sortColumnIndex = i;
            _sortAsc = asc;
          }),
        ),
        const DataColumn(label: Center(child: Icon(Icons.more_horiz))),
      ],
      initialColumnWidths: const [
        180.0,
        180.0,
        180.0,
        250.0,
        150.0,
        200.0,
        120.0,
        120.0,
        60.0,
      ],
      rows: data
          .map(
            (c) => DataRow(
              onSelectChanged: (_) => widget.onOpen(c),
              cells: [
                DataCell(
                  Text(
                    c.shortName ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Tooltip(
                    message:
                        c.onService ? 'На обслуживании' : 'Не на обслуживании',
                    waitDuration: const Duration(milliseconds: 500),
                    child: SizedBox(
                      width: 80,
                      height: 32,
                      child: Center(
                        child: Icon(
                          c.onService
                              ? Icons.check_outlined
                              : Icons.cancel_outlined,
                          color: c.onService
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    c.ownershipForm ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(c.name, overflow: TextOverflow.ellipsis),
                ),
                DataCell(Text(c.inn ?? '-')),
                DataCell(
                  Text(
                    c.taxSystems.isNotEmpty ? c.taxSystems.join(', ') : '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(Text(_formatDate(c.creationDate))),
                DataCell(Text(_formatDate(c.updatedAt))),
                DataCell(
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      tooltip: 'Подробнее',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => widget.onOpen(c),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: enableSelection ? SelectionArea(child: table) : table,
    );
  }
}
