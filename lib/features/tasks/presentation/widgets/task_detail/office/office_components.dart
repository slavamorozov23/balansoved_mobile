import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class OfficeEmptyValue extends StatelessWidget {
  const OfficeEmptyValue({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      '–',
      style: TextStyle(
        color: TaskStyles.textMuted(colorScheme),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class OfficeBulletLine extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String text;
  final TextStyle? textStyle;
  final Widget? leading;

  const OfficeBulletLine({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.text,
    this.textStyle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w600,
      fontSize: 13,
      height: 1.35,
    );
    final valueStyle = textStyle ?? defaultStyle;
    final leadingWidget =
        leading ??
        Icon(icon, size: 16, color: accentColor.withValues(alpha: 0.8));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leadingWidget,
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: valueStyle)),
      ],
    ).padding(bottom: 6);
  }
}

class OfficeNameTag extends StatelessWidget {
  final String name;
  final Color accentColor;

  const OfficeNameTag({super.key, required this.name, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = accentColor.withValues(alpha: 0.25);
    final bg =
        Color.lerp(accentColor, colorScheme.surface, 0.92) ??
        colorScheme.surface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TaskStyles.buildAvatar(name, colorScheme, size: 26),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: TaskStyles.textPrimary(colorScheme),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    )
        .padding(horizontal: 10, vertical: 8)
        .decorated(
          color: bg.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        )
        .clipRRect(all: 20);
  }
}

class OfficeDateValue extends StatelessWidget {
  final DateTime? date;
  final Color accentColor;

  const OfficeDateValue({super.key, required this.date, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (date == null) return const OfficeEmptyValue();

    final day = date!.day.toString().padLeft(2, '0');
    final month = date!.month.toString().padLeft(2, '0');

    return Row(
      children: [
        Container(
          width: 46,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                month,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            TaskDetailUtils.formatDate(date),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: TaskStyles.textPrimary(colorScheme),
            ),
          ),
        ),
      ],
    );
  }
}

class OfficeClockDateTimeValue extends StatelessWidget {
  final DateTime? date;
  final Color accentColor;
  final TextStyle? timeTextStyle;
  final TextStyle? dateTextStyle;
  final TextStyle? centerLabelStyle;

