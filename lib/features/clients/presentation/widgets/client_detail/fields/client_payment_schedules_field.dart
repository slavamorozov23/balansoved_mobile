import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/client_detail/fields/client_field_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientPaymentSchedulesField extends StatelessWidget {
  final PaymentSchedule? salaryPayment;
  final bool? salaryPaymentEnabled;
  final bool? cashPayment;
  final bool? bankPayment;
  final bool? hasEmployees;
  final bool? isSoleFounderDirector;
  final PaymentSchedule? advancePayment;
  final PaymentSchedule? ndflPayment;

  const ClientPaymentSchedulesField({
    super.key,
    required this.salaryPayment,
    required this.salaryPaymentEnabled,
    required this.cashPayment,
    required this.bankPayment,
    required this.hasEmployees,
    required this.isSoleFounderDirector,
    required this.advancePayment,
    required this.ndflPayment,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;
    final sectionStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: TaskStyles.textBody(colorScheme),
    );

    return OfficeFieldFrame(
      label: 'Графики платежей',
      watermarkIcon: Icons.schedule_outlined,
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Настройки выплат', style: sectionStyle),
          const SizedBox(height: 6),
          _buildSettingLine('Есть сотрудники', hasEmployees, Icons.groups_outlined, accent),
          _buildSettingLine(
            'Единственный учредитель-директор',
            isSoleFounderDirector,
            Icons.person_pin_outlined,
            accent,
          ),
          _buildSettingLine(
            'Выплата зарплаты',
            salaryPaymentEnabled,
            Icons.payments_outlined,
            accent,
          ),
          _buildSettingLine('Банк', bankPayment, Icons.account_balance_outlined, accent),
          _buildSettingLine('Касса', cashPayment, Icons.store_outlined, accent),
          const SizedBox(height: 12),
          _buildScheduleBlock(
            context: context,
            label: 'Зарплата',
            icon: Icons.account_balance_wallet_outlined,
            schedule: salaryPayment,
            accent: accent,
            showTransferDate: false,
          ),
          const SizedBox(height: 10),
          _buildScheduleBlock(
            context: context,
            label: 'Аванс',
            icon: Icons.payments_outlined,
            schedule: advancePayment,
            accent: accent,
            showTransferDate: false,
          ),
          const SizedBox(height: 10),
          _buildScheduleBlock(
            context: context,
            label: 'НДФЛ',
            icon: Icons.receipt_long_outlined,
            schedule: ndflPayment,
            accent: accent,
            showTransferDate: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingLine(
    String label,
    bool? value,
    IconData icon,
    Color accent,
  ) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = TextStyle(
          color: TaskStyles.textPrimary(colorScheme),
          fontWeight: FontWeight.w400,
          fontSize: 13,
          height: 1.35,
        );
        final statusIcon =
            value == true
                ? Icons.check_circle_rounded
                : value == false
                ? Icons.cancel_rounded
                : Icons.remove_circle_outline;
        final statusColor =
            value == true
                ? Colors.green.shade600
                : value == false
                ? colorScheme.error
                : TaskStyles.textMuted(colorScheme);

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: accent.withValues(alpha: 0.8)),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: textStyle)),
              Icon(statusIcon, size: 14, color: statusColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleBlock({
    required BuildContext context,
    required String label,
    required IconData icon,
    required PaymentSchedule? schedule,
    required Color accent,
    required bool showTransferDate,
  }) {
    final payment = formatPaymentDate(schedule?.paymentDate);
    final transfer =
        showTransferDate ? formatPaymentDate(schedule?.transferDate) : null;
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(Theme.of(context).colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );
    const valueIndent = 22.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accent.withValues(alpha: 0.85)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: accent.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: valueIndent),
          child: OfficeBulletLine(
            icon: Icons.today_outlined,
            accentColor: accent,
            text: 'Дата: $payment',
            textStyle: valueStyle,
          ),
        ),
        if (transfer != null)
          Padding(
            padding: const EdgeInsets.only(left: valueIndent),
            child: OfficeBulletLine(
              icon: Icons.compare_arrows_outlined,
              accentColor: accent,
              text: 'Перенос: $transfer',
              textStyle: valueStyle,
            ),
          ),
      ],
    );
  }
}
