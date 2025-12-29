import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientDigitalSignatureExpiryField extends StatelessWidget {
  final DateTime? expiryDate;

  const ClientDigitalSignatureExpiryField({
    super.key,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;
    final timeStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: TaskStyles.textPrimary(colorScheme),
    );
    final dateStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: TaskStyles.textBody(colorScheme),
    );
    final centerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      color: accent,
    );

    return OfficeFieldFrame(
      label: 'Срок действия ЭЦП',
      watermarkIcon: Icons.verified_user_outlined,
      accentColor: accent,
      child: OfficeClockDateTimeValue(
        date: expiryDate,
        accentColor: accent,
        timeTextStyle: timeStyle,
        dateTextStyle: dateStyle,
        centerLabelStyle: centerStyle,
      ),
    );
  }
}
