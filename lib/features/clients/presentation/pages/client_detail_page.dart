import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/client_versions_cubit.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/client_detail_card.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/injection_container.dart';

@RoutePage()
class ClientDetailPage extends StatelessWidget {
  final String clientName;

  const ClientDetailPage({super.key, required this.clientName});

  String _versionLabel(ClientEntity version) {
    final date = version.manualCreationDate ?? version.creationDate;
    final dateText = date == null ? 'без даты' : _formatDate(date);
    return version.isActual ? '$dateText • актуальная' : dateText;
  }

  @override
  Widget build(BuildContext context) {
    final firmId = context.read<FirmsCubit>().state.selectedFirm?.id;

    return BlocProvider(
      create: (_) {
        final cubit = sl<ClientVersionsCubit>();
        if (firmId != null) {
          cubit.fetchVersions(firmId, clientName);
        }
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Клиент: $clientName'),
        ),
        body: firmId == null
            ? const Center(child: Text('Фирма не выбрана'))
            : BlocBuilder<ClientVersionsCubit, ClientVersionsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null) {
                    return Center(child: Text(state.error!));
                  }
                  if (state.versions.isEmpty) {
                    return const Center(child: Text('Версии клиента не найдены'));
                  }

                  final selected = state.selectedVersion ?? state.versions.first;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<ClientEntity>(
                          isExpanded: true,
                          value: selected,
                          onChanged: (value) {
                            if (value == null) return;
                            context.read<ClientVersionsCubit>().selectVersion(value);
                          },
                          items: state.versions
                              .map(
                                (version) => DropdownMenuItem<ClientEntity>(
                                  value: version,
                                  child: Text(_versionLabel(version)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClientDetailCard(client: selected),
                    ],
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
