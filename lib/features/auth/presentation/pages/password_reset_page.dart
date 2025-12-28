import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/router.dart';
import 'package:balansoved_mobile/features/auth/presentation/widgets/auth_error_panel.dart';

@RoutePage()
class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});
  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _step = 1;
  bool _obscurePasswords = true;
  bool _didNavigate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сброс пароля')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // После успешного сброса — переходим в приложение (отложенно и один раз)
            if (!_didNavigate) {
              _didNavigate = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.router.replaceAll([const HomeRoute()]);
              });
            }
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state is AuthError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: AuthErrorPanel(
                            message: state.message,
                            statusCode: state.statusCode,
                            title: _step == 1 ? 'Ошибка запроса сброса пароля' : 'Ошибка подтверждения сброса',
                          ),
                        ),
                      if (_step == 1) ...[
                        const Text(
                          'Введите email для отправки инструкции по сбросу пароля',
                        ),
                        const SizedBox(height: 16),
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
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _requestReset();
                            }
                          },
                          child: const Text('Отправить код'),
                        ),
                      ] else ...[
                        Text(
                          'Введите код из письма и новый пароль для ${_emailController.text}',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Код из письма',
                          ),
                          validator:
                              (v) =>
                                  v != null && v.isNotEmpty
                                      ? null
                                      : 'Введите код',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Новый пароль',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePasswords
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePasswords = !_obscurePasswords;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePasswords,
                          validator:
                              (v) =>
                                  v != null && v.length >= 6
                                      ? null
                                      : 'Минимум 6 символов',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Повторите пароль',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePasswords
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePasswords = !_obscurePasswords;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePasswords,
                          validator:
                              (v) =>
                                  v == _newPasswordController.text
                                      ? null
                                      : 'Пароли не совпадают',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Левая зона: показываем email и кнопку "изменить email"
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Text('Email: ${_emailController.text}'),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _step = 1; // Вернуться к вводу email
                                        });
                                      },
                                      child: const Text('Изменить email'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Правая зона: кнопка сброса пароля
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _confirmReset();
                                }
                              },
                              child: const Text('Сбросить пароль'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    try {
      final ok = await context.read<AuthCubit>().requestPasswordReset(
        email: email,
      );
      if (ok) {
        if (!mounted) return;
        // Переходим ко 2-му шагу только при успехе
        setState(() {
          _step = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Инструкции отправлены на email')),
        );
      }
      // Если не ok — AuthError обработается в BlocConsumer.listener и покажет сырой текст ошибки
    } catch (e) {
      // Ошибка будет показана через BlocListener (AuthError)
    }
  }

  Future<void> _confirmReset() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    try {
      await context.read<AuthCubit>().resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      // Успех обработается через AuthAuthenticated в listener
    } catch (e) {
      // Ошибка будет показана через BlocListener
    }
  }
}


