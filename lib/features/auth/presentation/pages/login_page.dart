import 'package:auto_route/auto_route.dart';
import 'package:balansoved_mobile/presentation/widgets/constrained_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:balansoved_mobile/router.dart';
import 'package:balansoved_mobile/features/auth/presentation/widgets/auth_error_panel.dart';
import 'package:balansoved_mobile/presentation/widgets/cat_loader.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(16);
    final borderColor = colorScheme.outline.withValues(
      alpha: isDark ? 0.4 : 0.5,
    );
    final baseBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.35 : 0.75,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.4),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    );
  }

  Widget _buildMascot(BuildContext context, {required double maxHeight}) {
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
                  'assets/promo/moscot_keys.png',
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surface,
        colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.04),
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Авторизация'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              sl<Talker>().error('LOGIN ERROR: ${state.message}');
            }
            if (state is AuthAuthenticated) {
              Navigator.of(context).pop();
            }
            if (state is AuthAwaitingEmailConfirmation) {
              context.router.push(ConfirmRegistrationRoute(email: state.email));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const CatLoadingView();
            }
            return ConstrainedWrap(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mascotMaxHeight = (constraints.maxHeight * 0.34)
                          .clamp(160.0, 280.0);

                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              _buildMascot(
                                context,
                                maxHeight: mascotMaxHeight,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: _buildInputDecoration(
                                  context,
                                  label: 'Email',
                                ),
                                validator: (v) => v != null && v.contains('@')
                                    ? null
                                    : 'Неверный email',
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                decoration: _buildInputDecoration(
                                  context,
                                  label: 'Пароль',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (v) => v != null && v.length >= 6
                                    ? null
                                    : 'Минимум 6 символов',
                              ),
                              if (state is AuthError) ...[
                                const SizedBox(height: 16),
                                AuthErrorPanel(
                                  message: state.message,
                                  statusCode: state.statusCode,
                                  title: 'Не удалось войти',
                                ),
                              ],
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().login(
                                          email:
                                              _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        );
                                      }
                                    },
                                    child: const Text('Войти'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _showUserNameDialog();
                                      }
                                    },
                                    child: const Text('Регистрация'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Кликабельный текст для сброса пароля
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Перенаправление на страницу сброса пароля
                                    // Route добавлю в следующем шаге
                                    context.router.push(
                                      const PasswordResetRoute(),
                                    );
                                  },
                                  child: const Text('Забыли пароль?'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUserNameDialog() async {
    String userName = '';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Введите имя'),
        content: TextField(
          onChanged: (val) => userName = val,
          decoration: const InputDecoration(hintText: 'Имя пользователя'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (userName.isNotEmpty) {
                context.read<AuthCubit>().registerRequest(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                  userName: userName,
                );
              }
            },
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }
}
