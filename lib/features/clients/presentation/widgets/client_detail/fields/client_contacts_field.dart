import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientContactsField extends StatelessWidget {
  final List<ContactEntity> contacts;

  const ClientContactsField({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final muted = TaskStyles.textMuted(colorScheme);
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );
    final borderColor = TaskStyles.dividerColor(colorScheme).withValues(
      alpha: 0.45,
    );

    Widget body;
    if (contacts.isEmpty) {
      body = Text('Контактов нет', style: TextStyle(color: muted));
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in contacts.asMap().entries) ...[
            _ContactCard(
              contact: entry.value,
              index: entry.key,
              accentColor: accent,
              borderColor: borderColor,
              valueStyle: valueStyle,
            ),
            if (entry.key < contacts.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return OfficeFieldFrame(
      label: 'Контакты',
      watermarkIcon: Icons.contacts_outlined,
      accentColor: accent,
      child: body,
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ContactEntity contact;
  final int index;
  final Color accentColor;
  final Color borderColor;
  final TextStyle valueStyle;

  const _ContactCard({
    required this.contact,
    required this.index,
    required this.accentColor,
    required this.borderColor,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = (contact.fullName?.trim().isNotEmpty ?? false)
        ? contact.fullName!.trim()
        : 'Контакт ${index + 1}';
    final phone = contact.phone?.trim() ?? '';
    final emails = contact.emails.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final methods =
        contact.communicationMethods.entries
            .map(
              (entry) => _ContactMethod(
                label: entry.key.trim(),
                value: entry.value.trim(),
              ),
            )
            .where((method) => method.label.isNotEmpty || method.value.isNotEmpty)
            .toList();

    final hasDetails = phone.isNotEmpty || emails.isNotEmpty || methods.isNotEmpty;
    final muted = TaskStyles.textMuted(colorScheme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Color.lerp(accentColor, colorScheme.surface, 0.96) ??
            colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: TaskStyles.textPrimary(colorScheme),
            ),
          ),
          const SizedBox(height: 6),
          if (!hasDetails)
            Text('Данных нет', style: TextStyle(color: muted))
          else ...[
            if (phone.isNotEmpty)
              _ContactPhoneLine(
                phone: phone,
                accentColor: accentColor,
                valueStyle: valueStyle,
              ),
            for (final email in emails)
              OfficeBulletLine(
                icon: Icons.email_outlined,
                accentColor: accentColor,
                text: email,
                textStyle: valueStyle,
              ),
            for (final method in methods)
              _ContactMethodLine(
                method: method,
                accentColor: accentColor,
                valueStyle: valueStyle,
              ),
          ],
        ],
      ),
    );
  }
}

class _ContactMethod {
  final String label;
  final String value;

  const _ContactMethod({required this.label, required this.value});
}

class _ContactPhoneLine extends StatelessWidget {
  final String phone;
  final Color accentColor;
  final TextStyle valueStyle;

  const _ContactPhoneLine({
    required this.phone,
    required this.accentColor,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final uri = _buildPhoneUri(phone);
    final line = OfficeBulletLine(
      icon: Icons.phone_outlined,
      accentColor: accentColor,
      text: phone,
      textStyle: valueStyle,
    );

    if (uri == null) return line;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _launchContactUri(context, uri, 'Телефон'),
      child: line,
    );
  }
}

class _ContactMethodLine extends StatelessWidget {
  final _ContactMethod method;
  final Color accentColor;
  final TextStyle valueStyle;

  const _ContactMethodLine({
    required this.method,
    required this.accentColor,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final text = _formatMethodText(method.label, method.value);
    final uri = _buildChatUri(method.label, method.value);
    final line = OfficeBulletLine(
      icon: Icons.chat_bubble_outline,
      accentColor: accentColor,
      text: text,
      textStyle: valueStyle,
    );

    if (uri == null) return line;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _launchContactUri(context, uri, method.label),
      child: line,
    );
  }
}

String _formatMethodText(String label, String value) {
  if (label.isEmpty) return value;
  if (value.isEmpty) return label;
  return '$label: $value';
}

Future<void> _launchContactUri(
  BuildContext context,
  Uri uri,
  String label,
) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (ok) return;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.showSnackBar(
    SnackBar(content: Text('Не удалось открыть $label')),
  );
}

