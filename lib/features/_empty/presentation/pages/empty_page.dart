import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/_empty/presentation/widgets/empty_view.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyView(),
    );
  }
}

