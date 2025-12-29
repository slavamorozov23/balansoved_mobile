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
  Widget _buildWelcomeMascot(BuildContext context, {required double maxHeight}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glowOpacity = isDark ? 0.55 : 0.4;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: glowOpacity),
                        blurRadius: 90,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/promo/moscot_welcome.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final mascotMaxHeight =
                (constraints.maxHeight * 0.42).clamp(180.0, 320.0);

            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWelcomeMascot(
                        context,
                        maxHeight: mascotMaxHeight,
                      ),
                      const SizedBox(height: 16),
                      const Text('Для доступа необходимо авторизоваться'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.router.push(const LoginRoute()),
                        child: const Text('Войти'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.router.replaceAll(
                          [AcceptInvitationRoute()],
                        ),
                        child: const Text('Подтвердить приглашение'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


