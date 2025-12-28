import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:balansoved_mobile/router.dart';

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Router.withConfig(
      config: GetIt.I<AppRouter>().config(),
    );
  }
}

