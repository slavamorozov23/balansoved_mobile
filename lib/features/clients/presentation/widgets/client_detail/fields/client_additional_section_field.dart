import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/client_detail/fields/client_field_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientAdditionalSectionField extends StatelessWidget {
  final List<String> activityTypes;
  final List<String> additionalTags;
  final List<String> fixedContributionsIP;
  final List<int> fixedContributionsPaymentDate;
  final List<String> contributionsIP1Percent;
  final List<int> contributionsIP1PercentPaymentDate;

  const ClientAdditionalSectionField({
    super.key,
    required this.activityTypes,
    required this.additionalTags,
    required this.fixedContributionsIP,
    required this.fixedContributionsPaymentDate,
    required this.contributionsIP1Percent,
    required this.contributionsIP1PercentPaymentDate,
  });

  bool _hasData() {
    return cleanStringList(activityTypes).isNotEmpty ||
        cleanStringList(additionalTags).isNotEmpty ||
        cleanStringList(fixedContributionsIP).isNotEmpty ||
        cleanStringList(contributionsIP1Percent).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData()) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;
    final sectionStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: TaskStyles.textBody(colorScheme),
    );
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );

    final blocks = <Widget>[
      _buildListBlock(
        label: 'Виды деятельности',
        icon: Icons.work_outline,
        items: activityTypes,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'Теги',
        icon: Icons.label_outlined,
        items: additionalTags,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildContributionBlock(
        label: 'Фиксированные взносы ИП',
        icon: Icons.payments_outlined,
        types: fixedContributionsIP,
        paymentDates: fixedContributionsPaymentDate,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildContributionBlock(
        label: 'Взносы ИП 1%',
        icon: Icons.percent_outlined,
        types: contributionsIP1Percent,
        paymentDates: contributionsIP1PercentPaymentDate,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
    ];

    final visibleBlocks = blocks.where((block) => block is! SizedBox).toList();
    if (visibleBlocks.isEmpty) return const SizedBox.shrink();

    return OfficeFieldFrame(
      label: 'Дополнительно',
      watermarkIcon: Icons.more_horiz_outlined,
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in visibleBlocks.indexed) ...[
            entry.$2,
            if (entry.$1 < visibleBlocks.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildListBlock({
    required String label,
    required IconData icon,
    required List<String> items,
    required Color accent,
    required TextStyle sectionStyle,
    required TextStyle valueStyle,
  }) {
    final clean = cleanStringList(items);
    if (clean.isEmpty) return const SizedBox.shrink();
    const valueIndent = 22.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accent.withValues(alpha: 0.85)),
            const SizedBox(width: 6),
            Text(label, style: sectionStyle),
          ],
        ),
        const SizedBox(height: 6),
        for (final item in clean)
          Padding(
            padding: const EdgeInsets.only(left: valueIndent),
            child: OfficeBulletLine(
              icon: Icons.check_circle_outline,
              accentColor: accent,
              text: item,
              textStyle: valueStyle,
            ),
          ),
      ],
    );
  }

  Widget _buildContributionBlock({
    required String label,
    required IconData icon,
    required List<String> types,
    required List<int> paymentDates,
    required Color accent,
    required TextStyle sectionStyle,
    required TextStyle valueStyle,
  }) {
    final clean = cleanStringList(types);
    if (clean.isEmpty) return const SizedBox.shrink();
    const valueIndent = 22.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accent.withValues(alpha: 0.85)),
            const SizedBox(width: 6),
            Text(label, style: sectionStyle),
          ],
        ),
        const SizedBox(height: 6),
        for (final item in clean)
          Padding(
            padding: const EdgeInsets.only(left: valueIndent),
            child: OfficeBulletLine(
              icon: Icons.check_circle_outline,
              accentColor: accent,
              text: item,
              textStyle: valueStyle,
            ),
          ),
        if (paymentDates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: valueIndent),
            child: OfficeBulletLine(
              icon: Icons.event_outlined,
              accentColor: accent,
              text: 'Даты: ${formatPaymentDates(paymentDates)}',
              textStyle: valueStyle,
            ),
          ),
      ],
    );
  }
}