Uri? _buildChatUri(String method, String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final normalized = method.trim().toLowerCase();
  final explicitUrl = _parseExplicitUrl(value);

  if (normalized.contains('whatsapp') || normalized.contains('ватсап')) {
    if (explicitUrl != null) return explicitUrl;
    final digits = _digitsOnly(value);
    if (digits.isEmpty) return null;
    return Uri.parse('https://wa.me/$digits');
  }

  if (normalized.contains('telegram') || normalized.contains('телеграм')) {
    if (explicitUrl != null) return explicitUrl;
    if (value.contains('t.me') || value.contains('telegram.me')) {
      final link = value.startsWith('http') ? value : 'https://$value';
      return Uri.parse(link);
    }
    final user = _stripAt(value);
    return Uri.parse('https://t.me/$user');
  }

  if (normalized.contains('viber')) {
    if (explicitUrl != null) return explicitUrl;
    final digits = _digitsOnly(value);
    if (digits.isEmpty) return null;
    return Uri.parse('viber://chat?number=$digits');
  }

  if (normalized.contains('skype')) {
    if (value.startsWith('skype:')) return Uri.parse(value);
    final user = _stripAt(value);
    return Uri.parse('skype:$user?chat');
  }

  if (normalized.contains('vk') || normalized.contains('вк') ||
      normalized.contains('vkontakte')) {
    if (explicitUrl != null) return explicitUrl;
    final user = _stripAt(value);
    return Uri.parse('https://vk.com/$user');
  }

  if (normalized.contains('instagram') || normalized.contains('инстаграм')) {
    if (explicitUrl != null) return explicitUrl;
    final user = _stripAt(value);
    return Uri.parse('https://instagram.com/$user');
  }

  if (normalized.contains('facebook') || normalized.contains('фейсбук')) {
    if (explicitUrl != null) return explicitUrl;
    final user = _stripAt(value);
    return Uri.parse('https://facebook.com/$user');
  }

  if (normalized.contains('discord')) {
    if (explicitUrl != null) return explicitUrl;
    final digits = _digitsOnly(value);
    if (digits.isNotEmpty) {
      return Uri.parse('https://discord.com/users/$digits');
    }
    return Uri.parse('https://discord.com/users/${_stripAt(value)}');
  }

  if (normalized.contains('zoom')) {
    if (explicitUrl != null) return explicitUrl;
    final digits = _digitsOnly(value);
    if (digits.isNotEmpty) {
      return Uri.parse('https://zoom.us/j/$digits');
    }
    return null;
  }

  if (normalized.contains('sms') || normalized.contains('смс')) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty) return null;
    return Uri(scheme: 'sms', path: digits);
  }

  if (normalized.contains('email') || normalized.contains('e-mail')) {
    return Uri(scheme: 'mailto', path: value);
  }

  if (normalized.contains('телефон') || normalized.contains('phone')) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty) return null;
    return Uri(scheme: 'tel', path: digits);
  }

  return explicitUrl;
}

Uri? _buildPhoneUri(String rawValue) {
  final normalized = rawValue.trim();
  if (normalized.isEmpty) return null;
  final cleaned = normalized.replaceAll(RegExp(r'[^0-9+]'), '');
  if (cleaned.isEmpty) return null;
  return Uri(scheme: 'tel', path: cleaned);
}

String _digitsOnly(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}

String _stripAt(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('@')) return trimmed.substring(1);
  return trimmed;
}

Uri? _parseExplicitUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  if (uri.hasScheme) return uri;
  if (trimmed.contains('.') && !trimmed.contains(' ')) {
    return Uri.tryParse('https://$trimmed');
  }
  return null;
}
