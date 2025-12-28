import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:balansoved_mobile/features/auth/domain/usecases/accept_invitation_usecase.dart';
import 'package:balansoved_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:balansoved_mobile/features/auth/presentation/widgets/auth_error_panel.dart';
import 'package:balansoved_mobile/router.dart';

@RoutePage()
class AcceptInvitationPage extends StatefulWidget {
  final String? invitationKey;
  const AcceptInvitationPage({
    super.key,
    @PathParam('invitationKey') this.invitationKey,
  });

  @override
  State<AcceptInvitationPage> createState() => _AcceptInvitationPageState();
}

class _AcceptInvitationPageState extends State<AcceptInvitationPage> {
  bool _loading = false;
  String? _error;
  bool _success = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.invitationKey ?? '');
    if (widget.invitationKey != null && widget.invitationKey!.isNotEmpty) {
      _activate(widget.invitationKey!);
    }
  }

  Future<void> _activate(String key) async {
    setState(() {
      _loading = true;
      _error = null;
      _success = false;
    });
    final res = await GetIt.I<AcceptInvitationUseCase>().call(key);
    res.fold(
      (failure) {
        setState(() {
          _loading = false;
          _error = failure.message;
        });
      },
      (_) {
        setState(() {
          _loading = false;
          _success = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AuthErrorPanel(
                          message: _error!,
                          statusCode: null,
                          title: 'Ошибка подтверждения приглашения',
                        ),
                      ),
                    if (_success) ...[
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      const Text('Приглашение успешно принято!'),
                      const SizedBox(height: 24),
                    ],
                    if (!_success) ...[
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ключ приглашения',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _activate(_controller.text.trim()),
                        child: const Text('Подтвердить'),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (_success || _error != null)
                      ElevatedButton(
                        onPressed: _onContinue,
                        child: const Text('Продолжить'),
                      ),
                  ],
                ),
      ),
    );
  }

  void _onContinue() {
    final authState = GetIt.I<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.router.replaceAll([const HomeRoute()]);
    } else {
      context.router.replaceAll([const LoginRoute()]);
    }
  }
}


