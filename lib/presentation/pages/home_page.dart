import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:balansoved_mobile/features/clients/presentation/pages/clients_page.dart';
import 'package:balansoved_mobile/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/cubit/firms_cubit.dart';
import 'package:balansoved_mobile/features/firms/presentation/widgets/firm_selector.dart';
import 'package:balansoved_mobile/features/notifications/presentation/widgets/notifications_button.dart';
import 'package:balansoved_mobile/features/tasks/presentation/pages/tasks_page.dart';
import 'package:balansoved_mobile/features/tasks/presentation/cubit/tasks_chrome_cubit.dart';
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
  bool _bottomBarVisible = false;

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

  void _toggleBottomBar() {
    setState(() => _bottomBarVisible = !_bottomBarVisible);
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
    final colorScheme = Theme.of(context).colorScheme;
    final navBarBackground =
        Theme.of(context).navigationBarTheme.backgroundColor ??
        colorScheme.surfaceContainer;

    return MultiBlocListener(
      listeners: [
        BlocListener<FirmsCubit, FirmsState>(
        listenWhen: (previous, current) =>
            previous.selectedFirm?.id != current.selectedFirm?.id &&
            current.selectedFirm != null,
        listener: (context, state) {
          final firmId = state.selectedFirm?.id;
          if (firmId == null) return;
          context.read<ClientsCubit>().fetchClients(firmId);
          context.read<EmployeesCubit>().fetchEmployees(firmId);
        },
        ),
        BlocListener<TasksChromeCubit, bool>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, isCollapsed) {
            if (isCollapsed && _bottomBarVisible) {
              setState(() => _bottomBarVisible = false);
            }
          },
        ),
      ],
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
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            );
          },
          child:
              _bottomBarVisible
                  ? NavigationBar(
                    key: const ValueKey('bottom_nav'),
                    backgroundColor: navBarBackground,
                    elevation: 0,
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
                  )
                  : const SizedBox.shrink(
                    key: ValueKey('bottom_nav_hidden'),
                  ),
        ),
        floatingActionButton: BlocBuilder<TasksChromeCubit, bool>(
          builder: (context, isCollapsed) {
            final showFab = _currentIndex != 0 || !isCollapsed;
            if (!showFab) return const SizedBox.shrink();

            return FloatingActionButton.small(
              onPressed: _toggleBottomBar,
              tooltip:
                  _bottomBarVisible
                      ? 'Скрыть навигацию'
                      : 'Показать навигацию',
              backgroundColor: navBarBackground,
              foregroundColor: colorScheme.onSurfaceVariant,
              shape: const CircleBorder(),
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              disabledElevation: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    _bottomBarVisible
                        ? const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          key: ValueKey('nav_hide'),
                        )
                        : const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          key: ValueKey('nav_show'),
                        ),
              ),
            );
          },
        ),
        floatingActionButtonLocation:
            _bottomBarVisible
                ? FloatingActionButtonLocation.centerDocked
                : FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

