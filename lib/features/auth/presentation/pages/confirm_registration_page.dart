import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/router.dart';
import 'package:balansoved_mobile/features/auth/presentation/widgets/auth_error_panel.dart';

@RoutePage()
class ConfirmRegistrationPage extends StatefulWidget {
  final String email;
  const ConfirmRegistrationPage({
    super.key,
    @PathParam('email') required this.email,
  });

  @override
  State<ConfirmRegistrationPage> createState() =>
      _ConfirmRegistrationPageState();
}

class _ConfirmRegistrationPageState extends State<ConfirmRegistrationPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение регистрации')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // После успешного подтверждения закрываем страницу
            context.router.popUntilRoot();
            context.router.replace(const HomeRoute());
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
          return Padding(
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
                        title: 'Ошибка подтверждения',
                      ),
                    ),
                  Text('Мы отправили код подтверждения на ${widget.email}'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Код из email',
                    ),
                    validator:
                        (v) =>
                            v != null && v.length == 6
                                ? null
                                : 'Введите 6-значный код',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthCubit>().confirmRegistration(
                          email: widget.email,
                          code: _codeController.text.trim(),
                        );
                      }
                    },
                    child: const Text('Подтвердить'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<AuthCubit>().resendVerificationCode();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Код отправлен повторно')),
                      );
                    },
                    child: const Text('Отправить код ещё раз'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


