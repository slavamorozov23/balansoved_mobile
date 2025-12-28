import 'package:auto_route/auto_route.dart';
import 'package:balansoved_mobile/presentation/widgets/constrained_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:balansoved_mobile/router.dart';
import 'package:balansoved_mobile/features/auth/presentation/widgets/auth_error_panel.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: BlocConsumer<AuthCubit, AuthState>(
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
            return const Center(child: CircularProgressIndicator());
          }
          return ConstrainedWrap(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is AuthError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AuthErrorPanel(
                          message: state.message,
                          statusCode: state.statusCode,
                          title: 'Не удалось войти',
                        ),
                      ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator:
                          (v) =>
                              v != null && v.contains('@')
                                  ? null
                                  : 'Неверный email',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
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
                      validator:
                          (v) =>
                              v != null && v.length >= 6
                                  ? null
                                  : 'Минимум 6 символов',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
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
                          context.router.push(const PasswordResetRoute());
                        },
                        child: const Text('Забыли пароль?'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUserNameDialog() async {
    String userName = '';
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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


