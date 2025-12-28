import 'package:flutter/material.dart';
import 'auth_error_interpreter.dart';

class AuthErrorPanel extends StatelessWidget {
  final String message;
  final int? statusCode;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const AuthErrorPanel({
    super.key,
    required this.message,
    this.statusCode,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    final info = AuthErrorInterpreter.interpret(message, statusCode: statusCode);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
        if (title != null) const SizedBox(height: 4),
        Text(
          info.displayMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }
    return content;
  }
}