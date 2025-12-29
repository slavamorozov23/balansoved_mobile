import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/client_detail/fields/client_field_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientTaxSectionField extends StatelessWidget {
  final List<String> taxSystems;
  final List<String> profitTaxTypes;
  final List<String> vatTypes;
  final List<String> propertyTypes;
  final String? reportingType;
  final String? reportingOperator;
  final List<String> exciseGoods;
  final List<String> excisePaymentTerms;
  final List<String> edoOperators;
  final String? enpType;
  final String? ndflType;

  const ClientTaxSectionField({
    super.key,
    required this.taxSystems,
    required this.profitTaxTypes,
    required this.vatTypes,
    required this.propertyTypes,
    required this.reportingType,
    required this.reportingOperator,
    required this.exciseGoods,
    required this.excisePaymentTerms,
    required this.edoOperators,
    required this.enpType,
    required this.ndflType,
  });

  bool _hasData() {
    return cleanStringList(taxSystems).isNotEmpty ||
        cleanStringList(profitTaxTypes).isNotEmpty ||
        cleanStringList(vatTypes).isNotEmpty ||
        cleanStringList(propertyTypes).isNotEmpty ||
        (reportingType?.trim().isNotEmpty ?? false) ||
        (reportingOperator?.trim().isNotEmpty ?? false) ||
        cleanStringList(exciseGoods).isNotEmpty ||
        cleanStringList(excisePaymentTerms).isNotEmpty ||
        cleanStringList(edoOperators).isNotEmpty ||
        (enpType?.trim().isNotEmpty ?? false) ||
        (ndflType?.trim().isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData()) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
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
        label: 'Система налогообложения',
        icon: Icons.gavel_outlined,
        items: taxSystems,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'Налог на прибыль',
        icon: Icons.trending_up_outlined,
        items: profitTaxTypes,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'НДС',
        icon: Icons.percent_outlined,
        items: vatTypes,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'Имущество',
        icon: Icons.home_work_outlined,
        items: propertyTypes,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildValueLine(
        label: 'Отчётность',
        icon: Icons.description_outlined,
        value: reportingType,
        accent: accent,
        valueStyle: valueStyle,
      ),
      _buildValueLine(
        label: 'Оператор отчётности',
        icon: Icons.engineering_outlined,
        value: reportingOperator,
        accent: accent,
        valueStyle: valueStyle,
      ),
      _buildValueLine(
        label: 'ЕНП',
        icon: Icons.payment_outlined,
        value: enpType,
        accent: accent,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'Подакцизные товары',
        icon: Icons.shopping_cart_outlined,
        items: exciseGoods,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'Сроки уплаты акцизов',
        icon: Icons.schedule_outlined,
        items: excisePaymentTerms,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildListBlock(
        label: 'Оператор ЭДО',
        icon: Icons.cloud_outlined,
        items: edoOperators,
        accent: accent,
        sectionStyle: sectionStyle,
        valueStyle: valueStyle,
      ),
      _buildValueLine(
        label: 'НДФЛ',
        icon: Icons.person_outline,
        value: ndflType,
        accent: accent,
        valueStyle: valueStyle,
      ),
    ].whereType<Widget>().toList();

    final visibleBlocks =
        blocks.where((block) => block is! SizedBox).toList();
    if (visibleBlocks.isEmpty) return const SizedBox.shrink();

    return OfficeFieldFrame(
      label: 'Налоги и отчётность',
      watermarkIcon: Icons.account_balance_wallet_outlined,
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

  Widget _buildValueLine({
    required String label,
    required IconData icon,
    required String? value,
    required Color accent,
    required TextStyle valueStyle,
  }) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return const SizedBox.shrink();

    return OfficeBulletLine(
      icon: icon,
      accentColor: accent,
      text: '$label: $clean',
      textStyle: valueStyle,
    );
  }
}
