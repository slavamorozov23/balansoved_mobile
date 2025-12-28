import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/clients/presentation/pages/clients_page.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/widgets/firm_selector.dart';
import 'package:balansoved_mobile/features/notifications/presentation/widgets/notifications_button.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:balansoved_mobile/features/tasks/presentation/pages/tasks_page.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:balansoved_mobile/router.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FirmsCubit>().loadFirms();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _titleForIndex(int index) {
    return switch (index) {
      0 => 'Задачи',
      1 => 'Клиенты',
      _ => 'Balansoved',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ClientsCubit>()),
        BlocProvider(create: (_) => sl<TasksCubit>()),
      ],
      child: BlocListener<FirmsCubit, FirmsState>(
        listenWhen: (previous, current) =>
            previous.selectedFirm?.id != current.selectedFirm?.id &&
            current.selectedFirm != null,
        listener: (context, state) {
          final firmId = state.selectedFirm?.id;
          if (firmId == null) return;
          context.read<ClientsCubit>().fetchClients(firmId);
          context.read<EmployeesCubit>().fetchEmployees(firmId);
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 56,
            leading: const FirmSelector(),
            title: Text(_titleForIndex(_currentIndex)),
            actions: [
              const NotificationsButton(),
              IconButton(
                onPressed: () => context.router.push(const SettingsRoute()),
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Настройки',
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [TasksPage(), ClientsPage()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                label: 'Задачи',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                label: 'Клиенты',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

