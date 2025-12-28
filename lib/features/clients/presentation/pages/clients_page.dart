import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/clients_table.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/router.dart';

@RoutePage()
class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

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

        return BlocBuilder<ClientsCubit, ClientsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.noAccess) {
              return const Center(
                child: Text('Недостаточно прав для просмотра клиентов'),
              );
            }
            if (state.error != null && state.clients.isEmpty) {
              return Center(child: Text(state.error!));
            }

            if (state.clients.isEmpty) {
              return const Center(child: Text('Нет клиентов'));
            }

            return ClientsTable(
              clients: state.clients,
              onOpen: (client) {
                context.router.push(ClientDetailRoute(clientName: client.name));
              },
            );
          },
        );
      },
    );
  }
}
