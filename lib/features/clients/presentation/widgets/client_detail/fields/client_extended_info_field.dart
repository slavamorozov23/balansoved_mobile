import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientExtendedInfoField extends StatelessWidget {
  final String? ownershipForm;
  final String? okpo;
  final String? ogrn;
  final String? legalAddress;
  final String? actualAddress;
  final bool actualAddressSameAsLegal;
  final SfrInfo? sfrInfo;
  final List<FnsInfo> fnsInfo;
  final List<KppInfo> kppInfo;

  const ClientExtendedInfoField({
    super.key,
    required this.ownershipForm,
    required this.okpo,
    required this.ogrn,
    required this.legalAddress,
    required this.actualAddress,
    required this.actualAddressSameAsLegal,
    required this.sfrInfo,
    required this.fnsInfo,
    required this.kppInfo,
  });

  @override
  Widget build(BuildContext context) {
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
    final borderColor = TaskStyles.dividerColor(colorScheme).withValues(
      alpha: 0.45,
    );

    return OfficeFieldFrame(
      label: 'Расширенная информация',
      watermarkIcon: Icons.business_center_outlined,
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Регистрационные данные', style: sectionStyle),
          const SizedBox(height: 6),
          OfficeBulletLine(
            icon: Icons.numbers_outlined,
            accentColor: accent,
            text: 'ОКПО: ${_valueOrDash(okpo)}',
            textStyle: valueStyle,
          ),
          OfficeBulletLine(
            icon: Icons.badge_outlined,
            accentColor: accent,
            text: '${_ogrnLabel()}: ${_valueOrDash(ogrn)}',
            textStyle: valueStyle,
          ),
          const SizedBox(height: 12),
          Text('Адреса', style: sectionStyle),
          const SizedBox(height: 6),
          OfficeBulletLine(
            icon: Icons.location_on_outlined,
            accentColor: accent,
            text: 'Юридический: ${_valueOrDash(legalAddress)}',
            textStyle: valueStyle,
          ),
          _buildBoolLine(
            context,
            label: 'Фактический совпадает',
            value: actualAddressSameAsLegal,
            icon: Icons.check_box_outlined,
            accent: accent,
            valueStyle: valueStyle,
          ),
          if (!actualAddressSameAsLegal)
            OfficeBulletLine(
              icon: Icons.home_outlined,
              accentColor: accent,
              text: 'Фактический: ${_valueOrDash(actualAddress)}',
              textStyle: valueStyle,
            ),
          const SizedBox(height: 12),
          Text('Информация о СФР', style: sectionStyle),
          const SizedBox(height: 6),
          _buildSfrBlock(accent, valueStyle),
          const SizedBox(height: 12),
          Text('Информация о ФНС', style: sectionStyle),
          const SizedBox(height: 6),
          _buildFnsBlock(accent, borderColor, colorScheme, valueStyle),
          const SizedBox(height: 12),
          Text('Информация о КПП', style: sectionStyle),
          const SizedBox(height: 6),
          _buildKppBlock(accent, borderColor, colorScheme, valueStyle),
        ],
      ),
    );
  }

  String _ogrnLabel() {
    if (ownershipForm == 'ООО' || ownershipForm == 'АО') return 'ОГРН';
    if (ownershipForm == 'ИП' || ownershipForm == 'КФХ' || ownershipForm == 'КХ') {
      return 'ОГРНИП';
    }
    return 'ОГРН/ОГРНИП';
  }

  String _valueOrDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '–' : trimmed;
  }

  Widget _buildBoolLine(
    BuildContext context, {
    required String label,
    required bool value,
    required IconData icon,
    required Color accent,
    required TextStyle valueStyle,
  }) {
    final textStyle = valueStyle;
    final statusIcon =
        value ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final statusColor =
        value ? Colors.green.shade600 : Theme.of(context).colorScheme.error;

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
  }

  Widget _buildSfrBlock(Color accent, TextStyle valueStyle) {
    final number = sfrInfo?.number.trim() ?? '';
    final code = sfrInfo?.subordinationCode.trim() ?? '';
    if (number.isEmpty && code.isEmpty) {
      return const OfficeEmptyValue();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OfficeBulletLine(
          icon: Icons.confirmation_number_outlined,
          accentColor: accent,
          text: 'Номер: ${_valueOrDash(number)}',
          textStyle: valueStyle,
        ),
        OfficeBulletLine(
          icon: Icons.code_outlined,
          accentColor: accent,
          text: 'Код подчинённости: ${_valueOrDash(code)}',
          textStyle: valueStyle,
        ),
      ],
    );
  }

  Widget _buildFnsBlock(
    Color accent,
    Color borderColor,
    ColorScheme colorScheme,
    TextStyle valueStyle,
  ) {
    if (fnsInfo.isEmpty) {
      return Text(
        'Информация о ФНС не добавлена',
        style: TextStyle(color: TaskStyles.textMuted(colorScheme)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in fnsInfo.asMap().entries) ...[
          _InfoCard(
            title: 'ФНС ${entry.key + 1}',
            borderColor: borderColor,
            accentColor: accent,
            children: [
              OfficeBulletLine(
                icon: Icons.tag_outlined,
                accentColor: accent,
                text: 'Код: ${_valueOrDash(entry.value.code)}',
                textStyle: valueStyle,
              ),
              OfficeBulletLine(
                icon: Icons.location_city_outlined,
                accentColor: accent,
                text: 'ОКТМО: ${_valueOrDash(entry.value.oktmo)}',
                textStyle: valueStyle,
              ),
              OfficeBulletLine(
                icon: Icons.business_outlined,
                accentColor: accent,
                text: 'Название: ${_valueOrDash(entry.value.name)}',
                textStyle: valueStyle,
              ),
              OfficeBulletLine(
                icon: Icons.event_outlined,
                accentColor: accent,
                text:
                    'Дата: ${TaskDetailUtils.formatDate(entry.value.date)}',
                textStyle: valueStyle,
              ),
            ],
          ),
          if (entry.key < fnsInfo.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildKppBlock(
    Color accent,
    Color borderColor,
    ColorScheme colorScheme,
    TextStyle valueStyle,
  ) {
    if (kppInfo.isEmpty) {
      return Text(
        'Информация о КПП не добавлена',
        style: TextStyle(color: TaskStyles.textMuted(colorScheme)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in kppInfo.asMap().entries) ...[
          _InfoCard(
            title: 'КПП ${entry.key + 1}',
            borderColor: borderColor,
            accentColor: accent,
            children: [
              OfficeBulletLine(
                icon: Icons.credit_card_outlined,
                accentColor: accent,
                text: 'Номер: ${_valueOrDash(entry.value.number)}',
                textStyle: valueStyle,
              ),
              OfficeBulletLine(
                icon: Icons.event_outlined,
                accentColor: accent,
                text:
                    'Дата: ${TaskDetailUtils.formatDate(entry.value.date)}',
                textStyle: valueStyle,
              ),
            ],
          ),
          if (entry.key < kppInfo.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Color borderColor;
  final Color accentColor;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.borderColor,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              fontWeight: FontWeight.w700,
              color: TaskStyles.textPrimary(colorScheme),
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}
