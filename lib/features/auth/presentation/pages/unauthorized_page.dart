import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/router.dart';

@RoutePage()
class UnauthorizedPage extends StatefulWidget {
  const UnauthorizedPage({super.key});

  @override
  State<UnauthorizedPage> createState() => _UnauthorizedPageState();
}

class _UnauthorizedPageState extends State<UnauthorizedPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.replaceAll([const HomeRoute()]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Если пользователь авторизован, перенаправляем на домашнюю страницу
          context.router.replaceAll([const HomeRoute()]);
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Для доступа необходимо авторизоваться'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.router.push(const LoginRoute()),
                child: const Text('Войти'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => context.router.replaceAll([AcceptInvitationRoute()]),
                child: const Text('Подтвердить приглашение'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