  const OfficeClockDateTimeValue({
    super.key,
    required this.date,
    required this.accentColor,
    this.timeTextStyle,
    this.dateTextStyle,
    this.centerLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (date == null) return const OfficeEmptyValue();

    final colorScheme = Theme.of(context).colorScheme;
    final dt = date!;

    final timeText = DateFormat('HH:mm').format(dt);
    final fullDateText = DateFormat('dd.MM.yy').format(dt);
    final dayMonthText = DateFormat('dd.MM').format(dt);

    final borderColor = accentColor.withValues(alpha: 0.22);
    final fill = accentColor.withValues(alpha: 0.10);
    final clockHandsColor = accentColor.withValues(alpha: 0.78);
    final clockTickColor = accentColor.withValues(alpha: 0.18);
    final clockBase = Color.lerp(
          colorScheme.surfaceContainerLowest,
          colorScheme.surface,
          0.55,
        ) ??
        colorScheme.surfaceContainerLowest;
    final centerLabelBg = Color.alphaBlend(fill, clockBase);

    final defaultTimeStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: TaskStyles.textPrimary(colorScheme),
    );
    final defaultDateStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: TaskStyles.textBody(colorScheme),
    );
    final defaultCenterStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.2,
      color: accentColor,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeText,
                style: timeTextStyle ?? defaultTimeStyle,
              ),
              const SizedBox(height: 2),
              Text(
                fullDateText,
                style: dateTextStyle ?? defaultDateStyle,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(56),
                painter: _OfficeClockPainter(
                  dateTime: dt,
                  fillColor: fill,
                  borderColor: borderColor,
                  tickColor: clockTickColor,
                  handsColor: clockHandsColor,
                ),
              ),
              Container(
                width: 36,
                height: 18,
                decoration: BoxDecoration(
                  color: centerLabelBg,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                dayMonthText,
                textAlign: TextAlign.center,
                style: centerLabelStyle ?? defaultCenterStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfficeClockPainter extends CustomPainter {
  final DateTime dateTime;
  final Color fillColor;
  final Color borderColor;
  final Color tickColor;
  final Color handsColor;

  const _OfficeClockPainter({
    required this.dateTime,
    required this.fillColor,
    required this.borderColor,
    required this.tickColor,
    required this.handsColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final fillPaint = Paint()..color = fillColor;
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius - 0.5, borderPaint);

    final tickPaint =
        Paint()
          ..color = tickColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

    // 12-hour ticks
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30.0 - 90.0) * (pi / 180.0);
      final outer = center + Offset(cos(angle), sin(angle)) * (radius - 5);
      final inner = center + Offset(cos(angle), sin(angle)) * (radius - 9);
      canvas.drawLine(inner, outer, tickPaint);
    }

    final handsPaint =
        Paint()
          ..color = handsColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final hour = dateTime.hour % 12;
    final minute = dateTime.minute;

    final minuteAngle =
        ((minute / 60.0) * 360.0 - 90.0) * (pi / 180.0);
    final hourAngle =
        (((hour + minute / 60.0) / 12.0) * 360.0 - 90.0) * (pi / 180.0);

    final minuteHandLength = radius - 10;
    final hourHandLength = radius - 16;

    handsPaint.strokeWidth = 2;
    canvas.drawLine(
      center,
      center + Offset(cos(minuteAngle), sin(minuteAngle)) * minuteHandLength,
      handsPaint,
    );

    handsPaint.strokeWidth = 3;
    canvas.drawLine(
      center,
      center + Offset(cos(hourAngle), sin(hourAngle)) * hourHandLength,
      handsPaint,
    );

    final knobPaint = Paint()..color = handsColor;
    canvas.drawCircle(center, 2.2, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _OfficeClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.handsColor != handsColor;
  }
}

class OfficeMiniCounterStamp extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData watermarkIcon;
  final Color accentColor;
  final int count;

  const OfficeMiniCounterStamp({
    super.key,
    required this.label,
    required this.icon,
    required this.watermarkIcon,
    required this.accentColor,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = TaskStyles.dividerColor(colorScheme).withValues(
      alpha: 0.45,
    );
    final background =
        Color.lerp(accentColor, colorScheme.surface, 0.94) ??
        colorScheme.surface;
    final shown = count > 0 ? count.toString() : '–';

    return Stack(
      children: [
        Positioned(
          right: -10,
          top: -10,
          child: Icon(
            watermarkIcon,
            size: 56,
            color: accentColor.withValues(alpha: 0.08),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 18, color: accentColor),
            Text(
              shown,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: TaskStyles.textPrimary(colorScheme),
              ),
            ),
            Text(
              label.toUpperCase(),
              style: TaskStyles.sectionLabelStyle(colorScheme),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    )
        .padding(all: 12)
        .constrained(height: 110)
        .decorated(
          color: background.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
        )
        .clipRRect(all: 18);
  }
}

class OfficePriorityStars extends StatelessWidget {
  final String priority;
  final Color color;

  const OfficePriorityStars({
    super.key,
    required this.priority,
    required this.color,
  });

  int _countForPriority() {
    switch (priority) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      case 'critical':
        return 4;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _countForPriority();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) => Icon(
          index < count ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: color.withValues(alpha: index < count ? 1 : 0.35),
        ),
      ),
    );
  }
}

List<String> resolveEmployeeNames(
  List<String> userIds,
  List<EmployeeEntity> employees,
) {
  if (userIds.isEmpty) return const [];
  if (employees.isEmpty) return userIds;

  final byId = {for (final e in employees) e.id: e};
  return userIds
      .map((id) {
        final employee = byId[id];
        if (employee == null) return id;
        return employee.userName ?? employee.email ?? employee.id;
      })
      .where((name) => name.trim().isNotEmpty)
      .toList();
}
